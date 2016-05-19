//
//  MyPlaylistsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import Async
import WCLNotificationManager
import WCLPopupManager
import WCLUserManager

class MyPlaylistsController : ASViewController, PagerSubcontroller {

    var actionSheet : ActionSheetPopup!
    lazy var _leftHeaderIcon : ASControlNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "magnifier-white")
        x.contentMode = .Center
        return nil
    }()
    var leftHeaderIcon : ASControlNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASControlNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "newPlaylist")
        x.contentMode = .Center
        x.addTarget(self, action: #selector(MyPlaylistsController.newPlaylistAction(_:)), forControlEvents: .TouchUpInside)
        return x
    }()
    var rightHeaderIcon : ASControlNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Playlists", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor.whiteColor().colorWithAlphaComponent(0.27), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    var selectedPlaylist : SynncPlaylist!
    var playlistController : PlaylistController!
    var screenNode : MyPlaylistsNode!

    deinit {
    }
    init(){
        let listNode = MyPlaylistsNode()
        super.init(node: listNode)
        self.screenNode = listNode
        
        if SharedPlaylistDataSource.allItems.isEmpty {
            listNode.emptyState = true
            listNode.emptyStateNode.subTextNode.addTarget(self, action: #selector(MyPlaylistsController.newPlaylistAction(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        
        SharedPlaylistDataSource.delegate = self
        
        listNode.tableNode.view.asyncDataSource = self
        listNode.tableNode.view.asyncDelegate = self
        listNode.tableNode.view.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 65))
        listNode.tableNode.view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyPlaylistsController {
    func newPlaylistAction(sender : AnyObject){
        displayPlaylist(nil)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "New Playlist", value: nil)
    }
    
    func displayPlaylist(playlist: SynncPlaylist?) {
        let vc = PlaylistController(playlist: playlist)
        let opts = WCLWindowOptions(link: false, draggable: true, dismissable: true)
        let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
        a.delegate = vc
        a.panRecognizer.delegate = vc
        a.display(true)
    }
}

