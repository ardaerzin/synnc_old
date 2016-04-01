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
    override var subControllers : [ASViewController]! {
        get {
            if self.childViewControllers.indexOf(infoController) == nil {
                self.addChildViewController(infoController)
            }
            if self.childViewControllers.indexOf(tracklistController) == nil {
                self.addChildViewController(tracklistController)
            }
            return [infoController, tracklistController]
        }
    }
    
    init(stream : Stream?){
        let node = StreamVCNode()
        super.init(pagerNode: node)
        
        if let s = stream {
            self.stream = s
            self.configure(s)
        }
        
        node.nowPlayingArea.likeButton.addTarget(self, action: #selector(StreamVC.toggleTrackFav(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamViewController.userFavPlaylistUpdated(_:)), name: "UpdatedFavPlaylist", object: nil)
    }
    
    func toggleTrackFav(sender: ButtonNode) {
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
        
        updateTrack(stream)
    }
    
    func endedActiveStream(notification: NSNotification!){
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
        } else {
            if let window = self.node.view.wclWindow {
                window.dismissable = true
            }
            self.state = .Inactive
        }
        
        self.infoController.screenNode.infoNode.topSection.configure(self.stream!)
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
}

extension StreamVC : StreamerDelegate {
    func streamer(streamer: WildPlayer!, updatedToPosition position: CGFloat) {
//        Async.main {
//            (self.screenNode as! StreamVCNode).nowPlayingArea.updateProgress(position)
//        }
    }
    func streamer(streamer: WildPlayer!, updatedPlaylistIndex index: Int) {
        Async.main {
            self.updateTrack(self.stream)
        }
    }
}

extension StreamVC : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        if stream == StreamManager.sharedInstance.activeStream {
            let screenNode = (self.screenNode as! StreamVCNode)
            
            let p = POPProgress(progress, startValue: 0, endValue: window.lowerPercentage)
            let transition = POPTransition(p, startValue: 0, endValue: -screenNode.calculatedSize.height*window.lowerPercentage)
            POPLayerSetTranslationY(screenNode.nowPlayingArea.layer, transition)
        }
    }
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            AnalyticsScreen.new(node: self.currentScreen())
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
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || otherGestureRecognizer == (self.tracklistController.node as! StreamTracklistNode).tracksTable.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || otherGestureRecognizer == (self.tracklistController.node as! StreamTracklistNode).tracksTable.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}
