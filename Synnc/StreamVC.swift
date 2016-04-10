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

enum StreamControllerState : Int {
    case Inactive = 0
    case Active = 1
}

class StreamVC : PagerBaseController {
    
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
        
        if let s = stream {
            self.stream = s
        }
        
        node.nowPlayingArea.likeButton.addTarget(self, action: #selector(StreamVC.toggleTrackFav(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamViewController.userFavPlaylistUpdated(_:)), name: "UpdatedFavPlaylist", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure(stream)
        (self.screenNode.headerNode as! StreamHeaderNode).shareButton.addTarget(self, action: #selector(StreamVC.shareStream(_:)), forControlEvents: .TouchUpInside)
        (self.screenNode as! StreamVCNode).nowPlayingArea.volumeButton.addTarget(self, action: #selector(StreamVC.toggleMute(_:)), forControlEvents: .TouchUpInside)
        
        (self.screenNode as! StreamVCNode).nowPlayingArea.joinButton.addTarget(self, action: #selector(StreamVC.joinStream(_:)), forControlEvents: .TouchUpInside)
    }
    
    func toggleMute(sender: ButtonNode) {
        if stream != StreamManager.sharedInstance.activeStream {
            return
        }
        StreamManager.sharedInstance.player.volume = !sender.selected ? 1 : 0
    }
    func shareStream(sender: AnyObject) {
        
        let textToShare = "I'm listening to \(stream.user.username)'s stream, '\(stream.name)'"
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
            activityVC.completionWithItemsHandler = {
                (activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                
                AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: activityType, value: nil)
                if let w = self.view.wclWindow {
                    w.panRecognizer.enabled = true
                }
            }
            
            if let w = self.view.wclWindow {
                w.panRecognizer.enabled = false
            }
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func toggleTrackFav(sender: ButtonNode) {
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        if st != StreamManager.sharedInstance.activeStream {
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

    func userFavPlaylistUpdated(notification: NSNotification){
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        let song = st.playlist.songs[ind as Int]
        let button = (self.screenNode as! StreamVCNode).nowPlayingArea.likeButton
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamVC.endedActiveStream(_:)), name: "EndedActiveStream", object: nil)
        
        
        ((self.screenNode as! StreamVCNode).headerNode as! StreamHeaderNode).streamTitleNode.attributedString = NSAttributedString(string: stream.name, attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSKernAttributeName : 0.5, NSForegroundColorAttributeName : UIColor.whiteColor()])
        (self.screenNode as! StreamVCNode).headerNode.setNeedsLayout()
        
        if let id = stream.img {
            (self.screenNode as! StreamVCNode).imageHeader.imageId = stream.img as String
        } else {
            (self.screenNode as! StreamVCNode).imageHeader.imageNode.image = Synnc.appIcon
        }

        (self.screenNode as! StreamVCNode).imageHeader.fetchData()
        self.infoController.configure(stream)
        
        if stream == StreamManager.sharedInstance.activeStream {
            self.state = .Active
        }
        
        self.chatController.configure(stream)
        
        updateTrack(stream)
    }
    
    func endedActiveStream(notification: NSNotification!){
        print("WADAP SON")
        print("ended active stream")
        
        if let stream = notification.object as? Stream {
            if stream == StreamManager.sharedInstance.activeStream {
                print("INTERRUPTED")
            }
        }
        
//        if self.stream == StreamManager.sharedInstance.userStream {
//            self.state = .Finished
//        } else {
//            self.state = .ReadyToPlay
//        }
    }
    func checkActiveStream(notification: NSNotification!){
        if let s = self.stream, let st = StreamManager.sharedInstance.activeStream where s == st {
            self.state = .Active
            
            if let window = self.node.view.wclWindow {
                window.dismissable = false
            }
            StreamManager.sharedInstance.player.delegate = self
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
        if let w = self.view.wclWindow {
            if let pos = w.position where pos == .LowerLinked {
                w.transitionProgress = 1
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
        if let ind = stream.currentSongIndex {
            Async.main {
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

extension StreamVC : StreamerDelegate {
    func streamer(streamer: WildPlayer!, updatedToPosition position: CGFloat) {
        Async.main {
            if position.isFinite {
                (self.screenNode as! StreamVCNode).nowPlayingArea.updateProgress(position)
            }
        }
    }
    func streamer(streamer: WildPlayer!, updatedPlaylistIndex index: Int) {
        Async.main {
            self.updateTrack(self.stream)
        }
    }
    func streamer(streamer: WildPlayer!, volumeChanged volume: Float) {
        (self.screenNode as! StreamVCNode).nowPlayingArea.volumeButton.selected = volume > 0 ? true : false
    }
}

extension StreamVC : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        if stream == StreamManager.sharedInstance.activeStream {
            let screenNode = (self.screenNode as! StreamVCNode)
            
            let p = POPProgress(progress, startValue: 0, endValue: window.lowerPercentage)
            let transition = POPTransition(p, startValue: 0, endValue: -screenNode.calculatedSize.height*window.lowerPercentage)            
            screenNode.nowPlayingArea.windowTransition = transition
        }
        
        Async.main {
//            self.chatController.chatbar.textNode.view.endEditing(true)
//            self.chatController.chatbar.view.endEditing(true)
//            self.chatController.chatbar.textNode.resignFirstResponder()
//            self.chatController.shouldFirstRespond = false
//            self.chatController.resignFirstResponder()
            (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = 0
        }
        
//        self.chatController.chatbar.textNode.view.endEditing(true)
//        self.chatController.chatbar.view.endEditing(true)
//        self.chatController.chatbar.textNode.resignFirstResponder()
//        self.chatController.shouldFirstRespond = false
//        self.chatController.resignFirstResponder()
//        (self.screenNode as! StreamVCNode).nowPlayingArea.stateAnimation.toValue = 0
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
//            if self.
        }
    }
}

extension StreamVC {
    func joinStream(sender : AnyObject){
        
        if let node = sender as? ButtonNode {
            node.userInteractionEnabled = false
            node.showSpinView()
        }
        
        AnalyticsEvent.new(category: "ui_action", action: "button_tap", label: "Join Stream", value: nil)
        
        if let stream = StreamManager.sharedInstance.activeStream {
            
            let x = StreamInProgressPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200), playlist: nil)
            WCLPopupManager.sharedInstance.newPopup(x)
            
            return
        }
        
        if let s = self.stream {
            StreamManager.sharedInstance.joinStream(s) {
                success in
                if success {
                    //                StreamManager.sharedInstance.player.delegate = self
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
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || otherGestureRecognizer == (self.tracklistController.node as! StreamTracklistNode).tracksTable.view.panGestureRecognizer || otherGestureRecognizer == self.chatController.screenNode.chatCollection.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}
