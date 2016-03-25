//
//  LoginNameNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class LoginBrandNode : ASDisplayNode {
    
    var iconNode : ASImageNode!
    var titleNode : ASTextNode!
    var subtextNode : ASTextNode!
    
    override init() {
        super.init()
    
        self.iconNode = ASImageNode()
        self.iconNode.image = Synnc.appIcon
        
//        self.logoHolder = AnimatedLogoNode(barCount: 5)
//        self.logoHolder.startAnimation()
        
        self.titleNode = ASTextNode()
        self.titleNode.attributedString = NSAttributedString(string: "synnc", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 48)!, NSForegroundColorAttributeName : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), NSKernAttributeName : -0.2])
        
        self.subtextNode = ASTextNode()
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        self.subtextNode.attributedString = NSAttributedString(string: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), NSKernAttributeName : 0, NSParagraphStyleAttributeName : p])
        
        self.addSubnode(self.iconNode)
        self.addSubnode(self.titleNode)
        self.addSubnode(subtextNode)
    }
    override func layout() {
        super.layout()
        
        self.titleNode.position.x = self.calculatedSize.width / 2
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
//        self.logoHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        
        let a = ASStaticLayoutSpec(children: [self.titleNode])
        let b = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 25, 0, 25), child: subtextNode)
        b.spacingBefore = 15
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [iconNode, a, b])
    }
}