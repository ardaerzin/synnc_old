//
//  SearchController.swift
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

class SearchController : TabItemController {
    
    override var identifier : String! {
        return "SearchController"
    }
    override var imageName : String! {
        return "search_icon"
    }
    override var subsections : [TabSubsectionController]! {
        get {
            if _subsections == nil {
                _subsections = [SearchStreamsController(), SearchUsersController()]
            }
            return _subsections
        }
    }
    override var titleItem : ASDisplayNode! {
        get {
            if _titleItem == nil {
                let item = ASEditableTextNode()
                item.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.04)
                item.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
                item.attributedPlaceholderText = NSAttributedString(string: "Search Here", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSKernAttributeName : -0.09])
                item.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor(), NSKernAttributeName : -0.09]
                _titleItem = item
            }
            return _titleItem
        }
    }
    override var iconItem : ASDisplayNode! {
        get {
            if _iconItem == nil {
                let item = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
                item.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(34, 34))
                item.setImage(UIImage(named: "settings"), forState: ASButtonStateNormal)
                _iconItem = item
            }
            return _iconItem
        }
    }
}