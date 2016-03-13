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

class MyPlaylistsController : TabSubsectionController {

    var selectedPlaylist : SynncPlaylist!
    var playlistController : PlaylistController!
    
    override var _title : String! {
        return "My Playlists"
    }
    deinit {
    }
    override init(){
        let listNode = MyPlaylistsNode()
        super.init(node: listNode)
        self.screenNode = listNode
        
        if SharedPlaylistDataSource.allItems.isEmpty {
            let s = self.screenNode as! MyPlaylistsNode
            s.emptyState = true
            s.emptyStateNode.subTextNode.addTarget(self, action: Selector("newPlaylistAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        
        let nn = self.screenNode as! MyPlaylistsNode
        nn.collectionNode.view.asyncDataSource = self
        nn.collectionNode.view.asyncDelegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyPlaylistsController {
    func displayPlaylist(playlist: SynncPlaylist?){
        self.playlistController = PlaylistController(playlist: playlist)
        self.navigationController?.pushViewController(self.playlistController, animated: true)
    }
    func newPlaylistAction(sender : AnyObject){
        self.displayPlaylist(nil)
        
        if let _ = sender as? ASTextNode {
            AnalyticsEvent.new(category : "ui_action", action: "newPlaylist", label: "textButton", value: nil)
        } else {
            AnalyticsEvent.new(category : "ui_action", action: "newPlaylist", label: "topButton", value: nil)
        }
    }
}


extension MyPlaylistsController : ASCollectionDataSource {
    func collectionView(collectionView: ASCollectionView, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath)-> ASSizeRange {
        let x = collectionView.bounds.width / 2
        return ASSizeRangeMake(CGSize(width: x, height: x), CGSize(width: x, height: x))
    }
    func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = PlaylistCellNode()
        let item = SharedPlaylistDataSource.allItems[indexPath.row]
        node.configureForPlaylist(item)
        return node
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedPlaylistDataSource.allItems.count
    }
}
extension MyPlaylistsController : ASCollectionDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let playlist = SharedPlaylistDataSource.allItems[indexPath.item]
        self.selectedPlaylist = playlist
        self.displayPlaylist(playlist)
        AnalyticsEvent.new(category : "ui_action", action: "playlist_tap", label: nil, value: nil)
    }
}

extension MyPlaylistsController : PlaylistsDataSourceDelegate {
    func playlistsDataSource(addedItem item: SynncPlaylist, newIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! MyPlaylistsNode).collectionNode.view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.insertItemsAtIndexPaths([indexPath])
        }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! MyPlaylistsNode).collectionNode.view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.deleteItemsAtIndexPaths([indexPath])
        }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! MyPlaylistsNode).collectionNode.view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.reloadItemsAtIndexPaths([indexPath])
        }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! MyPlaylistsNode).collectionNode.view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
            }, completion: nil)
        updatedPlaylists()
    }
    
    func updatedPlaylists(){
        if SharedPlaylistDataSource.allItems.isEmpty {
            (self.screenNode as! MyPlaylistsNode).emptyState = true
        } else {
            (self.screenNode as! MyPlaylistsNode).emptyState = false
        }
        
        if let x = self.playlistController {
            x.updatedPlaylist()
        }
    }
}