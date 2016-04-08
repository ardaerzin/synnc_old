//
//  LoginVCHolder.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit
import WCLDataManager

class LoginVCHolder : ASDisplayNode {
    
    var state : LoginVCState! {
        didSet {
            if oldValue != nil {
                self.stateAnimation.toValue = state == .Onboarding ? 0 : 1
            } else {
                self.stateAnimationProgress = CGFloat(state.rawValue)
            }
            
            if state == .Onboarding {
                self.loginNode.panRecognizer.enabled = true
                
            }
        }
    }
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("serverStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LoginVCHolder).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LoginVCHolder).stateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = 1 {
        didSet {
            
            let size = self.calculatedSize == CGSizeZero ? UIScreen.mainScreen().bounds.size : self.calculatedSize
            let a = POPTransition(stateAnimationProgress, startValue: (size.height - 60), endValue: -60)
            
            loginNode.translationY = a
            loginNode.toggleButton.alpha = 1-stateAnimationProgress
            loginNode.toggleIndicator.alpha = 1-stateAnimationProgress
        }
    }
    
    
    lazy var loginNode : LoginNode = {
        let x = LoginNode()
        let a = UIPanGestureRecognizer()
        x.panRecognizer = a
        a.enabled = false
        return x
    }()
    var onboardingNode : ASDisplayNode! {
        didSet {
            if let node = onboardingNode{
                self.addSubnode(node)
                self.view.sendSubviewToBack(node.view)
            }
        }
    }
    
    override init() {
        super.init()
        self.addSubnode(loginNode)
    }
    
    override func layout() {
        super.layout()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        loginNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height + 60))
        if let n = onboardingNode {
            n.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - 60))
            return ASStaticLayoutSpec(children: [loginNode, onboardingNode])
        } else {
            return ASStaticLayoutSpec(children: [loginNode])
        }
    }
}