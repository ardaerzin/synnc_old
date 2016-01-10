//
//  StreamLoadingNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/4/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager

class StreamLoadingNode : ASDisplayNode {
    var animationNode : AnimatedLogoNode!
    var titleNode : ASTextNode!
    
        override init() {
        super.init()
        
        animationNode = AnimatedLogoNode(barCount: 5)
        animationNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 50, height: 50))
        animationNode.startAnimation()
        
        titleNode = ASTextNode()
        titleNode.attributedString =  NSAttributedString(string: "Creating Your Stream...", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 20)!, NSForegroundColorAttributeName : UIColor(red: 83/255, green: 83/255, blue: 83/255, alpha: 1), NSKernAttributeName : 0.3])
    
        self.addSubnode(animationNode)
        self.addSubnode(titleNode)
    }
    
    override func layout() {
        super.layout()
        animationNode.position.x = self.calculatedSize.width - (animationNode.calculatedSize.width / 2)
        
        titleNode.position.x = (self.calculatedSize.width / 2)
        titleNode.position.y = (self.calculatedSize.height / 2)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [titleNode])
        return ASStaticLayoutSpec(children: [animationNode, titleNode])
        
//        return ASStaticLayoutSpec(children: [animationNode])
//            ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [animationNode]), titleNode])
    }
}
