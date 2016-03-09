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
import WCLUserManager

class MyStreamController : TabItemController {
    override var identifier : String! {
        return "MyStreamController"
    }
    override var imageName : String! {
        return "mystream_icon"
    }
}