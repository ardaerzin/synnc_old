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

    lazy var _leftHeaderIcon : ASImageNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "magnifier-white")
        x.contentMode = .Center
        return x
    }()
    var leftHeaderIcon : ASImageNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASImageNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "newPlaylist")
        x.contentMode = .Center
        x.addTarget(self, action: #selector(MyPlaylistsController.newPlaylistAction(_:)), forControlEvents: .TouchUpInside)
        return x
    }()
    var rightHeaderIcon : ASImageNode! {
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
    func displayPlaylist(playlist: SynncPlaylist?){
//        self.playlistController = PlaylistController(playlist: playlist)
//        self.navigationController?.pushViewController(self.playlistController, animated: true)
    }
    
    func newPlaylistAction(sender : AnyObject){
        
        print("NEW PLAYLIST ACTION")
        
        let vc = PlaylistController()
        let opts = WCLWindowOptions(link: false, draggable: true, dismissable : true)
        
        let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
//        a.delegate = vc
        a.roundCorners([UIRectCorner.TopLeft, UIRectCorner.TopRight], radius: 10)
//        a.animation.toValue = a.lowerPercentage
        a.display(true)
        
//        self.displayPlaylist(nil)
//        if let _ = sender as? ASTextNode {
//            AnalyticsEvent.new(category : "ui_action", action: "newPlaylist", label: "textButton", value: nil)
//        } else {
//            AnalyticsEvent.new(category : "ui_action", action: "newPlaylist", label: "topButton", value: nil)
//        }
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
        print("did select shit")
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
//        let collectionNode = self.screenNode.tableNode.view
//        collectionNode.performBatchAnimated(true, updates: {
//            collectionNode.insertItemsAtIndexPaths([indexPath])
//        }, completion: nil)
//        updatedPlaylists()
    }
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath) {
//        let collectionNode = self.screenNode.tableNode.view
//        collectionNode.performBatchAnimated(true, updates: {
//            collectionNode.deleteItemsAtIndexPaths([indexPath])
//        }, completion: nil)
//        updatedPlaylists()
    }
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath: NSIndexPath) {
//        let collectionNode = self.screenNode.tableNode.view
        
//        collectionNode.performBatchAnimated(true, updates: {
//            collectionNode.reloadItemsAtIndexPaths([indexPath])
//        }, completion: nil)
//        updatedPlaylists()
    }
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
//        let collectionNode = self.screenNode.tableNode.view
//        collectionNode.performBatchAnimated(true, updates: {
//            collectionNode.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
//            }, completion: nil)
//        updatedPlaylists()
    }
    
    func updatedPlaylists(){
        if SharedPlaylistDataSource.allItems.isEmpty {
            self.screenNode.emptyState = true
        } else {
            self.screenNode.emptyState = false
        }
        
//        if let x = self.playlistController {
//            x.updatedPlaylist()
//        }
    }
}