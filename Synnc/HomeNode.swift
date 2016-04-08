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

class ToggleButton : ASControlNode {
    
    let angle = CGFloat(M_PI/5)
    var progress : CGFloat = -1 {
        didSet {
            let x = POPTransition(progress, startValue: -1, endValue: 1)
            let diff = (1-cos(x * angle)) * self.line1.calculatedSize.width
            
            let a = (line1.calculatedSize.height / 2)
            
            POPLayerSetRotation(line1.layer, x * angle)
            POPLayerSetTranslationX(line1.layer, diff/2 + a)
            POPLayerSetRotation(line2.layer, -x * angle)
            POPLayerSetTranslationX(line2.layer, -diff/2 - a)
        }
    }
    
    
    var line1 : ASDisplayNode!
    var line2 : ASDisplayNode!
    
    override init() {
        super.init()
        
        let height = UIScreen.mainScreen().scale
        let sizeRange = ASRelativeSizeRangeMakeWithExactRelativeSize(ASRelativeSizeMake(ASRelativeDimension(type: .Points, value:  10), ASRelativeDimension(type: .Points, value:  height)))
        
        line1 = ASDisplayNode()
        line1.layerBacked = true
        line1.sizeRange = sizeRange
        line1.backgroundColor = .whiteColor()
        line1.cornerRadius = height / 2
        self.addSubnode(line1)
        
        line2 = ASDisplayNode()
        line2.layerBacked = true
        line2.sizeRange = sizeRange
        line2.backgroundColor = .whiteColor()
        line2.cornerRadius = height / 2
        self.addSubnode(line2)
    }
    
    override func layout() {
        super.layout()
        
        line1.position.y = self.calculatedSize.height / 2
        line2.position.y = self.calculatedSize.height / 2
        line1.position.x = (self.calculatedSize.width / 2) - (line2.calculatedSize.width / 2)
        line2.position.x = (self.calculatedSize.width / 2) + (line2.calculatedSize.width / 2)
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if progress == -1 {
            progress = 1
        }
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [line1, line2])
    }
}

class HomeHeader : PagerHeaderNode {
    var toggleButton : ToggleButton!
    
    override init(backgroundColor: UIColor?, height: CGFloat?) {
        super.init(backgroundColor: backgroundColor, height: height)
        
        toggleButton = ToggleButton()
//        toggleButton.setImage(UIImage(named: "chevron-up"), forState: .Normal)
//        toggleButton.imageNode.contentMode = .Center
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