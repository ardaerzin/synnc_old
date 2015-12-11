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
import DeviceKit

func ==(lhs: TabItem, rhs: TabItem) -> Bool {
    return lhs.title == rhs.title
}

//class TabItemController : ASViewController, TabItemZa {
//    var image : String!
//    var subsections : [ASViewController]!
//    var titleIcon : AnyObject?
//    var selectedIndex : Int = 0
//    var titleItem : AnyObject!
//}
//protocol TabItemZa {
//    var image : String! {get set}
//    var titleItem : AnyObject! {get set}
//    var subsections : [ASViewController]! {get set}
//    var titleIcon : AnyObject? {get set}
//    var selectedIndex : Int {get set}
//}

class TabItem: Equatable {
    var image : String!
    var title : String!
    var subsections : [String]!
    var hasTitleIcon : Bool!
    var selectedIndex : Int = 0
    
    init(image: String, title: String, subsections: [String], hasTitleIcon : Bool) {
        self.image = image
        self.title = title
        self.subsections = subsections
    }
}