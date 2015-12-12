//
//  TabItem.swift
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

class TabSubsectionController : ASViewController {
    internal var _title : String! {
        get {
            return "Subsection"
        }
    }
    override var title : String! {
        get {
            return _title
        }
        set {
        }
    }
}

class TabItemController : ASViewController, TabItem {
    var identifier : String! {
        get {
            return "id"
        }
    }
    var imageName : String! {
        get {
            return "hey"
        }
    }
    internal var _subsections : [TabSubsectionController]!
    var subsections : [TabSubsectionController]! {
        get {
            return []
        }
    }
    internal var _titleItem : ASDisplayNode!
    var titleItem : ASDisplayNode! {
        get {
            return nil
        }
    }
    internal var _iconItem : ASDisplayNode!
    var iconItem : ASDisplayNode! {
        get {
            return nil
        }
    }
    final var selectedIndex : Int = 0
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 30)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.15]
}
@objc protocol TabItem {
    var identifier : String! {get}
    var imageName : String! {get}
    
    var titleItem : ASDisplayNode! {get}
    var iconItem : ASDisplayNode! {get}
    var subsections : [TabSubsectionController]! {get}
    var selectedIndex : Int {get set}
}