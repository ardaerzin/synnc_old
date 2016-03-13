//
//  StreamViewController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/31/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager
import WCLUserManager

enum StreamVCState : Int {
    case Create = -1
    case ReadyToPlay = 1
    case Syncing = 2
    case Play = 3
    case Finished = 4
    case Hidden = 0
}

class StreamViewController : ASViewController {
    
    var _shadowNode : ASDisplayNode!
    var shadowNode : ASDisplayNode! {
        get {
            if _shadowNode == nil {
                _shadowNode = ASDisplayNode()
            }
            return _shadowNode
        }
    }
    
    var _shareController : ShareController!
    var shareController : ShareController! {
        get {
            if _shareController == nil {
                _shareController = ShareController()
            }
            return _shareController
        }
    }
    var _stopController : StopController!
    var stopController : StopController! {
        get {
            if _stopController == nil {
                _stopController = StopController()
            }
            return _stopController
        }
    }
    
    var selectedPopoverButton : ButtonNode!
    var _popContentController : PopController!
    var popContentController : PopController! {
        get {
            if _popContentController == nil {
                _popContentController = PopController()
                _popContentController.delegate = self
            }
            return _popContentController
        }
    }
    
    var chatController : ChatController! = ChatController()
    var listenersController : StreamListenersController! = StreamListenersController()
    var screenNode : StreamViewNode!
    var createController : StreamCreateController!
    
    
    var stream : Stream? {
        didSet {
            if stream != oldValue {
                self.configure(stream)
            }
        }
    }
    var isActiveController : Bool! {
        didSet {
            if isActiveController != oldValue {
                self.updatedActiveStatus(isActiveController)
            }
        }
    }
    var state : StreamVCState = .ReadyToPlay {
        didSet {
            if state != oldValue {
                AnalyticsEvent.new(category: "Stream", action: "StateChange", label: "\(state.rawValue)", value: nil)
                updatedState(state)
            }
        }
    }
    
    deinit {
    }
    
