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
import WCLUserManager

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
                _subsections = [StreamsFeedController(), SocialFeedController(), RecommendedFeedController()]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.screenNode.backgroundColor = UIColor.redColor()
    }
}