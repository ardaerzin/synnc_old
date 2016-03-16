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

class ParallaxBackgroundScrollNode : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    var imageGradientNode : ASImageNode!

    
    override init() {
        super.init()
        self.clipsToBounds = true
        
        self.imageNode = ASNetworkImageNode()
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
    var imageSelector : ButtonNode!
    var editing : Bool = false {
        didSet {
            if editing != oldValue {
                enableSelectionAnimation.toValue = editing ? 1 : 0
            }
        }
    }
    var enableSelectionAnimation : POPBasicAnimation! {
        get {
            if let anim = self.imageSelector.pop_animationForKey("enableSelectionAnimation") as? POPBasicAnimation {
                return anim
            } else {
                let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                anim.completionBlock = {
                    a, finished in
                    self.imageSelector.userInteractionEnabled = self.editing
                    self.imageSelector.enabled = self.editing
                }
                self.imageSelector.pop_addAnimation(anim, forKey: "enableSelectionAnimation")
                return anim
            }
        }
    }
    var backgroundTranslation : CGFloat! {
        didSet {
            POPLayerSetTranslationY(self.scrollNode.imageGradientNode.layer, backgroundTranslation)
            POPLayerSetTranslationY(self.scrollNode.imageNode.layer, backgroundTranslation)
        }
    }
    var backgroundScale : CGFloat! {
        didSet {
            POPLayerSetScaleXY(self.imageGradientNode.layer, CGPointMake(backgroundScale, backgroundScale))
            POPLayerSetScaleXY(self.imageNode.layer, CGPointMake(backgroundScale, backgroundScale))
        }
    }
    override init() {
        super.init()
        
        scrollNode = ParallaxBackgroundScrollNode()
        
        self.view.scrollEnabled = false
        self.clipsToBounds = false
        
        self.shadowColor = UIColor.blackColor().CGColor
        self.shadowOffset = CGSizeMake(0, 1)
        self.shadowOpacity = 0.5
        self.shadowRadius = 2
        
        self.view.delaysContentTouches = false
        
        imageSelector = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        imageSelector.setImage(UIImage(named: "camera-large")?.resizeImage(usingWidth: 20), forState: ASControlState.Normal)
        imageSelector.minScale = 1
        imageSelector.enabled = false
        imageSelector.userInteractionEnabled = false
        imageSelector.alpha = 0
        
        imageSelector.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50, 50))
        
        self.addSubnode(scrollNode)
        self.addSubnode(imageSelector)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, constrainedSize.max.width))
        
//        ASStaticLayoutSpec(children: [self.scrollNode, imageSelector])
        let a = ASStaticLayoutSpec(children: [self.scrollNode, imageSelector])
        return a
//            ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: a)
    }
    
    override func layout() {
        super.layout()
        
        if self.scrollNode.calculatedSize.height > self.calculatedSize.height {
            let diff = self.scrollNode.calculatedSize.height - self.calculatedSize.height
            self.scrollNode.position.y = self.calculatedSize.height - (self.scrollNode.calculatedSize.height / 2)
        }
        self.imageSelector.position.x = self.calculatedSize.width - (self.imageSelector.calculatedSize.width / 2)
        self.imageSelector.position.y = self.calculatedSize.height - (self.imageSelector.calculatedSize.height / 2)
    }
    
    func updateScrollPositions(position: CGFloat, ratioProgress: CGFloat = 0){
        
        if position < 0 {
            if ratioProgress < 1 {
                POPLayerSetTranslationY(self.imageSelector.layer, 0)
            } else {
                let a = self.scrollNode.calculatedSize.height - self.calculatedSize.height
                POPLayerSetTranslationY(self.imageSelector.layer, (position + a) / 4)
            }
            
        } else {
            POPLayerSetTranslationY(self.imageSelector.layer, 0)
        }
    }
}