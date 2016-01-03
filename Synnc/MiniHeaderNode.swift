//
//  MiniHeaderNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/23/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop

class SmallHeaderNode : ASDisplayNode {
    var buttons : [ButtonNode] = [] {
        didSet {
            for button in buttons {
                self.addSubnode(button)
                button.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMake(ASRelativeDimension(type: .Points, value: 0), ASRelativeDimension(type: .Percent, value: 1)), ASRelativeSizeMake(ASRelativeDimension(type: .Points, value: 200), ASRelativeDimension(type: .Percent, value: 1)))
            }
            
            self.setNeedsLayout()
        }
    }
    var closeButton : ButtonNode!
    var buttonSpecs : [ASLayoutable] = []
    
    override init!() {
        super.init()
        
        self.closeButton = ButtonNode(normalColor: .clearColor(), selectedColor: .clearColor())
        self.closeButton.setImage(UIImage(named: "chevronDown"), forState: ASButtonStateNormal)
        self.closeButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimensionMake(.Points, 44), ASRelativeDimensionMake(.Percent, 1))
        
        self.addSubnode(self.closeButton)
    }
    override func layout() {
        super.layout()
        
        self.closeButton.position.x = self.closeButton.calculatedSize.width / 2 + 10
        
        var buttonsTotalWidth : CGFloat = self.closeButton.calculatedSize.width
        for button in buttons {
            buttonsTotalWidth += button.calculatedSize.width
        }
        
        let diff = self.calculatedSize.width - (buttonsTotalWidth + CGFloat(buttons.count) * 10)
        
        let buttonSpacing = min(50, diff * 0.5 / CGFloat(buttons.count - 1))
        
        var prevLeft : CGFloat = 0
        for (index,button) in buttons.reverse().enumerate() {
            
            var marginRight : CGFloat = 0
            if index == 0 {
                marginRight = 20
                button.position.x = self.calculatedSize.width - (button.calculatedSize.width / 2) - marginRight
            } else {
                button.position.x = prevLeft - buttonSpacing - (button.calculatedSize.width / 2)
            }
            button.position.y = self.calculatedSize.height / 2
            
            prevLeft = button.position.x - (button.calculatedSize.width / 2)
        }
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        spacer.flexBasis = ASRelativeDimension(type: .Percent, value: 0.5)
        
        let a = ASStaticLayoutSpec(children: [self.closeButton])
        a.spacingBefore = 0
        
        
        var x : [ASLayoutable] = [a]
        x += (buttons as [ASLayoutable])
        return ASStaticLayoutSpec(children: x)
    }
}