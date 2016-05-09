//
//  HomeNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class HomeNode : PagerBaseControllerNode {
    
}

class HomeHeader : PagerHeaderNode {
    var toggleButton : ToggleButton!
    
    override init(backgroundColor: UIColor?, height: CGFloat?) {
        super.init(backgroundColor: backgroundColor, height: height)
        
        toggleButton = ToggleButton()
        toggleButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        self.addSubnode(toggleButton)
    }
    
    override func layout() {
        super.layout()
        
        self.toggleButton.position = self.leftButtonHolder.position
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [a, toggleButton])
    }
}