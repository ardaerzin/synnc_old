//
//  PopContentController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/23/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class PopContentController : ASViewController {
    var screenNode : ASDisplayNode!
    var topMargin : CGFloat = 0
    
    func hideController(sender: AnyObject!){
        if let p = self.parentViewController as? PopController {
            p.hideWithTouch()
        }
    }
}