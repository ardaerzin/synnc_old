//
//  StopControllerNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/16/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit
import pop

class StopControllerNode : ASDisplayNode {
    
    var titleNode : ASTextNode!
    let titleAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    
    let buttonAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    
    var noButton : ButtonNode!
    var yesButton : ButtonNode!
    
    override init() {
        super.init()
        
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "Are you sure you want to stop your active stream?", attributes: titleAttributes)
        titleNode.flexGrow = true
        
        noButton = ButtonNode()
        noButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(75, 35))
        noButton.setAttributedTitle(NSAttributedString(string: "Nope", attributes: buttonAttributes), forState: ASControlState.Normal)
        
        yesButton = ButtonNode()
        var yesAttributes = buttonAttributes
        yesAttributes[NSForegroundColorAttributeName] = UIColor.SynncColor()
        yesButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(75, 35))
        yesButton.setAttributedTitle(NSAttributedString(string: "Yes", attributes: yesAttributes), forState: ASControlState.Normal)
        
        self.addSubnode(titleNode)
        self.addSubnode(noButton)
        self.addSubnode(yesButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let yesStack = ASStaticLayoutSpec(children: [yesButton])
        let noStack = ASStaticLayoutSpec(children: [noButton])
        
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [yesStack, noStack])
        titleNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 10 - 75 - 25)
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [titleNode, vStack])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 20, 5, 5), child: x)
    }
}