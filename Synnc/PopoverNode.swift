//
//  PopoverNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/28/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class PopoverNode : ASDisplayNode {
    
    let arrowWidth: CGFloat = 20
    let arrowHeight: CGFloat = 10
    
    var arrowPosition : CGPoint! {
        didSet {
            if oldValue == nil {
                self.initialPosition = arrowPosition
            } else if oldValue != nil && arrowPosition != oldValue {
                self.arrowAnimation.toValue = arrowPosition.x - initialPosition.x
            }
        }
    }
    var arrowDiff : CGFloat = 0
    
    
    var initialPosition : CGPoint!
    
    var arrowNode : ASImageNode!
    var contentHolder : PopoverContentHolderNode!
    
    var arrowAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("arrowAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PopoverNode).arrowAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PopoverNode).arrowAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var arrowAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("arrowAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                }
                x.springSpeed = 15
                x.springBounciness = 0
                x.property = self.arrowAnimatableProperty
                self.pop_addAnimation(x, forKey: "arrowAnimation")
                return x
            }
        }
    }
    var arrowAnimationProgress : CGFloat = 0 {
        didSet {
            print(arrowAnimationProgress)
//            print(arrowAnimationProgress)
//            let x = POPProgress(arrowAnimationProgress, startValue: 0, endValue: self.arrowDiff)
//            let z = POPTransition(x, startValue: 0, endValue: self.arrowDiff)
//            print(z)
            
            POPLayerSetTranslationX(self.arrowNode.layer, arrowAnimationProgress)
        }
    }
    
    
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("displayAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PopoverNode).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PopoverNode).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("displayAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                }
                x.springSpeed = 15
                x.springBounciness = 0
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "displayAnimation")
                return x
            }
        }
    }
    var displayAnimationProgress : CGFloat = 0 {
        didSet {
            let maxDiff = (self.arrowPosition.x - self.position.x)
            let za = POPTransition(displayAnimationProgress, startValue: maxDiff, endValue: 0)
            
            let shit = POPTransition(displayAnimationProgress, startValue: -self.calculatedSize.height / 2, endValue: 0)
            POPLayerSetScaleXY(self.layer, CGPointMake(displayAnimationProgress, displayAnimationProgress))
            POPLayerSetTranslationXY(self.layer, CGPointMake(za, shit))
        }
    }
    
    override init(){
        super.init()
        
        arrowNode = ASImageNode()
        arrowNode.preferredFrameSize = CGSizeMake(20, 10)
        
        self.contentHolder = PopoverContentHolderNode()
        self.contentHolder.flexGrow = true
        self.contentHolder.alignSelf = .Stretch
        self.contentHolder.backgroundColor = UIColor.whiteColor()
        
        self.backgroundColor = UIColor.clearColor()
        
        self.addSubnode(arrowNode)
        self.addSubnode(contentHolder)
    }
    
    override func fetchData() {
        super.fetchData()
        arrowNode.image = self.arrowImage()
    }
    override func layout() {
        super.layout()
        self.supernode?.calculatedSize
        
        if let sn = self.supernode {
            self.position.y = sn.calculatedSize.height / 2 - 10
        }
        let a = self.displayAnimationProgress
        self.displayAnimationProgress = a
        
        arrowNode.position.x = initialPosition.x
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [arrowNode]), contentHolder])
    }
    
    func setContent(node : ASDisplayNode?){
        self.contentHolder.contentNode?.removeFromSupernode()
        self.contentHolder.contentNode = node
        self.contentHolder.setNeedsLayout()
    }
}

class PopoverContentHolderNode : ASDisplayNode {
    var contentNode : ASDisplayNode! {
        didSet {
            if contentNode != nil {
                self.addSubnode(contentNode)
            }
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if contentNode != nil {
            
//            contentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
            self.contentNode.flexGrow = true
            self.contentNode.alignSelf = .Stretch
            
            return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.contentNode])
//                ASStaticLayoutSpec(children: [contentNode])
        }
        return ASLayoutSpec()
    }
}

extension PopoverNode {
    func arrowImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: arrowWidth, height: arrowHeight), false, UIScreen.mainScreen().scale)
        
        let context = UIGraphicsGetCurrentContext()
        UIColor.clearColor().setFill()
        CGContextFillRect(context, CGRect(x: 0, y: 0, width: arrowWidth, height: arrowHeight))
        
        let arrowPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(arrowPath, nil,  arrowWidth / 2, 0)
        CGPathAddLineToPoint(arrowPath, nil, arrowWidth, arrowHeight)
        CGPathAddLineToPoint(arrowPath, nil, 0, arrowHeight)
        CGPathCloseSubpath(arrowPath)
        
        CGContextAddPath(context, arrowPath)
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        
        let arrowImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return arrowImage
    }
}