
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
            
            if let sip = selectedIndexPath, let ov = oldValue where sip == ov {
                return
            }
            
            if selectedIndexPath == nil {
                if let oldIp = oldValue, let oldNode = (self.screenNode.view as! ASCollectionView).nodeForItemAtIndexPath(oldIp) as? SelectablePlaylistCellNode {
                    oldNode.isSelected = false
                }
                return
            }
            
            selectedPlaylist = nil
            selectedPlaylist = playlistDataSource.allItems[selectedIndexPath.item]
            
            if let node = (self.screenNode.view as! ASCollectionView).nodeForItemAtIndexPath(selectedIndexPath) as? SelectablePlaylistCellNode {
                node.isSelected = true
            }
            if let oldIp = oldValue, let oldNode = (self.screenNode.view as! ASCollectionView).nodeForItemAtIndexPath(oldIp) as? SelectablePlaylistCellNode {
                oldNode.isSelected = false
            }
        }
    }
    var delegate : PlaylistSelectorDelegate? {
        didSet {
            if let plist = selectedPlaylist {
                print(plist)
                self.delegate?.didSelectPlaylist(plist)
            }
        }
    }
    var playlistDataSource : PlaylistsDataSource!
    var selectedPlaylist : SynncPlaylist! {
        didSet {
            if selectedPlaylist != nil && selectedPlaylist != oldValue {
                self.delegate?.didSelectPlaylist(selectedPlaylist)
            }
        }
    }
    weak var plist : SynncPlaylist?
    deinit {
        print("ADHSAKDAS")
    }
    init(playlist : SynncPlaylist? = nil){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
//        self.plist = playlist
        self.selectedPlaylist = playlist
        
        playlistDataSource = SelectablePlaylistsDataSource(predicates:
            [
                NSPredicate(format: "user == %@", Synnc.sharedInstance.user._id, NSNull()),
                NSPredicate(format: "id != %@", NSNull())
            ], type: NSCompoundPredicateType.AndPredicateType)
        
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistSelectorController : ASCollectionDataSource {
    func collectionView(collectionView: ASCollectionView, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> ASSizeRange {
        let x = collectionView.bounds.width / 2
        return ASSizeRangeMake(CGSize(width: x, height: x), CGSize(width: x, height: x))
    }
    func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = SelectablePlaylistCellNode()
        let item = playlistDataSource.allItems[indexPath.row]
        node.configureForPlaylist(item)
        return node
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlistDataSource.allItems.count
    }
}
extension PlaylistSelectorController : ASCollectionDelegate {
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView) -> Bool {
        return false
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = nil
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
    }
    func collectionView(collectionView: ASCollectionView, willDisplayNodeForItemAtIndexPath indexPath: NSIndexPath) {
        
        let ind = indexPath.item
        if self.selectedPlaylist != nil {
            if ind < playlistDataSource.allItems.count && playlistDataSource.allItems[ind] == self.selectedPlaylist {
                self.selectedIndexPath = indexPath
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        } else {
            if ind == 0 {
                self.selectedIndexPath = indexPath
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        }
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
    }
}