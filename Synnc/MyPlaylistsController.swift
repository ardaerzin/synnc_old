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

class MyPlaylistsController : ASViewController, PagerSubcontroller {

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
        return node
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedPlaylistDataSource.allItems.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
            
            var keys : [String] = []
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