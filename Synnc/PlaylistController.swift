//
//  CreatePlaylistController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/13/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
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
import DKImagePickerController

class PlaylistController : PagerBaseController {
    
    var isNewPlaylist : Bool = false
    var playlist : SynncPlaylist!
    var needsToShowTrackSearch : Bool = false
    
    lazy var infoController : PlaylistInfoController = {
        return PlaylistInfoController(playlist: self.playlist)
    }()
    lazy var tracklistController : PlaylistTracklistController = {
        return PlaylistTracklistController()
    }()
    override var subControllers : [ASViewController]! {
        get {
            if self.childViewControllers.indexOf(infoController) == nil {
                self.addChildViewController(infoController)
            }
            if self.childViewControllers.indexOf(tracklistController) == nil {
                self.addChildViewController(tracklistController)
            }
            tracklistController.screenNode.infoDelegate = infoController
            return [infoController, tracklistController]
        }
    }
    
    deinit {
    }
    
    init(playlist : SynncPlaylist?){
        let node = PlaylistBaseNode()
        super.init(pagerNode: node)
        
        if playlist == nil {
            self.playlist = SynncPlaylist.create(inContext: Synnc.sharedInstance.moc) as! SynncPlaylist
            self.playlist.user = Synnc.sharedInstance.user._id
            isNewPlaylist = true
        } else {
            self.playlist = playlist
        }
        
        node.streamButtonHolder.streamButton.addTarget(self, action: #selector(PlaylistController.streamPlaylist(_:)) , forControlEvents: .TouchUpInside)
        
        if let fav = SharedPlaylistDataSource.findUserFavoritesPlaylist() where playlist == fav {
            self.infoController.screenNode.infoNode.titleNode.userInteractionEnabled = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let window = self.view.wclWindow {
            window.panRecognizer.delegate = self
        }
    }
    
    func deleteAction(sender : AnyObject){
        var plist = self.playlist
        let json = plist.toJSON(nil, populate: true)
        Async.background {
            Async.main {
                Synnc.sharedInstance.socket.emit("SynncPlaylist:delete", json)
            }
        }
        if let window = self.view.wclWindow {
            window.hide(true)
        }
        playlist.delete()
        self.playlist = nil
    }
    
    func addSongs(sender : AnyObject) {
        print("add songs")
        needsToShowTrackSearch = true
        self.screenNode.pager.scrollToPageAtIndex(1, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        if self.currentIndex == 1 && needsToShowTrackSearch {
            self.tracklistController.displayTrackSearch(nil)
            needsToShowTrackSearch = false
        }
    }
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        if self.currentIndex == 1 && needsToShowTrackSearch {
            self.tracklistController.displayTrackSearch(nil)
            needsToShowTrackSearch = false
        }
    }
}

extension PlaylistController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let ip = self.infoController.imagePicker {
            return false
        }
        if otherGestureRecognizer == self.screenNode.pager.view.panGestureRecognizer {
            return false
        }
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.tracklistController.editMode {
            return true
        }
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || (otherGestureRecognizer == self.tracklistController.screenNode.tracksTable.view.panGestureRecognizer && !self.tracklistController.editMode){
            return true
        } else {
            return false
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ip = self.infoController.imagePicker {
            return false
        }
        if self.tracklistController.editMode {
            return true
        }
        if otherGestureRecognizer == self.infoController.screenNode.infoNode.view.panGestureRecognizer || (otherGestureRecognizer == self.tracklistController.screenNode.tracksTable.view.panGestureRecognizer && !self.tracklistController.editMode) {
            return true
        } else {
            return false
        }
    }
}

extension PlaylistController {
    func streamPlaylist(sender: AnyObject) {
        
        AnalyticsEvent.new(category : "PlaylistAction", action: "button_tap", label: "stream", value: nil)
        
        if let stream = StreamManager.sharedInstance.activeStream {
            
            let x = StreamInProgressPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200), playlist: nil)
            WCLPopupManager.sharedInstance.newPopup(x)
            
            return
        }
        
        if self.playlist.songs.isEmpty {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                
                let info = WCLNotificationInfo(defaultActionName: "", body: "First, add songs to your playlist", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                        [weak self]
                        notif in
                        
                        if self == nil {
                            return
                        }
                    
                        AnalyticsEvent.new(category : "ui_action", action: "notification_tap", label: "Empty Playlist Notification", value: nil)
                    
                        self!.screenNode.pager.scrollToPageAtIndex(1, animated: true)
                }
                WCLNotificationManager.sharedInstance().newNotification(a, info: info)
            }
            return
        }
        
        
        if self.playlist.name == nil || self.playlist.name == "" {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                
                let info = WCLNotificationInfo(defaultActionName: "", body: "You need to name your playlist before sharing it with others.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                    [weak self]
                    notif in
                    
                    if self == nil {
                        return
                    }
                    
                    AnalyticsEvent.new(category : "ui_action", action: "notification_tap", label: "Empty Playlist Name Notification", value: nil)
                    
                    self!.screenNode.pager.scrollToPageAtIndex(0, animated: true)
                }
                WCLNotificationManager.sharedInstance().newNotification(a, info: info)
            }
            return
        }
        
        if self.infoController.uploadingImage {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Image upload in progress. Try again once it is finished", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
            }
            return
        }
        
        
        let stream = Stream(user: Synnc.sharedInstance.user)
        stream.playlist = playlist
        stream.lat = 0
        stream.lon = 0
        if let name = playlist.name {
            stream.name = name
        }
        if let coverid = playlist.cover_id {
            stream.img = coverid
        }
        if let location = playlist.location {
            stream.city = location
        }
        Synnc.sharedInstance.streamManager.userStream = stream
        let vc = StreamVC(stream: stream)
        
        let opts = WCLWindowOptions(link: false, draggable: true, limit: UIScreen.mainScreen().bounds.height - 70, dismissable: true)
        let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
        a.delegate = vc
        a.panRecognizer.delegate = vc
        a.clipsToBounds = false
        stream.createCallback = {
            created in
            if StreamManager.canSetActiveStream(stream) {
                if stream == StreamManager.sharedInstance.userStream {
                    StreamManager.setActiveStream(stream)
                    StreamManager.playStream(stream)
                }
            }
        }
        stream.update([NSObject : AnyObject]())
//        let stream = Stream.create(self.playlist) {
//            created in
//            
//            if created {
//                vc.createdStream()                
//            }
//        }
        a.display(true)
    }
}

extension PlaylistController : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
        if isNewPlaylist {
            let vals = self.playlist.changedValues().keys
            if vals.indexOf("songs") == nil && vals.indexOf("name") == nil && vals.indexOf("cover_id") == nil {
                playlist.delete()
            }
        }
    }
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            AnalyticsScreen.new(node: self.currentScreen())
        }
    }
}