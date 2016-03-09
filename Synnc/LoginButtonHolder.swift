//
//  LoginButtonHolder.swift
//  Synnc
//
//  Created by Arda Erzin on 3/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import pop
import WCLUIKit

class ButtonHolder : ASDisplayNode {
    
    var actionButton : LoginButtonNode!
    var facebookLoginButton : LoginButtonNode!
    var twitterLoginButton : LoginButtonNode!
    var seperatorNode : SeperatorNode!
    
    
    var buttonHeight : CGFloat!
    
    
    var state : LoginNodeState! = .None {
        didSet {
            var str : String!
//            str = state == .Signup ? "SIGN UP" : state == .Login ? "LOGIN" : nil
//            if str != nil {
//                let normalTitleString = NSAttributedString(string: str, attributes: attributes)
//                self.actionButton.setAttributedTitle(normalTitleString, forState: ASControlState.Normal)
//            }
        }
    }
    
    var translationY : CGFloat = 0
    var maxTranslationY : CGFloat = 0
    
    var keyboardState : NodeKeyboardState! {
        didSet {
//            let top = keyboardState.frame
            
            let actionButtonCenter = self.position.y - self.calculatedSize.height / 2 + (self.actionButton.position.y + self.actionButton.calculatedSize.height / 2)
            let keyboardTop = CGRectGetMinY(keyboardState.frame)
            
            
            let diff = keyboardTop - (actionButtonCenter + translationY)
            
            if diff < 0 {
                print("keyboard diff", diff)
            }
            
            maxTranslationY = diff
            print(diff)
            
//            print("button shit", actionButtonCenter, keyboardTop)
            
            self.keyboardStateAnimation.toValue = keyboardState.state.rawValue
        }
    }
    var keyboardStateProgress : CGFloat = 0 {
        didSet {
            
            let alpha = 1 - keyboardStateProgress
            self.seperatorNode.alpha = alpha
            self.facebookLoginButton.alpha = alpha
            self.twitterLoginButton.alpha = alpha
            
            print(keyboardStateProgress)
            
            let ty = POPTransition(keyboardStateProgress, startValue: 0, endValue: maxTranslationY)
            POPLayerSetTranslationY(self.layer, ty)
            
        }
    }
    
    override init() {
        super.init()
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : p]
        
        var buttonHeight : CGFloat = 50
        
        let screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height < 600 {
            buttonHeight = 44
        }
        self.buttonHeight = buttonHeight
      
        self.actionButton = LoginButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        self.actionButton.minScale = 0.85
        self.actionButton.flexShrink = true
        self.actionButton.cornerRadius = 3
        self.actionButton.alpha = 1
        self.actionButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        
        self.seperatorNode = SeperatorNode()
        self.seperatorNode.alpha = 1
        self.seperatorNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: 15))
        
        self.facebookLoginButton = LoginButtonNode(normalColor: UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1), selectedColor: UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1))
        self.facebookLoginButton.alpha = 1
        self.facebookLoginButton.minScale = 0.85
        self.facebookLoginButton.setImage(UIImage(named: "facebook"), forState: ASControlState.Normal)
        self.facebookLoginButton.cornerRadius = 3
        self.facebookLoginButton.setAttributedTitle(NSAttributedString(string: "Sign in with Facebook", attributes: attributes), forState: .Normal)
        
        self.twitterLoginButton = LoginButtonNode(normalColor: UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1), selectedColor: UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1))
        self.twitterLoginButton.alpha = 1
        self.twitterLoginButton.minScale = 0.85
        self.twitterLoginButton.setImage(UIImage(named: "twitter"), forState: ASControlState.Normal)
        self.twitterLoginButton.cornerRadius = 3
        self.twitterLoginButton.setAttributedTitle(NSAttributedString(string: "Sign in with Twitter", attributes: attributes), forState: .Normal)
        
//        self.addSubnode(self.actionButton)
//        self.addSubnode(self.seperatorNode)
        self.addSubnode(self.facebookLoginButton)
        self.addSubnode(self.twitterLoginButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let regularButtonStack = ASStaticLayoutSpec(children: [self.actionButton])
        let facebookButtonStack = ASStaticLayoutSpec(children: [self.facebookLoginButton])
        let twitterButtonStack = ASStaticLayoutSpec(children: [self.twitterLoginButton])
        let seperatorStack = ASStaticLayoutSpec(children: [self.seperatorNode])
        
        let socialSpacer = ASLayoutSpec()
        socialSpacer.flexGrow = true
        
        self.facebookLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
//            ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.35), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.twitterLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
//            ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.35), ASRelativeDimension(type: .Points, value: buttonHeight))
        
        let socialLoginStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [facebookButtonStack, socialSpacer, twitterButtonStack])
        socialLoginStack.alignSelf = .Stretch
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [facebookButtonStack, twitterButtonStack])
        
        return a
    }
}

extension ButtonHolder {
    var keyboardStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("keyboardAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! ButtonHolder).keyboardStateProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! ButtonHolder).keyboardStateProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var keyboardStateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("keyboardStateAnimation") as? POPBasicAnimation {
                return anim
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("keyboardStateAnimation")
                }
                x.property = self.keyboardStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "keyboardStateAnimation")
                return x
            }
        }
    }
}