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
import Async

class PlaylistController : PagerBaseController {
    
    var isNewPlaylist : Bool = false
    var playlist : SynncPlaylist!
    var needsToShowTrackSearch : Bool = false
    var actionSheet : ActionSheetPopup!
    
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
        node.streamButtonHolder.submenuButton.addTarget(self, action: #selector(PlaylistController.displaySubmenu(_:)), forControlEvents: .TouchUpInside)
        
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
        
        (self.screenNode.headerNode as! PlaylistHeaderNode).toggleButton.addTarget(self, action: #selector(PlaylistController.toggleWindowPosition(_:)), forControlEvents: .TouchUpInside)
        (self.screenNode.headerNode as! PlaylistHeaderNode).tracksearchButton.addTarget(self, action: #selector(PlaylistController.addSongs(_:)), forControlEvents: .TouchUpInside)
    }
    
    func displaySubmenu(sender : AnyObject){
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        let deleteButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        deleteButton.setAttributedTitle(NSAttributedString(string: "Delete", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        deleteButton.minScale = 1
        deleteButton.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(PlaylistController.deletePlaylist(_:)), forControlEvents: .TouchUpInside)
        
        let editButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        editButton.setAttributedTitle(NSAttributedString(string: "Edit Tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        editButton.minScale = 1
        editButton.cornerRadius = 8
        editButton.addTarget(self, action: #selector(PlaylistController.toggleEditMode(_:)), forControlEvents: .TouchUpInside)
        
        let streamButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        streamButton.setAttributedTitle(NSAttributedString(string: "Stream", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        streamButton.minScale = 1
        streamButton.cornerRadius = 8
        streamButton.addTarget(self, action: #selector(PlaylistController.streamPlaylist(_:)), forControlEvents: .TouchUpInside)
        
        let addSongsButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        addSongsButton.setAttributedTitle(NSAttributedString(string: "Add Tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        addSongsButton.minScale = 1
        addSongsButton.cornerRadius = 8
        addSongsButton.addTarget(self, action: #selector(PlaylistController.addSongs(_:)), forControlEvents: .TouchUpInside)
        
        let buttons = [streamButton, addSongsButton, editButton, deleteButton]
        
        actionSheet = ActionSheetPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 200), buttons : buttons)
        actionSheet.onCancel = {
            if let node = sender as? ButtonNode {
                node.userInteractionEnabled = true
                node.hideSpinView()
            }
        }
        
        Synnc.sharedInstance.topPopupManager.newPopup(self.actionSheet)
    }
    
    func toggleWindowPosition(sender : AnyObject) {
        if let w = self.view.wclWindow {
            if w.position == .Displayed {
                w.hide(true)
            } else {
                w.display(true)
            }
        }
    }
    
    func addSongs(sender : AnyObject) {
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
        if !self.tracklistController.canDisplayTrackSearch() {
            Async.main {
                WCLNotification(body: ("You can't edit your active playlist.", "can't edit"), image: "notification-error").addToQueue()
            }
            return
        }

        if self.currentIndex != 1 {
            needsToShowTrackSearch = true
            self.screenNode.pager.scrollToPageAtIndex(1, animated: true)
        } else {
            self.tracklistController.displayTrackSearch(nil)
        }
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "trackSearch 2", value: nil)
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
    
    override func updatedPagerPosition(position: CGFloat) {
        super.updatedPagerPosition(position)
        
        let a = (self.screenNode.headerNode as! PlaylistHeaderNode).toggleButton
        let x = a.position.x + a.calculatedSize.width / 2
        
        if position >= 1 - (x / self.screenNode.pager.calculatedSize.width) {
            (self.screenNode.headerNode as! PlaylistHeaderNode).toggleButton.setColor(.whiteColor())
        } else {
            (self.screenNode.headerNode as! PlaylistHeaderNode).toggleButton.setColor(UIColor(red: 154/255, green: 154/255, blue: 154/255, alpha: 1))
        }
        
        let b = (self.screenNode.headerNode as! PlaylistHeaderNode).tracksearchButton
        let y = b.position.x
        
        if position >= 1 - (y / self.screenNode.pager.calculatedSize.width) {
            b.setImage(UIImage(named: "newPlaylist"), forState: .Normal)
        } else {
            b.setImage(UIImage(named: "newPlaylist-dark"), forState: .Normal)
        }
    }
}

extension PlaylistController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if self.infoController.imagePicker != nil {
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
        
        if self.infoController.imagePicker != nil {
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
    func streamPlaylist(sender: AnyObject!) {
        
        if let s = actionSheet {
            s.closeView(true)
        }

        guard let plist = self.playlist else {
            return
        }
        
        AnalyticsEvent.new(category : "PlaylistAction", action: "button_tap", label: "stream", value: nil)
        
        if StreamManager.sharedInstance.activeStream != nil {
            
            let x = StreamInProgressPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200), playlist: nil)
            x.callback = self.streamPlaylist
            WCLPopupManager.sharedInstance.newPopup(x)
            
            return
        }
        
        let t = plist.canPlay()
        
        if t.status {
            createStream(plist)
        } else {

            guard let dict = t.reasonDict else {
                return
            }
            
            var notificationMessage : (String,String)?
            var notificationAction : ((notif: WCLNotification) -> Void)?
            
            if let missingSources = dict["missingSources"] as? [String] where !missingSources.isEmpty {
                if missingSources.count > 1 {
                    //multiple
                    
                    var str : String = ""
                    
                    for (index,src) in missingSources.enumerate() {
                        str += index == 0 ? "\(src)" : index == missingSources.count - 1 ? " and \(src)" : ", \(src)"
                    }
                    
                    notificationMessage = ("Please login to \(str.fixAppleMusic()) to listen to the Premium content in this stream.","\(str.fixAppleMusic())")
                    notificationAction = nil
                    
                } else if let src = missingSources.first {
                    
                    let str = src.fixAppleMusic()
                    notificationMessage = ("Please login to \(str) to listen to the Premium content in this stream.", "\(str)")
                    notificationAction = {
                        notif in
                        if let type = WCLUserLoginType(rawValue: src.lowercaseString) {
                            Synnc.sharedInstance.user.socialLogin(type)
                        }
                    }
                }
            }
            
            if let missingInfo = dict["missingInfo"] as? [String] {
                
                if missingInfo.indexOf("songs") != nil {

                    notificationMessage = ("First, add songs to your playlist", "add songs")
                    notificationAction = {
                        [weak self]
                        notif in
                        
                        if self == nil {
                            return
                        }
                        
                        AnalyticsEvent.new(category : "ui_action", action: "notification_tap", label: "Empty Playlist Notification", value: nil)
                        
                        self!.screenNode.pager.scrollToPageAtIndex(1, animated: true)
                    }
                }
                
                if missingInfo.indexOf("name") != nil {
                    
                    notificationMessage = ("You need to name your playlist before sharing it with others.", "name")
                    notificationAction = {
                        [weak self]
                        notif in
                        
                        if self == nil {
                            return
                        }
                        
                        AnalyticsEvent.new(category : "ui_action", action: "notification_tap", label: "Empty Playlist Name Notification", value: nil)
                        
                        self!.screenNode.pager.scrollToPageAtIndex(0, animated: true)
                    }
                }
                
            }
            
            if let msg = notificationMessage {
                WCLNotification(body: msg, image: "notification-error", callback: notificationAction).addToQueue()
                return
            }
        }
    }
    
    internal func createStream(playlist: SynncPlaylist) {
        let stream = Stream(user: Synnc.sharedInstance.user)
        stream.playlist = playlist
        stream.lat = 0
        stream.lon = 0
        Synnc.sharedInstance.streamManager.userStream = stream
        let vc = StreamVC(stream: stream)
        
        let opts = WCLWindowOptions(link: false, draggable: true, limit: UIScreen.mainScreen().bounds.height, dismissable: true)
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
        a.onDisplay = {
            [weak self] in
            
            if self == nil {
                return
            }
            
            if let window = self!.view.wclWindow {
                window.hide(true)
            }
        }
        stream.update([NSObject : AnyObject]())
        a.display(true)
    }
}

extension PlaylistController : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
        if let p = playlist where isNewPlaylist {
            let vals = p.changedValues().keys
            if vals.indexOf("songs") == nil && vals.indexOf("name") == nil && vals.indexOf("cover_id") == nil && vals.indexOf("songs") == nil {
                p.delete()
            }
        }
    }
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        let x = 1-window.lowerPercentage
        let za = (1 - progress - x) / (1-x)
        
        (self.screenNode.headerNode as! PlaylistHeaderNode).toggleButton.progress = za
        self.screenNode.headerNode.leftButtonHolder.alpha = za
        self.screenNode.headerNode.rightButtonHolder.alpha = za
        self.screenNode.headerNode.pageControl.alpha = za
        
        let z = POPTransition(za, startValue: 10, endValue: 0)
        POPLayerSetTranslationY(self.screenNode.headerNode.titleHolder.layer, z)
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            AnalyticsScreen.new(node: self.currentScreen())
        }
    }
}

extension PlaylistController {
    
    func deletePlaylist(sender : AnyObject) {
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == self.playlist {
            
            Async.main {
                WCLNotification(body: ("You can't delete your active stream.", "can't delete"), image: "notification-error").addToQueue()
            }
            
            return
        }
        
        let x = DeletePlaylistPopup(playlist : self.playlist!, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
        x.screenNode.yesButton.addTarget(self, action: #selector(PlaylistController.deleteAction(_:)), forControlEvents: .TouchUpInside)
        WCLPopupManager.sharedInstance.newPopup(x)
    }
    
    func deleteAction(sender : AnyObject){
        
        let plist = self.playlist
        let json = plist.toJSON(nil, populate: true)
        
        playlist.delete()
        self.playlist = nil
        Async.background {
            Async.main {
                Synnc.sharedInstance.socket.emit("SynncPlaylist:delete", json)
            }
        }
        if let window = self.view.wclWindow {
            window.hide(true)
        }
    }
    
    func toggleEditMode(sender : ButtonNode) {
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
        
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == self.playlist {
            
            Async.main {
                WCLNotification(body: ("You can't edit your active stream.", "can't edit"), image: "notification-error").addToQueue()
            }
            
            return
        }
        
        if self.currentIndex != 1 {
            self.screenNode.pager.scrollToPageAtIndex(1, animated: true)
        }
        sender.selected = !sender.selected
        self.tracklistController.editMode = !self.tracklistController.editMode
    }
}