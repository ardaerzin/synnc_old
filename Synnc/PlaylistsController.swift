//
//  PlaylistsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/11/15.
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

class PlaylistsController : TabItemController {

    override var identifier : String! {
        return "PlaylistsController"
    }
    override var imageName : String! {
        return "playlists_icon"
    }
    
    override var subsections : [TabSubsectionController]! {
        get {
            if _subsections == nil {
                _subsections = [MyPlaylistsController(), ImportPlaylistsController()]
            }
            return _subsections
        }
    }
    override var titleItem : ASDisplayNode! {
        get {
            if _titleItem == nil {
                let item = ASTextNode()
                item.attributedString = NSAttributedString(string: "Playlists", attributes: self.titleAttributes)
                _titleItem = item
            }
            return _titleItem
        }
    }
    override var iconItem : ASDisplayNode! {
        get {
            if _iconItem == nil {
                let item = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
                item.imageNode.contentMode = UIViewContentMode.ScaleAspectFit
                item.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(34, 34))
                item.setImage(UIImage(named: "addPlaylist"), forState: ASControlState.Normal)
                item.addTarget(self.myPlaylistsController, action: Selector("newPlaylistAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
                
                _iconItem = item
            }
            return _iconItem
        }
    }
    
    var myPlaylistsController : MyPlaylistsController! {
        return self.subsections[0] as! MyPlaylistsController
    }
    override init(){
        let node = NavigationHolderNode()
        super.init(node: node)
    }
    override func willBecomeActiveTab() {
        super.willBecomeActiveTab()
        SharedPlaylistDataSource.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistsController : PlaylistsDataSourceDelegate {
    func playlistsDataSource(addedItem item: SynncPlaylist, newIndexPath indexPath: NSIndexPath) {
        myPlaylistsController.playlistsDataSource(addedItem: item, newIndexPath: indexPath)
    }
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath) {
        myPlaylistsController.playlistsDataSource(removedItem: item, fromIndexPath: indexPath)
    }
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath: NSIndexPath) {
        myPlaylistsController.playlistsDataSource(updatedItem: item, atIndexPath: indexPath)
    }
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {
        myPlaylistsController.playlistsDataSource(movedItem: item, fromIndexPath: indexPath, toIndexPath: newIndexPath)
    }
}