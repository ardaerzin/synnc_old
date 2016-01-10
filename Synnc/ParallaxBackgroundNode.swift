//
//  ParallaxBackgroundNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit
import WebASDKImageManager

class ParallaxBackgroundScrollNode : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    var imageGradientNode : ASImageNode!

    
        override init() {
        super.init()
//        self.view.scrollEnabled = false
        
        self.clipsToBounds = true
        
        self.imageNode = ASNetworkImageNode(webImage: ())
        imageNode.userInteractionEnabled = false
        imageNode.enabled = false
        imageNode.backgroundColor = UIColor.whiteColor()
        
        imageGradientNode = ASImageNode()
        
        self.addSubnode(self.imageNode)
        self.addSubnode(self.imageGradientNode)
        
//        self.view.programaticScrollEnabled = false
    }
//    override func layout() {
//        self.view.programaticScrollEnabled = false
//        super.layout()
//    }
    override func setNeedsLayout() {
//        self.view.programaticScrollEnabled = false
        super.setNeedsLayout()
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
//        self.view.programaticScrollEnabled = true
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        imageGradientNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        return ASStaticLayoutSpec(children: [imageNode, imageGradientNode])
    }
}

class ParallaxBackgroundNode : ASScrollNode {
    var scrollNode : ParallaxBackgroundScrollNode!
    var imageNode : ASNetworkImageNode! {
        get {
            return self.scrollNode.imageNode
        }
    }
    var imageGradientNode : ASImageNode! {
        get {
            return self.scrollNode.imageGradientNode
        }
    }
    
        override init() {
        super.init()
        
        scrollNode = ParallaxBackgroundScrollNode()
        
        self.view.scrollEnabled = false
        self.clipsToBounds = false
        
        self.shadowColor = UIColor.blackColor().CGColor
        self.shadowOffset = CGSizeMake(0, 2)
        self.shadowOpacity = 1
        self.shadowRadius = 5
        
        self.addSubnode(scrollNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(constrainedSize.max)
        return ASStaticLayoutSpec(children: [self.scrollNode])
    }
    
    func updateScrollPositions(position: CGFloat){
        
    }
}