    init(stream : Stream?, playlist: SynncPlaylist? = nil){
        screenNode = StreamViewNode(chatNode: chatController.screenNode, chatbar : chatController.chatbar, content: StreamContentNode(usersNode: listenersController.screenNode))
        super.init(node: screenNode)
        screenNode.delegate = self
        
        self.addChildViewController(chatController)
        chatController.didMoveToParentViewController(self)

        self.automaticallyAdjustsScrollViewInsets = false
        self.stream = stream
        self.screenNode.mainScrollNode.delegate = self

        if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
            bg.infoNode.streamStatusButton.addTarget(self, action: Selector("toggleStreamStatus:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        
        if self.stream == nil {
            
            createController = StreamCreateController(backgroundNode: screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode, playlist: playlist)
            
            createController.parentController = self
            createController.delegate = self
            
            createController.contentNode.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
            self.addChildViewController(createController.playlistSelector)
            createController.playlistSelector.didMoveToParentViewController(self)
        }

        self.configure(self.stream)
        self.updateUsers(stream)

        (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).infoNode.addToFavoritesButton.addTarget(self, action: Selector("addSongToFavorites:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).infoNode.closeButton.addTarget(self, action: Selector("dismissStreamView:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        
        self.screenNode.headerNode.closeButton.addTarget(self, action: Selector("hideAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.screenNode.shareStreamButton.addTarget(self, action: Selector("shareStream:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.screenNode.stopStreamButton.addTarget(self, action: Selector("stopStream:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        self.screenNode.contentNode.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userFavPlaylistUpdated:"), name: "UpdatedFavPlaylist", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let p = parent as? StreamNavigationController {
            p.panRecognizer.delegate = self
        } else if parent == nil {
            StreamManager.sharedInstance.player.delegate = nil

            if let p = self.navigationController as? StreamNavigationController {
                p.panRecognizer.delegate = nil
            }
            if let x = _popContentController {
                x.delegate = nil
            }
            if let x = self.createController {
                x.delegate = nil
                x.parentController = nil
                x.contentNode.view.removeObserver(self, forKeyPath: "contentSize")
                self.createController = nil
            }

            self.screenNode.contentNode.view.removeObserver(self, forKeyPath: "contentSize")
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
            screenNode.delegate = nil
            self.screenNode.mainScrollNode.delegate = nil
        }
    }
    
    func configure(stream: Stream!) {
        
        if stream == nil {
            self.state = .Create
            screenNode.updateForState(createController)
        } else {
            screenNode.updateForState(stream: stream)
            self.screenNode.contentNode.headerNode.configure(stream)
            self.chatController.configure(stream)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updatedStream:"), name: "UpdatedStream", object: stream)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkActiveStream:"), name: "DidSetActiveStream", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("endedActiveStream:"), name: "EndedActiveStream", object: nil)
            
            self.checkActiveStream(nil)
        }
    }
    
    func updatedActiveStatus(status : Bool){
        if status {
            self.state = .Play
        } else {
            self.state = .ReadyToPlay
        }
    }
    
    func updatedState(state : StreamVCState) {
        self.chatController.isEnabled = state.rawValue >= StreamVCState.Syncing.rawValue && state.rawValue != StreamVCState.Finished.rawValue
        
        (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).state = state
        self.screenNode.state = state
        
        if state.rawValue >= StreamVCState.Play.rawValue {
            if StreamManager.sharedInstance.player.delegate !== self {
                StreamManager.sharedInstance.player.delegate = self
            }
            
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.playingState = StreamManager.sharedInstance.player.rate == 1 ? true : false
            }
        } else {
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.playingState = false
            }
        }
    }


}

// MARK: - Button Targets
extension StreamViewController {
    func dismissStreamView(sender : ButtonNode){
        self.hideAction(sender)
    }
    func hideAction(sender : ButtonNode) {
        if let nvc = self.navigationController as? StreamNavigationController {
            nvc.hide()
        }
        AnalyticsEvent.new(category: "Stream", action: "Hide", label: nil, value: nil)
    }
    func toggleStreamStatus(sender : TitleColorButton){
        if sender.selected {
            return
        }
        
        if let s = self.stream where s == StreamManager.sharedInstance.userStream {
            if StreamManager.canSetActiveStream(self.stream!) {
                if self.stream == StreamManager.sharedInstance.userStream {
                    StreamManager.setActiveStream(self.stream!)
                    StreamManager.playStream(self.stream!)
                }
            }
        } else {
            self.state = .Syncing
            AnalyticsEvent.new(category: "Stream", action: "join", label: nil, value: nil)
            StreamManager.sharedInstance.joinStream(self.stream!) {
                success in
                if success {
                    //                StreamManager.sharedInstance.player.delegate = self
                }
            }
        }
    }
    
    func stopStream(sender : ButtonNode) {
        sender.selected = !sender.selected
        AnalyticsEvent.new(category: "Stream", action: "SubmenuToggle", label: "stopControl", value: nil)
        togglePopover(sender, contentController: stopController)
    }
    
    func shareStream(sender : ButtonNode) {
        sender.selected = !sender.selected
        if let s = self.stream {
            shareController.configure(s)
        }
        AnalyticsEvent.new(category: "Stream", action: "SubmenuToggle", label: "share", value: nil)
        togglePopover(sender, contentController: shareController)
    }
    
    func userFavPlaylistUpdated(notification: NSNotification){
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        let song = st.playlist.songs[ind as Int]
        let button = (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).infoNode.addToFavoritesButton
        var anim : POPBasicAnimation
        if let x = button.pop_animationForKey("hide") as? POPBasicAnimation {
            anim = x
        } else {
            anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            anim.duration = 0.2
            button.pop_addAnimation(anim, forKey: "hide")
        }
        
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist(), let _ = plist.indexOf(song) {
            button.selected = true
        } else {
            button.selected = false
        }
        
        anim.toValue = 1
    }
    
    func addSongToFavorites(sender : ButtonNode){
        
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        animation.duration = 0.2
        animation.toValue = 0
        sender.pop_addAnimation(animation, forKey: "hide")
        
        let song = st.playlist.songs[ind as Int]
        
        StreamManager.sharedInstance.toggleTrackFavStatus(song, callback: {
            status in
            AnalyticsEvent.new(category: "Stream", action: "FavSong", label: status ? "add" : "remove", value: nil)
        })
    }
}


// MARK: - ParallaxNodeDelegate
extension StreamViewController : ParallaxNodeDelegate {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === self.screenNode.mainScrollNode.parallaxContentNode.view {
            self.updateScrollSizes()
        }
    }
    func updateScrollSizes(){
        let csh = (self.screenNode.mainScrollNode.parallaxContentNode.view as! UIScrollView).contentSize.height
        let totalCs = csh + self.screenNode.mainScrollNode.backgroundNode.calculatedSize.height
        if totalCs != self.screenNode.mainScrollNode.view.contentSize.height {
            self.screenNode.mainScrollNode.view.contentSize = CGSizeMake(self.view.frame.size.width, totalCs)
        }
    }
    func imageForBackground() -> (image: AnyObject?, viewMode: UIViewContentMode?) {
        if let s = self.stream {
            let transformation = CLTransformation()
            
            transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
            transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
            transformation.crop = "fill"
            
            if let str = s.img, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                return (image: url, viewMode: nil)
            }
        } else {
            if let cc = self.createController {
                if let img = cc.selectedImage {
                    return (image: img, viewMode: nil)
                } else if let plist = cc.playlist, let str = plist.cover_id where str != "" {
                    let transformation = CLTransformation()
                    
                    transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.crop = "fill"
                    
                    if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                        return (image: url, viewMode: nil)
                    }
                }
            }
        }
        return (image: Synnc.appIcon, viewMode: .Center)
    }
    func gradientImageName() -> String? {
        return "PICTINT"
    }
}

extension StreamViewController : StreamerDelegate {
    func streamer(streamer: WildPlayer!, isSyncing syncing: Bool) {
        self.state = syncing ? .Syncing : ((self.isActiveController! && streamer.isPlaying) ? .Play : .ReadyToPlay)
    }
    func streamer(streamer: WildPlayer!, updatedPlaylistIndex index: Int) {
        if let track = self.stream?.playlist.songs[index] {
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.updateForTrack(track)
            }
        }
    }
    func streamer(streamer: WildPlayer!, updatedRate rate: Float) {
        self.updatedState(self.state)
    }
    
