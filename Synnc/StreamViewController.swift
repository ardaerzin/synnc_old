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

class StreamViewController : ASViewController {
    
    var chatController : ChatController!
    var listenersController : StreamUsersController! = StreamUsersController()
    var screenNode : StreamViewNode!
    var stream : Stream? {
        didSet {
            if let s = stream where stream != oldValue {
                self.configure(s)
            }
        }
    }
    
    func configure(stream: Stream) {
        self.screenNode.contentNode.headerNode.configure(stream)
        self.chatController.configure(stream)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updatedStream:"), name: "UpdatedStream", object: stream)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkActiveStream:"), name: "DidSetActiveStream", object: stream)
        
        self.checkActiveStream(nil)
    }
    
    var createController : StreamCreateController!
    
    init(stream : Stream?){
        let chatController = ChatController()
        let node = StreamViewNode(chatNode: chatController.node, chatbar : chatController.chatbar, content: StreamContentNode(usersNode: listenersController.screenNode))
        
        super.init(node: node)
        self.chatController = chatController
        node.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.stream = stream
        self.screenNode = node
        self.screenNode.headerNode.closeButton.addTarget(self, action: Selector("hideAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.screenNode.contentNode.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        self.screenNode.mainScrollNode.delegate = self
        self.screenNode.chatbar.textNode.delegate = self.chatController
        if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
            bg.infoNode.streamStatusButton.addTarget(self, action: Selector("toggleStreamStatus:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        if self.stream == nil {
            
            createController = StreamCreateController(backgroundNode: node.mainScrollNode.backgroundNode as! StreamBackgroundNode)
            createController.parentController = self
            createController.delegate = self
            createController.contentNode.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
            
            node.updateForState(createController)
        } else {
            node.updateForState(stream: stream)
            self.updateUsers(stream!)
//            StreamManager.sharedInstance.player.delegate = self
            
            self.configure(stream!)
        }
        
        self.addChildViewController(chatController)
        chatController.didMoveToParentViewController(self)
        
    }
    func hideAction(sender : ButtonNode) {
        if let nvc = self.navigationController as? StreamNavigationController {
            nvc.hide()
        }
    }
    func toggleStreamStatus(sender : TitleColorButton){
        if sender.selected {
            return
        }
        StreamManager.sharedInstance.joinStream(self.stream!) {
            success in
            if success {
//                StreamManager.sharedInstance.player.delegate = self
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        listenersController.collectionView = self.screenNode.contentNode.connectedUsersNode.listenersCollection.view
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let p = parent as? StreamNavigationController {
            p.panRecognizer.delegate = self
        }
    }
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
}
extension StreamViewController : ParallaxNodeDelegate {
    func imageForBackground() -> AnyObject? {
        if let s = self.stream {
            let transformation = CLTransformation()
            
            transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
            transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
            transformation.crop = "fill"
            
            if let str = s.img, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                return url
            }
            
            
        } else {
            if let cc = self.createController {
                if let img = cc.selectedImage {
                    return img
                } else if let plist = cc.playlist, let str = plist.cover_id {
                    let transformation = CLTransformation()
                    
                    transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.crop = "fill"
                    
                    if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                        return url
                    }
                }
            }
        }
        return nil
    }
    func gradientImageName() -> String? {
        return "PICTINT"
    }
}
extension StreamViewController : StreamerDelegate {
    func streamer(streamer: WildPlayer!, isSyncing syncing: Bool) {
//        print("STREAMER: Is Syncing:", syncing)
    }
    func streamer(streamer: WildPlayer!, readyToPlay: Bool) {
//        print("STREAMER: Ready To Play:", readyToPlay)
    }
    func streamer(streamer: WildPlayer!, updatedPlaylistIndex index: Int) {
        if let track = self.stream?.playlist.songs[index] {
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.updateForTrack(track)
            }
        }
    }
    func streamer(streamer: WildPlayer!, updatedPreviewPosition position: CGFloat) {
//        print("STREAMER: Updated Preview Position:", position)
    }
    func streamer(streamer: WildPlayer!, updatedRate rate: Float) {
        if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
            bg.playingState = rate == 1 ? true : false
        }
    }
    func streamer(streamer: WildPlayer!, updatedPreviewStatus status: Bool) {
//        print("STREAMER: Updated Preview Status:", status)
    }
    func streamer(streamer: WildPlayer!, updatedToPosition position: CGFloat) {
//        print("STREAMER: Updated To Position:", position)
    }
    func streamer(streamer: WildPlayer!, updatedToTime: CGFloat) {
//        print("STREAMER: Updated To Time:", updatedToTime)
    }
}
extension StreamViewController : StreamCreateControllerDelegate {
    func checkActiveStream(notification: NSNotification!){
        if let s = self.stream, let st = StreamManager.sharedInstance.activeStream where s == st {
            (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).state = StreamBackgroundNodeState.Play
            self.chatController.isEnabled = true
            
            StreamManager.sharedInstance.player.delegate = self
            
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.playingState = StreamManager.sharedInstance.player.rate == 1 ? true : false
            }
        } else {
            (self.screenNode.mainScrollNode.backgroundNode as! StreamBackgroundNode).state = StreamBackgroundNodeState.ReadyToPlay
            self.chatController.isEnabled = false
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
    internal func updateUsers(stream : Stream){
        self.listenersController.update(stream)
        self.screenNode.contentNode.connectedUsersNode.emptyState = stream.users.isEmpty
    }
    internal func updateTrack(stream : Stream){
        if let ind = stream.currentSongIndex {
            let song = stream.playlist.songs[ind as Int]
            if let bg = self.screenNode.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.updateForTrack(song)
            }
        }
    }
    func createdStream(stream: Stream) {
        self.screenNode.updateForState(stream: stream)
        
        self.stream = stream
        if StreamManager.canSetActiveStream(self.stream!) {
            if self.stream == StreamManager.sharedInstance.userStream {
                StreamManager.setActiveStream(self.stream!)
                StreamManager.playStream(self.stream!)
            }
        }
    }
    func updatedImage(image: UIImage!) {
        
    }
    func updatedPlaylist(playlist: SynncPlaylist!) {
    }
    func updatedData() {
        self.screenNode.fetchData()
    }
    func resetScrollPosition() {
        let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
        self.screenNode.mainScrollNode.view.pop_addAnimation(animation, forKey: "offsetAnim")
        animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
    }
}
extension StreamViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension StreamViewController : ParallaxContentScrollerDelegate {
    func scrollViewDidScroll(scroller: ParallaxContentScroller, position: CGFloat) {
        if let _ = self.parentViewController as? StreamNavigationController where position <= -50 {
            if let s = scroller.view {
                s.programaticScrollEnabled = false
                scroller.view.panGestureRecognizer.enabled = false
                s.programaticScrollEnabled = true

                let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
                scroller.view.pop_addAnimation(animation, forKey: "offsetAnim")
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
            }
        } else {
            scroller.view.panGestureRecognizer.enabled = true
        }
    }
}