extension MyPlaylistsController : ASTableViewDataSource {
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = PlaylistCellNode()
        let item = SharedPlaylistDataSource.allItems[indexPath.row]
        node.configureForPlaylist(item)
        
//        node.contentNode.infoNode.buttonNode.indexPath = indexPath
        node.contentNode.infoNode.buttonNode.addTarget(self, action: #selector(MyPlaylistsController.sector(_:)), forControlEvents: .TouchUpInside)
        return node
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedPlaylistDataSource.allItems.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func sector(sender : CellButtonNode) {
        
//        let x = sender.convertPoint(sender.position, toNode: self.screenNode)
//        let x = self.parentViewController!.view.convertPoint(sender.position, toView: self.parentViewController!.view)
//        print("ANANEN", x)
        
        
        guard let a = sender.supernode?.view.convertPoint(sender.position, toView: self.view), let ip = self.screenNode.tableNode.view.indexPathForRowAtPoint(CGPointMake(a.x, a.y + self.screenNode.tableNode.view.contentOffset.y)) else {
            return
        }
        
        if ip.item >= SharedPlaylistDataSource.allItems.count {
            return
        }

        self.displayActionSheet(ip)
    }
    
    func displayActionSheet(indexPath : NSIndexPath) {
        
        if indexPath.item >= SharedPlaylistDataSource.allItems.count {
            return
        }
        
        let playlist = SharedPlaylistDataSource.allItems[indexPath.row]
        
        var buttons : [ButtonNode] = []
        //            [streamButton, addSongsButton, editButton, deleteButton]
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        let streamButton = CellButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        streamButton.indexPath = indexPath
        streamButton.setAttributedTitle(NSAttributedString(string: "Stream", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        streamButton.minScale = 1
        streamButton.cornerRadius = 8
        streamButton.addTarget(self, action: #selector(MyPlaylistsController.streamPlaylist(_:)), forControlEvents: .TouchUpInside)
        buttons.append(streamButton)
        
        let deleteButton = CellButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        deleteButton.indexPath = indexPath
        deleteButton.setAttributedTitle(NSAttributedString(string: "Delete", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        deleteButton.minScale = 1
        deleteButton.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(MyPlaylistsController.deletePlaylist(_:)), forControlEvents: .TouchUpInside)
        
        if let fav = SharedPlaylistDataSource.findUserFavoritesPlaylist() where playlist != fav {
            buttons.append(deleteButton)
        }
        
        actionSheet = ActionSheetPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 200), buttons : buttons)
        
        Async.main {
            Synnc.sharedInstance.topPopupManager.newPopup(self.actionSheet)
        }
    }
    
    func streamPlaylist(sender : CellButtonNode) {
        if let s = actionSheet {
            s.closeView(true)
        }
        
        guard let indexPath = sender.indexPath else {
            return
        }
        
        if indexPath.item >= SharedPlaylistDataSource.allItems.count {
            return
        }
        
        let plist = SharedPlaylistDataSource.allItems[indexPath.row]
        
        AnalyticsEvent.new(category : "MyPlaylistsAction", action: "button_tap", label: "stream", value: nil)
        
        if StreamManager.sharedInstance.activeStream != nil {
            
            let x = StreamInProgressPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200), playlist: nil)
//            x.callback = self.streamPlaylist
            WCLPopupManager.sharedInstance.newPopup(x)
            
            return
        }
        
        let t = plist.canPlay()
        
        if t.status {
            StreamManager.sharedInstance.createStreamWindow(plist).display(true)
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
                    
                    notificationMessage = ("Please login to \(str.fixAppleMusic()) to listen to the Premium content in this stream.","login")
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
            
            if let missingInfo = dict["missingInfo"] as? [String] {
                
                notificationMessage = ("First, add songs to your playlist", "add songs")
                notificationAction = {
                    [weak self]
                    notif in
                    
                    if self == nil {
                        return
                    }
                    
                    self?.displayPlaylist(plist)
                }
                
            }
            
            if let msg = notificationMessage {
                Async.main {
                    WCLNotification(body: msg, image: "notification-error", callback: notificationAction).addToQueue()
                }
                return
            }
        }
        
    }
    
    func deletePlaylist(sender : CellButtonNode) {
        
        if let s = actionSheet {
            s.closeView(true)
        }
        
        guard let indexPath = sender.indexPath else {
            return
        }
        
        if indexPath.item >= SharedPlaylistDataSource.allItems.count {
            return
        }
        
        let playlist = SharedPlaylistDataSource.allItems[indexPath.row]
        
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == playlist {
            
            Async.main {
                WCLNotification(body: ("You can't delete your active stream.", "can't delete"), image: "notification-error").addToQueue()
            }
            
            return
        }
        
        let x = DeletePlaylistPopup(playlist : playlist, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
        Async.main {
            WCLPopupManager.sharedInstance.newPopup(x)
        }
    }
}

extension MyPlaylistsController : ASTableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item >= SharedPlaylistDataSource.allItems.count {
            return
        }
        self.screenNode.userInteractionEnabled = false
        let playlist = SharedPlaylistDataSource.allItems[indexPath.item]
        self.displayPlaylist(playlist)
        AnalyticsEvent.new(category : "ui_action", action: "cell_tap", label: "playlist", value: nil)
    }
}

//extension MyPlaylistsController : ASCollectionDelegate {
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let playlist = SharedPlaylistDataSource.allItems[indexPath.item]
//        self.selectedPlaylist = playlist
//        self.displayPlaylist(playlist)
//        AnalyticsEvent.new(category : "ui_action", action: "playlist_tap", label: nil, value: nil)
//    }
//}

extension MyPlaylistsController : PlaylistsDataSourceDelegate {
    func playlistsDataSource(addedItem item: SynncPlaylist, newIndexPath indexPath: NSIndexPath) {
        
        self.screenNode.tableNode.view.beginUpdates()
        self.screenNode.tableNode.view.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.screenNode.tableNode.view.endUpdates()
        updatedPlaylists()
    }
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath) {
        
        self.screenNode.tableNode.view.beginUpdates()
        self.screenNode.tableNode.view.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.screenNode.tableNode.view.endUpdates()
        updatedPlaylists()
    }
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath: NSIndexPath) {
        
        if let stream = StreamManager.sharedInstance.activeStream where stream.playlist == item {
            
//            var keys : [String] = []
//            if stream.name != item.name {
//                keys.append("name")
//            }
            StreamManager.sharedInstance.updatedStreamLocally(stream, changedKeys: ["playlist"])
        }
        
        self.screenNode.tableNode.view.beginUpdates()
        self.screenNode.tableNode.view.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.screenNode.tableNode.view.endUpdates()
        updatedPlaylists()
    }
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        
        self.screenNode.tableNode.view.beginUpdates()
        self.screenNode.tableNode.view.moveRowAtIndexPath(indexPath, toIndexPath: newIndexPath)
        self.screenNode.tableNode.view.endUpdates()
        updatedPlaylists()
    }
    
    func updatedPlaylists(){
        if SharedPlaylistDataSource.allItems.isEmpty {
            self.screenNode.emptyState = true
        } else {
            self.screenNode.emptyState = false
        }
    }
}