//    func endOfPlaylist(streamer: WildPlayer!) {
//        if let s = self.stream {
//            StreamManager.sharedInstance.stopStream(s) {
//                stopped in
//                self.state = .Finished
//            }
//        }
//    }
}

// MARK: - Edit and Create Controller
extension StreamViewController : StreamCreateControllerDelegate {
    func createdStream(stream: Stream) {
        self.stream = stream
        
        if StreamManager.canSetActiveStream(self.stream!) {
            if self.stream == StreamManager.sharedInstance.userStream {
                StreamManager.setActiveStream(self.stream!)
                StreamManager.playStream(self.stream!)
            }
        }
    }
    func updatedData() {
        self.screenNode.fetchData()
    }
}

// MARK: - Notifications and update functions
extension StreamViewController {
    
    func endedActiveStream(notification: NSNotification!){
        if self.stream == StreamManager.sharedInstance.userStream {
            self.state = .Finished
        } else {
            self.state = .ReadyToPlay
        }
        
    }
    func checkActiveStream(notification: NSNotification!){
        if let s = self.stream, let st = StreamManager.sharedInstance.activeStream where s == st {
            self.isActiveController = true
        } else {
            self.isActiveController = false
        }
    }
    func updatedStream(notification: NSNotification){
        if let keys = notification.userInfo?["updatedKeys"] as? [String]{
            Async.main {
                if let stream = notification.object as? Stream {
                    if let _ = keys.indexOf("users") {
                        self.updateUsers(stream)
                    }
                    if let _ = keys.indexOf("currentSongIndex") {
                        self.updateTrack(stream)
                    }
                }
            }
        }
    }
    internal func updateUsers(stream : Stream!){
        if let s = stream {
            self.listenersController.update(s)
            self.screenNode.contentNode.connectedUsersNode.emptyState = s.users.isEmpty
        } else {
            self.screenNode.contentNode.connectedUsersNode.emptyState = true
        }
    }
    internal func updateTrack(stream : Stream){
        if let ind = stream.currentSongIndex {
            let song = stream.playlist.songs[ind as Int]
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.updateForTrack(song)
            }
        }
    }
}

extension StreamViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.mainScrollNode.view.panGestureRecognizer || otherGestureRecognizer == self.chatController.panRecognizer {
            return true
        } else {
            return false
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.mainScrollNode.view.panGestureRecognizer || otherGestureRecognizer == self.chatController.panRecognizer {
            return true
        } else {
            return false
        }
    }
}

extension StreamViewController : ParallaxContentScrollerDelegate {
    func scrollViewDidScroll(scroller: ParallaxContentScroller, position: CGFloat) {
        if let _ = self.parentViewController as? StreamNavigationController where position <= -50 {
            self.resetScrollPosition()
        } else {
            scroller.view.panGestureRecognizer.enabled = true
        }
    }
    func resetScrollPosition(){
        if let s = self.screenNode.mainScrollNode.view {
            s.programaticScrollEnabled = false
            s.panGestureRecognizer.enabled = false
            s.programaticScrollEnabled = true
            
            let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
            s.pop_addAnimation(animation, forKey: "offsetAnim")
            animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
        }
    }
}

extension StreamViewController {
    func togglePopover(sender : ButtonNode, contentController : PopContentController!){
        if sender.selected {
            if let selected = selectedPopoverButton where selected != sender {
                selected.selected = false
            }
            self.selectedPopoverButton = sender
        } else {
            self.selectedPopoverButton = nil
        }
        self.popContentController.screenNode.arrowPosition = sender.position
        
        if sender.selected {
            
            if let c = contentController {
                self.popContentController.screenNode.topMargin = sender.calculatedSize.height / 2 + sender.position.y + 20
                self.popContentController.setContent(c)
                
                let x = c.screenNode.measureWithSizeRange(ASSizeRangeMake(CGSizeMake(self.view.frame.width, 0), CGSizeMake(self.view.frame.width, self.view.frame.height - 50 - 30)))
                var s = x.size
                s.height += 20
                
            
                if !self.popContentController.displayed {
                    self.addChildViewController(self.popContentController)
                    if self.popContentController.view.frame == CGRectZero {
                        self.popContentController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 50 - 30)
                    }
                    self.popContentController.screenNode.displayAnimation.completionBlock = {
                        anim, finished in
                        self.popContentController.screenNode.pop_removeAnimationForKey("displayAnimation")
                    }
                    self.screenNode.addSubnode(self.popContentController.screenNode)
                    
                    self.popContentController.didMoveToParentViewController(self)
                    self.popContentController.screenNode.displayAnimation.toValue = 1
                    self.popContentController.displayed = true
                }
            }
            
        } else {
            self.popContentController.hidePopover(nil)
        }
    }
    
}

extension StreamViewController : PopControllerDelegate {
    func hidePopController() {
        selectedPopoverButton.selected = false
        self.togglePopover(self.selectedPopoverButton, contentController: nil)
    }
}
