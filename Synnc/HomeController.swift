//
//  HomeController.swift
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

class HomeController : TabItemController {

    override var identifier : String! {
        return "HomeController"
    }
    override var imageName : String! {
        return "Home"
    }
    override var subsections : [TabSubsectionController]! {
        get {
            if _subsections == nil {
                _subsections = [SocialFeedController(), StreamsFeedController(), RecommendedFeedController()]
            }
            return _subsections
        }
    }
    override var titleItem : ASDisplayNode! {
        get {
            if _titleItem == nil {
                let item = ASTextNode()
                item.attributedString = NSAttributedString(string: "Home", attributes: self.titleAttributes)
                _titleItem = item
            }
            return _titleItem
        }
    }
}