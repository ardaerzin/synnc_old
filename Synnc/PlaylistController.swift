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

class PlaylistController : PagerBaseController {
    
    var isNewPlaylist : Bool = false
    var playlist : SynncPlaylist!
    
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PlaylistController {
    func streamPlaylist(sender: AnyObject) {
        
        AnalyticsEvent.new(category : "PlaylistAction", action: "button_tap", label: "stream", value: nil)
        
        if self.playlist.songs.isEmpty {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                
                let info = WCLNotificationInfo(defaultActionName: "", body: "First, add songs to your playlist", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                        [weak self]
                        notif in
                        
                        if self == nil {
                            return
                        }
                        
                        self!.screenNode.pager.scrollToPageAtIndex(1, animated: true)
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
        
        let vc = StreamVC()
        let opts = WCLWindowOptions(link: false, draggable: true, limit: 300, dismissable: true)
        let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
        
        let stream = Stream.create(self.playlist) {
            created in
            
            if created {
                vc.createdStream()                
            }
        }
        vc.stream = stream
        
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
}