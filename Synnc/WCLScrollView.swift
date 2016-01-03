//
//  WCLScrollView.swift
//  Synnc
//
//  Created by Arda Erzin on 1/1/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit

class WCLScroller : UIScrollView {
    var oldOffset : CGPoint!
    var offsetAccept : Bool = true
    
    override var contentOffset : CGPoint {
        willSet {
            oldOffset = contentOffset
        }
        didSet {
            if !self.offsetAccept {
                super.contentOffset = oldOffset
            }
        }
    }
    
    
}