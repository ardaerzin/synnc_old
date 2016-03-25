//
//  LoginSpinner.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager

enum LoginSpinnerState : Int {
    case None = -1
    case ServerConnect = 0
    case LoggingIn = 1
}

class SpinnerNode : ASDisplayNode {
    
    var animatedLogo : AnimatedLogoNode!
    var msgNode : ASTextNode!
    
    var state : LoginSpinnerState! {
        didSet {
            updateForState()
        }
    }
    
    func updateForState() {
        guard let s = self.state else {
            return
        }
        switch s {
        case .ServerConnect :
            let str = NSMutableAttributedString(string: "Connecting to Synnc Servers", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
            msgNode.attributedString = str
            break
        case .LoggingIn :
            msgNode.attributedString = NSAttributedString(string: "Logging you in..", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
            break
        default:
            break
        }
        
        self.setNeedsLayout()
    }
    
    deinit {
    }
    
//    var loginStatusAnimatableProperty : POPAnimatableProperty {
//        get {
//            let x = POPAnimatableProperty.propertyWithName("loginStatusAnimationProperty", initializer: {
//                
//                prop in
//                
//                prop.readBlock = {
//                    obj, values in
//                    values[0] = (obj as! SpinnerNode).loginStatusAnimationProgress
//                }
//                prop.writeBlock = {
//                    obj, values in
//                    (obj as! SpinnerNode).loginStatusAnimationProgress = values[0]
//                }
//                prop.threshold = 0.01
//            }) as! POPAnimatableProperty
//            
//            return x
//        }
//    }
//    var loginStatusAnimation : POPSpringAnimation {
//        get {
//            if let anim = self.pop_animationForKey("loginStatusAnimation") {
//                return anim as! POPSpringAnimation
//            } else {
//                let x = POPSpringAnimation()
//                x.completionBlock = {
//                    anim, finished in
//                    
//                    self.pop_removeAnimationForKey("loginStatusAnimation")
//                }
//                x.springBounciness = 0
//                x.dynamicsFriction = 20
//                x.property = self.loginStatusAnimatableProperty
//                self.pop_addAnimation(x, forKey: "loginStatusAnimation")
//                return x
//            }
//        }
//    }
//    var loginStatusAnimationProgress : CGFloat = 0 {
//        didSet {
//            let a = POPTransition(loginStatusAnimationProgress, startValue: 1, endValue: 0)
//            msgNode.alpha = a
//            
//            POPLayerSetScaleXY(self.msgNode.layer, CGPointMake(a,a))
//            
//            let b = CGFloat(1-a)
//            userLoginMsgNode.alpha = b
//            POPLayerSetScaleXY(self.userImageNode.layer, CGPointMake(b,b))
//            POPLayerSetScaleXY(self.userLoginMsgNode.layer, CGPointMake(b,b))
//        }
//    }
//    
//    
//    var imageDisplayAnimatableProperty : POPAnimatableProperty {
//        get {
//            let x = POPAnimatableProperty.propertyWithName("imageDisplayAnimationProperty", initializer: {
//                
//                prop in
//                
//                prop.readBlock = {
//                    obj, values in
//                    values[0] = (obj as! SpinnerNode).imageDisplayProgress
//                }
//                prop.writeBlock = {
//                    obj, values in
//                    (obj as! SpinnerNode).imageDisplayProgress = values[0]
//                }
//                prop.threshold = 0.01
//            }) as! POPAnimatableProperty
//            
//            return x
//        }
//    }
//    var imageDisplayAnimation : POPSpringAnimation {
//        get {
//            if let anim = self.pop_animationForKey("imageDisplayAnimation") {
//                return anim as! POPSpringAnimation
//            } else {
//                let x = POPSpringAnimation()
//                x.completionBlock = {
//                    anim, finished in
//                    
//                    self.pop_removeAnimationForKey("imageDisplayAnimation")
//                }
//                x.springBounciness = 0
//                x.property = self.imageDisplayAnimatableProperty
//                self.pop_addAnimation(x, forKey: "imageDisplayAnimation")
//                return x
//            }
//        }
//    }
//    var imageDisplayProgress : CGFloat = 0 {
//        didSet {
//            POPLayerSetScaleXY(self.userImageNode.layer, CGPointMake(imageDisplayProgress,imageDisplayProgress))
//            userImageNode.alpha = imageDisplayProgress
//        }
//    }
    
    override init() {
        super.init()
        
        animatedLogo = AnimatedLogoNode(barCount: 5)
        animatedLogo.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 30,height: 30))
        msgNode = ASTextNode()
        
        self.addSubnode(msgNode)
        self.addSubnode(animatedLogo)
    }
    
    override func didLoad() {
        super.didLoad()
        animatedLogo.startAnimation()
    }
    
    override func layout() {
        super.layout()
       
        if let n = self.supernode {
        
            let x = self.calculatedSize.width / 2
            let y = n.calculatedSize.width / 2
            let a = y - x
            
            self.animatedLogo.position.y = self.msgNode.position.y
            self.animatedLogo.position.x = self.calculatedSize.width + a - (self.animatedLogo.calculatedSize.width / 2)
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [self.msgNode])
        
        let a = ASStaticLayoutSpec(children: [animatedLogo])
        return ASOverlayLayoutSpec(child: x, overlay: a)
    }
}