//
//  LoginToggleButtonHolder.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LoginToggleButtonHolder : ASDisplayNode {
    var toggleButton : ButtonNode!
    var mask : CAShapeLayer!
    
    override init(){
        super.init()
        toggleButton = ButtonNode()
        toggleButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        toggleButton.minScale = 0.85
        
        self.addSubnode(toggleButton)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [toggleButton])
    }
}