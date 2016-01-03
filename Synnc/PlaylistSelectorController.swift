//
//  PlaylistSelectorController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/31/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

protocol PlaylistSelectorDelegate {
    func didSelectPlaylist(playlist : SynncPlaylist)
}
class PlaylistSelectorController : TabSubsectionController {
    
    var selectedIndexPath : NSIndexPath! {
        didSet {
//            if selectedIndexPath != oldValue {
//            print("did change selected indexpath")
            selectedPlaylist = playlistDataSource.allItems[selectedIndexPath.item]
            if let node = (self.screenNode.view as! ASCollectionView).nodeForItemAtIndexPath(selectedIndexPath) as? PlaylistCellNode {
                node.isSelected = true
            }
            if let oldIp = oldValue, let oldNode = (self.screenNode.view as! ASCollectionView).nodeForItemAtIndexPath(oldIp) as? PlaylistCellNode {
                oldNode.isSelected = false
            }
        }
    }
    var delegate : PlaylistSelectorDelegate?
    var playlistDataSource : PlaylistsDataSource! = PlaylistsDataSource()
    var selectedPlaylist : SynncPlaylist! {
        didSet {
            if selectedPlaylist != oldValue {
                self.delegate?.didSelectPlaylist(selectedPlaylist)
            }
        }
    }
    
    override var _title : String! {
        return "My Playlists"
    }
    deinit {
        print("ADHSAKDAS")
    }
    override init(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let listNode = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: listNode)
        self.screenNode = listNode
        
        if playlistDataSource.allItems.isEmpty {
            let s = self.screenNode as! MyPlaylistsNode
            s.emptyState = true
            s.emptyStateNode.subTextNode.addTarget(self, action: Selector("newPlaylistAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        playlistDataSource.delegate = self
        
        listNode.view.scrollEnabled = false
        listNode.view.asyncDataSource = self
        listNode.view.asyncDelegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistSelectorController : ASCollectionViewDataSource {
    func collectionView(collectionView: ASCollectionView!, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath!) -> ASSizeRange {
        let x = collectionView.bounds.width / 2
        return ASSizeRangeMake(CGSize(width: x, height: x), CGSize(width: x, height: x))
    }
    func collectionView(collectionView: ASCollectionView!, nodeForItemAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let node = PlaylistCellNode()
        let item = playlistDataSource.allItems[indexPath.row]
        node.configureForPlaylist(item)
        return node
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return playlistDataSource.allItems.count
    }
}
extension PlaylistSelectorController : ASCollectionViewDelegate {
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView!) -> Bool {
        return false
    }
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
//        let playlist = playlistDataSource.allItems[indexPath.item]
        self.selectedIndexPath = indexPath
        
//        self.selectedPlaylist = playlist
//        self.delegate?.didSelectPlaylist(playlist)
//        if let node = (collectionView as! ASCollectionView).nodeForItemAtIndexPath(indexPath) as? PlaylistCellNode {
//            node.isSelected = true
//        }
    }
    func collectionView(collectionView: ASCollectionView!, willDisplayNodeForItemAtIndexPath indexPath: NSIndexPath!) {
////        let item = playlistDataSource.allItems[indexPath.row]
        if indexPath.item == 0 && self.selectedPlaylist == nil {
            self.selectedIndexPath = indexPath
            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
//        if let sp = self.selectedIndexPath where indexPath == sp {
//            
//        } else {
//            
//        }
//        
//        if indexPath == self.selectedIndexPath {
//            if let node = collectionView.nodeForItemAtIndexPath(indexPath) as? PlaylistCellNode {
//                node.isSelected = true
//            }
//            else {
//                node.isSelected = false
//            }
//        }
////            collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
////        } else {
////            collectionView.deselectItemAtIndexPath(indexPath, animated: false)
////            if let node = collectionView.nodeForItemAtIndexPath(indexPath) as? PlaylistCellNode {
////                node.isSelected = false
////                node.selected = false
////                print(node)
////            }
////        }
    }
}

extension PlaylistSelectorController : PlaylistsDataSourceDelegate {
    func playlistsDataSource(addedItem item: SynncPlaylist, newIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! ASCollectionNode).view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.insertItemsAtIndexPaths([indexPath])
            }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! ASCollectionNode).view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.deleteItemsAtIndexPaths([indexPath])
            }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! ASCollectionNode).view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.reloadItemsAtIndexPaths([indexPath])
            }, completion: nil)
        updatedPlaylists()
    }
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        let collectionNode = (self.screenNode as! ASCollectionNode).view
        collectionNode.performBatchAnimated(true, updates: {
            collectionNode.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
            }, completion: nil)
        updatedPlaylists()
    }
    
    func updatedPlaylists(){
//        if SharedPlaylistDataSource.allItems.isEmpty {
//        } else {
//            (self.screenNode as! MyPlaylistsNode).emptyState = false
//        }
    }
}