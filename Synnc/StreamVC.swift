//
//  StreamVC.swift
//  Synnc
//
//  Created by Arda Erzin on 3/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager
import WCLPopupManager
import DKImagePickerController
import AssetsLibrary
import Cloudinary
import Shimmer
import WCLNotificationManager
import Async

enum StreamControllerState : Int {
    case Inactive = 0
    case Active = 1
}

class ShareWrapperVC : WCLPopupViewController {
    var shareController : UIActivityViewController!
    
    init(controller : UIActivityViewController) {
        super.init(nibName: nil, bundle: nil, size: UIScreen.mainScreen().bounds.size)
        self.shareController = controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didDisplay() {
        super.didDisplay()
        self.presentViewController(shareController, animated: true, completion: nil)
    }
    override func didHide() {
        super.didHide()
        shareController.dismissViewControllerAnimated(true, completion: nil)
    }
}

class StreamVC : PagerBaseController {
    
    var currentTrack : SynncTrack? {
        get {
            if let s = self.stream where s == StreamManager.sharedInstance.activeStream {
                if let ci = s.currentSongIndex where (ci as Int) < s.playlist.songs.count {
                    let track = stream.playlist.songs[ci as Int]
                    return track
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
    var actionSheet : ActionSheetPopup!
    var state : StreamControllerState! = .Inactive {
        didSet {
            (self.screenNode as! StreamVCNode).state = state
            self.infoController.screenNode.infoNode.state = state
        }
    }
    var stream : Stream!
    
    lazy var infoController : StreamInfoController = {
        return StreamInfoController()
    }()
    lazy var tracklistController : StreamTracklistController = {
        return StreamTracklistController()
    }()
    lazy var chatController : ChatController = {
        return ChatController()
    }()
    
    override var subControllers : [ASViewController]! {
        get {
            if self.childViewControllers.indexOf(infoController) == nil {
                self.addChildViewController(infoController)
            }
            if self.childViewControllers.indexOf(tracklistController) == nil {
                self.addChildViewController(tracklistController)
            }
            if self.childViewControllers.indexOf(chatController) == nil {
                self.addChildViewController(chatController)
            }
            return [infoController, tracklistController, chatController]
        }
    }
    
    init(stream : Stream?){
        let node = StreamVCNode()
        super.init(pagerNode: node)
        node.clipsToBounds = false
        
        (node.headerNode as! StreamHeaderNode).toggleButton.addTarget(self, action: #selector(StreamVC.toggleWindowPosition(_:)), forControlEvents: .TouchUpInside)
        
        if let s = stream {
            self.stream = s
        }
        
        let isUserStream = self.stream == StreamManager.sharedInstance.userStream
        
        node.nowPlayingArea.joinButton.setAttributedTitle(NSAttributedString(string: isUserStream ? "START" : "JOIN", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: .Normal)
        node.nowPlayingArea.joinButton.addTarget(self, action: isUserStream ? #selector(StreamVC.startStream(_:)) : #selector(StreamVC.joinStream(_:)), forControlEvents: .TouchUpInside)
        node.nowPlayingArea.submenuButton.addTarget(self, action: #selector(StreamVC.displayActionSheet(_:)), forControlEvents: .TouchUpInside)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.userFavPlaylistUpdated(_:)), name: "UpdatedFavPlaylist", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure(stream)
        (self.screenNode.headerNode as! StreamHeaderNode).shareButton.addTarget(self, action: #selector(StreamVC.shareStream(_:)), forControlEvents: .TouchUpInside)
        (self.screenNode as! StreamVCNode).nowPlayingArea.volumeButton.addTarget(self, action: #selector(StreamVC.toggleMute(_:)), forControlEvents: .TouchUpInside)
    }
    
    func toggleWindowPosition(sender : AnyObject) {
        var action : String = ""
        if let w = self.view.wclWindow {
            if w.position == .Displayed {
                w.hide(true)
                action = "close"
            } else {
                w.display(true)
                action = "display"
            }
        }
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "\(action) Stream", value: nil)
    }
    
    func toggleMute(sender: ButtonNode) {
        if stream != StreamManager.sharedInstance.activeStream {
            return
        }
        StreamManager.sharedInstance.playerManager.volume = !sender.selected ? 1 : 0
    }
    func shareStream(sender: AnyObject) {
        if let s = actionSheet {
            Async.background {
                s.closeView(true)
            }
        }
        
        let textToShare = "I'm listening to \(stream.user.username)'s stream, '\(stream.playlist.name)'"
        if let myWebsite = NSURL(string: "https://synnc.live") {
            let objectsToShare = [textToShare, myWebsite, (self.screenNode as! StreamVCNode).imageHeader.imageNode.image as! AnyObject, self.stream]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [SynncFacebookActivity()])
            activityVC.excludedActivityTypes = [UIActivityTypePostToWeibo,
                                                UIActivityTypeMessage,
                                                UIActivityTypeMail,
                                                UIActivityTypePrint,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeAssignToContact,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeAddToReadingList,
                                                UIActivityTypePostToFlickr,
                                                UIActivityTypePostToVimeo,
                                                UIActivityTypePostToTencentWeibo,
                                                UIActivityTypeAirDrop,
                                                UIActivityTypePostToFacebook]
           
            let x = ShareWrapperVC(controller: activityVC)
            activityVC.completionWithItemsHandler = {
                (activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                
                print("completed share", activityType)
                
                if let type = activityType {
                    AnalyticsEvent.new(category: "Share", action: type, label: nil, value: nil, customAttributes: ["contentName" : self.stream.playlist.name!, "contentType" : "stream", "contentId" : self.stream.o_id])
                }
                
                AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: activityType, value: nil)
                
                x.closeView(true)
                
                if let w = self.view.wclWindow {
                    w.panRecognizer.enabled = true
                }
            }
            
            if let w = self.view.wclWindow {
                w.panRecognizer.enabled = false
            }
            
            Synnc.sharedInstance.topPopupManager.newPopup(x)
        }
    }
    
    func endCurrentStream(sender : ButtonNode!) {
        
        sender.showSpinView()
        AnalyticsEvent.new(category: "StreamPopup", action: "buttonTap", label: "endCurrentStream", value: nil)
        if let activeStr = StreamManager.sharedInstance.activeStream {
            StreamManager.sharedInstance.stopStream(activeStr, completion: {
                [weak self]
                status in
                
                if self == nil {
                    return
                }
                if let s = self!.actionSheet {
                    Async.background {
                        s.closeView(true)
                    }
                }
            })
        }
    }
    
    func displayActionSheet(sender : AnyObject) {
        var isActiveStream = false
        if let s = self.stream where s == StreamManager.sharedInstance.activeStream {
            isActiveStream = true
        }
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        let shareButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        shareButton.setAttributedTitle(NSAttributedString(string: "Share", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        shareButton.minScale = 1
        shareButton.cornerRadius = 8
        shareButton.addTarget(self, action: #selector(StreamVC.shareStream(_:)), forControlEvents: .TouchUpInside)
        
        var stateButton : ButtonNode
        if !isActiveStream {
            let playButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
            playButton.setAttributedTitle(NSAttributedString(string: "Play", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
            playButton.addTarget(self, action: #selector(StreamVC.joinStream(_:)), forControlEvents: .TouchUpInside)
            playButton.minScale = 1
            playButton.cornerRadius = 8
            stateButton = playButton
        } else {
            let stopButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
            stopButton.setAttributedTitle(NSAttributedString(string: "Stop", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
            stopButton.minScale = 1
            stopButton.cornerRadius = 8
            stopButton.addTarget(self, action: #selector(StreamVC.endCurrentStream(_:)), forControlEvents: .TouchUpInside)
            stateButton = stopButton
        }
        
        let likeButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        likeButton.setAttributedTitle(NSAttributedString(string: "Like current track", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        likeButton.setAttributedTitle(NSAttributedString(string: "Unlike current track", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Selected)
        
        print("current track", self.currentTrack)
        
        if let track = currentTrack, let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist.hasTrack(track) {
            likeButton.selected = true
        } else {
            likeButton.selected = false
        }
        likeButton.minScale = 1
        likeButton.cornerRadius = 8
        likeButton.addTarget(self, action: #selector(StreamVC.toggleTrackFav(_:)), forControlEvents: .TouchUpInside)
        
        let buttons = [shareButton, likeButton, stateButton]
        
        
        actionSheet = ActionSheetPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 200), buttons : buttons)
        actionSheet.onCancel = {
            if let node = sender as? ButtonNode {
                node.userInteractionEnabled = true
                node.hideSpinView()
            }
        }
        WCLPopupManager.sharedInstance.newPopup(actionSheet)
    }
    
    func toggleTrackFav(sender: ButtonNode) {
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        if st != StreamManager.sharedInstance.activeStream {
            return
        }

        sender.selected = !sender.selected
//        let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
//        animation.duration = 0.2
//        animation.toValue = 0
//        sender.pop_addAnimation(animation, forKey: "hide")
        
        let song = st.playlist.songs[ind as Int]
        
        StreamManager.sharedInstance.toggleTrackFavStatus(song, callback: {
            status in
            AnalyticsEvent.new(category: "Stream", action: "FavSong", label: status ? "add" : "remove", value: nil)
        })
    }

    func userFavPlaylistUpdated(notification: NSNotification){
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
    }
    
    override func updatedPagerPosition(position : CGFloat) {
        super.updatedPagerPosition(position)
        if position <= 0.5 {
            Async.main {
                self.chatController.chatbar.textNode.view.endEditing(true)
                self.chatController.chatbar.view.endEditing(true)
                self.chatController.chatbar.textNode.resignFirstResponder()
                self.chatController.shouldFirstRespond = false
                self.chatController.resignFirstResponder()
                (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = 0
                
                let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                self.chatController.chatbar.pop_addAnimation(anim, forKey: "alpha")
                anim.duration = 0.1
                anim.toValue = 0
            }
        } else if self.stream == StreamManager.sharedInstance.activeStream {
            (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = (self.screenNode as! StreamVCNode).nowPlayingArea.calculatedSize.height
            chatController.shouldFirstRespond = true
            chatController.becomeFirstResponder()
            
            let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
            self.chatController.chatbar.pop_addAnimation(anim, forKey: "alpha")
            anim.duration = 0.1
            anim.toValue = 1
        }
        self.screenNode.headerNode.update(position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(stream: Stream) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.updatedStream(_:)), name: "UpdatedStream", object: stream)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.updatedStream(_:)), name: "UpdatedStreamLocally", object: stream)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.endedActiveStream(_:)), name: "EndedActiveStream", object: nil)
        
        let name = stream.playlist.name == nil ? "Untitled" : stream.playlist.name!
        ((self.screenNode as! StreamVCNode).headerNode as! StreamHeaderNode).streamTitleNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSKernAttributeName : 0.5, NSForegroundColorAttributeName : UIColor.whiteColor()])
        (self.screenNode as! StreamVCNode).headerNode.setNeedsLayout()
        
        if let id = stream.playlist.cover_id {
            (self.screenNode as! StreamVCNode).imageHeader.imageId = id
        } else {
            (self.screenNode as! StreamVCNode).imageHeader.imageNode.image = Synnc.appIcon
        }

        (self.screenNode as! StreamVCNode).imageHeader.setNeedsDataFetch()
        self.infoController.configure(stream)
        
        if stream == StreamManager.sharedInstance.activeStream {
            self.state = .Active
        }
        
        self.chatController.configure(stream)
        
        updateTrack(stream)
    }
    
    func endedActiveStream(notification: NSNotification!){
        print("ended active stream")
        
        if let stream = notification.object as? Stream {
            if stream == StreamManager.sharedInstance.activeStream {
                print("INTERRUPTED")
            }
        }
    }
    func checkActiveStream(notification: NSNotification!){
        if let s = self.stream, let st = StreamManager.sharedInstance.activeStream where s == st {
            self.state = .Active
            
            if let window = self.node.view.wclWindow {
                window.dismissable = false
            }
            StreamManager.sharedInstance.playerManager.delegate = self
            self.scrollViewDidScroll(self.screenNode.pager.view)
        } else {
            if let window = self.node.view.wclWindow {
                window.dismissable = true
            }
            self.state = .Inactive
            self.scrollViewDidScroll(self.screenNode.pager.view)
        }
        
        self.chatController.configure(stream)
        self.chatController.isEnabled = self.state == .Active ? true : false
        self.infoController.screenNode.infoNode.topSection.configure(self.stream!)
        
        if let window = self.screenNode.view.wclWindow {
            
            var lowerLimit : CGFloat = 0
            
            var isActiveStream : Bool
            
            if let thisSt = self.stream, let st = (notification.object as? Stream) where st == thisSt {
                isActiveStream = true
            } else {
                isActiveStream = false
            }
            
            if isActiveStream {
                lowerLimit = UIScreen.mainScreen().bounds.height - 70
            } else {
                lowerLimit = UIScreen.mainScreen().bounds.height
            }
            
            window.lowerPercentage = lowerLimit
        }
        
        if let w = self.view.wclWindow {
            
            print("window shit", self, w.lowerPercentage)
            
            if let pos = w.position where pos == .LowerLinked {
                w.animation.toValue = 1
            }
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
                    if let _ = keys.indexOf("playlist") {
                        self.configure(self.stream)
                    }
                }
            }
        }
    }
    
    internal func updateUsers(stream : Stream!){
        if let s = stream {
            self.infoController.listenersController.update(s)
        }
    }
    internal func updateTrack(stream : Stream){
        if let ind = stream.currentSongIndex where (Int(ind) >= 0) {
            Async.main {
                let i = ind as Int
                if i >= stream.playlist.songs.count {
                    return
                }
                print("SECTOR", ind)
                let track = stream.playlist.songs[ind as Int]
                self.tracklistController.currentIndex = ind as Int
                (self.screenNode as! StreamVCNode).nowPlayingArea.configure(track)
            }
        }
    }
    
    override func updatedCurrentIndex(index: Int) {
        if self.stream != StreamManager.sharedInstance.activeStream {
            return
        }
    }
}

extension StreamVC : PlayerManagerDelegate {
    func playerManager(manager: StreamPlayerManager!, updatedToPosition position: CGFloat) {
        Async.main {
            if position.isFinite {
                (self.screenNode as! StreamVCNode).nowPlayingArea.updateProgress(position)
            }
        }
    }
    func playerManager(manager: StreamPlayerManager!, updatedPlaylistIndex index: Int) {
        Async.main {
            self.updateTrack(self.stream)
        }
    }
    func playerManager(manager: StreamPlayerManager!, volumeChanged volume: Float) {
        (self.screenNode as! StreamVCNode).nowPlayingArea.volumeButton.selected = volume > 0 ? true : false
    }
}

extension StreamVC : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        if stream == StreamManager.sharedInstance.activeStream {
            let screenNode = (self.screenNode as! StreamVCNode)
            
            
            let p = POPProgress(progress, startValue: 0, endValue: window.lowerPercentage)
            let transition = POPTransition(p, startValue: 0, endValue: -screenNode.calculatedSize.height*window.lowerPercentage)
            if progress < 0 {
                screenNode.nowPlayingArea.windowTransition = 0
            } else {
                screenNode.nowPlayingArea.windowTransition = transition
            }
//            screenNode.nowPlayingArea.windowTransition = transition
        }
        
        Async.main {
            (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = 0
        }
        
        let x = 1-window.lowerPercentage
        let za = (1 - progress - x) / (1-x)
        
        (self.screenNode.headerNode as! StreamHeaderNode).toggleButton.progress = za
        self.screenNode.headerNode.leftButtonHolder.alpha = za
        self.screenNode.headerNode.rightButtonHolder.alpha = za
        self.screenNode.headerNode.pageControl.alpha = za
        
        let z = POPTransition(za, startValue: 10, endValue: 0)
        POPLayerSetTranslationY(self.screenNode.headerNode.titleHolder.layer, z)
    }
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            AnalyticsScreen.new(node: self.currentScreen())
        }
        
        if position != .Displayed {
            Async.main {
                self.chatController.chatbar.textNode.view.endEditing(true)
                self.chatController.chatbar.view.endEditing(true)
                self.chatController.chatbar.textNode.resignFirstResponder()
                self.chatController.shouldFirstRespond = false
                self.chatController.resignFirstResponder()
                
                let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                self.chatController.chatbar.pop_addAnimation(anim, forKey: "alpha")
                anim.duration = 0.1
                anim.toValue = 0
            }
        } else if self.stream == StreamManager.sharedInstance.activeStream {
            if self.currentIndex == 2 {
                (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = (self.screenNode as! StreamVCNode).nowPlayingArea.calculatedSize.height
                chatController.shouldFirstRespond = true
                chatController.becomeFirstResponder()
                
                let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                self.chatController.chatbar.pop_addAnimation(anim, forKey: "alpha")
                anim.duration = 0.1
                anim.toValue = 1
            }
        }
    }
}

extension StreamVC {
    
    func notJoiningStream(sender : AnyObject){
        if let node = sender as? ButtonNode {
            node.userInteractionEnabled = true
            node.hideSpinView()
        }
    }
    
    func startStream(sender : AnyObject!) {
        print("start stream now", self.stream.status)
        
        if self.stream != StreamManager.sharedInstance.userStream || self.stream.status {
            return
        }
        
        stream.update(["status" : true])
        StreamManager.setActiveStream(stream)
        StreamManager.playStream(stream)
    }
    
    func joinStream(sender : AnyObject!){
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
//        AnalyticsEvent.new(category: "ui_action", action: "button_tap", label: "Join Stream", value: nil)
        
        if let _ = StreamManager.sharedInstance.activeStream {
            
            let x = StreamInProgressPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200), playlist: nil)
            x.callback = self.joinStream
            x.node.noButton.addTarget(self, action: #selector(StreamVC.notJoiningStream(_:)), forControlEvents: .TouchUpInside)
            WCLPopupManager.sharedInstance.newPopup(x)
            
            return
        }
        
        if let s = self.stream {
            
            if !s.status {
                return
            }
            
            let t = s.playlist.canPlay()
            if t.status {
                if let node = sender as? ButtonNode {
                    node.userInteractionEnabled = false
                    node.showSpinView()
                }
                StreamManager.sharedInstance.joinStream(s) {
                    success in
                    
                    if let node = sender as? ButtonNode {
                        node.userInteractionEnabled = true
                        node.hideSpinView()
                    }
                }
            } else {
                
                guard let dict = t.reasonDict else {
                    return
                }
                
                
                var notificationMessage : (String, String)?
                var notificationAction : ((notif: WCLNotification) -> Void)?
                
                if let missingSources = dict["missingSources"] as? [String] {
                    if missingSources.count > 1 {
                        //multiple
                        
                        var str : String = ""
                        
                        for (index,src) in missingSources.enumerate() {
                            str += index == 0 ? "\(src)" : index == missingSources.count - 1 ? " and \(src)" : ", \(src)"
                        }
                        
                        notificationMessage = ("Please login to \(str.fixAppleMusic()) to listen to the Premium content in this stream.", "login")
                        notificationAction = nil
                        
                    } else if let src = missingSources.first {
                        
                        let str = src.fixAppleMusic()
                        notificationMessage = ("Please login to \(str) to listen to the Premium content in this stream.", "login")
                        notificationAction = {
                           notif in
                            if let type = WCLUserLoginType(rawValue: src.lowercaseString) {
                                Synnc.sharedInstance.user.socialLogin(type)
                            }
                        }
                    }
                }
                
                if let msg = notificationMessage {
                    SynncNotification(body: msg, image: "notification-warning", callback: notificationAction).addToQueue()
                }
            }
        }
    }
}

extension StreamVC {
    func updateScrollPosition(position : CGFloat) {
        (self.node as! StreamVCNode).imageHeader.updateScrollPosition(position)
    }
}

extension StreamVC : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.pager.view.panGestureRecognizer {
            return false
        }
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || otherGestureRecognizer == (self.tracklistController.node as! StreamTracklistNode).tracksTable.view.panGestureRecognizer || otherGestureRecognizer == self.chatController.screenNode.chatCollection.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
        
        return false
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

//        return true
//        return false
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || otherGestureRecognizer == (self.tracklistController.node as! StreamTracklistNode).tracksTable.view.panGestureRecognizer || otherGestureRecognizer == self.chatController.screenNode.chatCollection.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}
