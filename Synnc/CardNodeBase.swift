//
//  CardNodeBase.swift
//  Synnc
//
//  Created by Arda Erzin on 3/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class CardNodeBase : ASDisplayNode {
    override init() {
        super.init()
        
        backgroundColor = .whiteColor()
        self.cornerRadius = 15
        
        self.shadowColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 0.5).CGColor
        self.shadowOpacity = 1
        self.shadowOffset = CGSizeMake(0, 1)
        self.shadowRadius = 2
    }
}