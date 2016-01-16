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

protocol PopoverNodeDelegate {
    func hideWithTouch()
}
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
    var topMargin : CGFloat = 0
    var arrowNode : ASImageNode!
    var contentHolder : PopoverContentHolderNode!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.delegate?.hideWithTouch()
    }
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        let s = super.hitTest(point, withEvent : event)
//        print(s)
//        if s == self.view {
//            self.delegate?.hideWithTouch()
//            return nil
//        }
//        return s
//    }
    
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
            
            
//            let maxDiff = (self.arrowPosition.x - self.position.x)
//            let za = POPTransition(displayAnimationProgress, startValue: maxDiff, endValue: 0)
//            
//            let shit = POPTransition(displayAnimationProgress, startValue: (-self.supernode!.calculatedSize.height/2 - 20) - (self.calculatedSize.height/2), endValue: self.topMargin - self.position.y)
//            print(displayAnimationProgress, self.position.y)
//            POPLayerSetScaleXY(self.layer, CGPointMake(displayAnimationProgress, displayAnimationProgress))
//            POPLayerSetTranslationXY(self.layer, CGPointMake(za, shit))
        }
    }
    
    var delegate : PopoverNodeDelegate?
    
    init(delegate : PopoverNodeDelegate?){
        super.init()
        
        
        
        self.delegate = delegate
        
        arrowNode = ASImageNode()
        arrowNode.preferredFrameSize = CGSizeMake(20, 10)
        
        self.contentHolder = PopoverContentHolderNode()
//        self.contentHolder.flexGrow = true
        self.contentHolder.alignSelf = .Stretch
        self.contentHolder.backgroundColor = UIColor.clearColor()
        
        self.backgroundColor = UIColor.clearColor()
//            .blackColor().colorWithAlphaComponent(0.3)
        
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
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [ASStaticLayoutSpec(children: [arrowNode]), contentHolder])
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
                contentNode.layer.shadowColor = UIColor.blackColor().CGColor
                contentNode.layer.shadowOffset = CGSize(width: 0,height: 2)
                contentNode.layer.shadowOpacity = 0.5
                contentNode.layer.shadowRadius = 2
                
                self.addSubnode(contentNode)
            }
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if contentNode != nil {
            
//            contentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//            self.contentNode.flexGrow = true
            self.contentNode.alignSelf = .Stretch
            
            return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.contentNode])
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