//
//  MyStreamController.swift
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

class MyStreamController : TabItemController {
    
    override var identifier : String! {
        return "MyStreamController"
    }
    override var imageName : String! {
        return "mystream_icon"
    }
    override var subsections : [TabSubsectionController]! {
        get {
            if _subsections == nil {
                _subsections = []
            }
            return _subsections
        }
    }
    override var titleItem : ASDisplayNode! {
        get {
            if _titleItem == nil {
                let item = ASTextNode()
                item.attributedString = NSAttributedString(string: "My Stream", attributes: self.titleAttributes)
                _titleItem = item
            }
            return _titleItem
        }
    }
}