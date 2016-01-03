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

class ParallaxBackgroundNode : ASScrollNode {
    var imageNode : ASNetworkImageNode!
    var imageGradientNode : ASImageNode!
    
    override init!() {
        super.init()
        self.imageNode = ASNetworkImageNode(webImage: ())
        imageNode.userInteractionEnabled = false
        imageNode.enabled = false

        self.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.view.scrollEnabled = false
        self.clipsToBounds = false
        
        imageGradientNode = ASImageNode()
        imageGradientNode.image = UIImage(named: "imageGradient")

        self.addSubnode(self.imageNode)
        self.addSubnode(self.imageGradientNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        imageGradientNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        return ASStaticLayoutSpec(children: [self.imageNode, self.imageGradientNode])
    }
    
    func updateScrollPositions(position: CGFloat){
        
    }
}