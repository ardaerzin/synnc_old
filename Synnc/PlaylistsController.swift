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
                item.setImage(UIImage(named: "add_playlist")?.resizeImage(usingWidth: 20), forState: ASButtonStateNormal)
                _iconItem = item
            }
            return _iconItem
        }
    }
}