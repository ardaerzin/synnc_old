//
//  LSFormNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/3/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit

class LSFormNode : ASDisplayNode {
    
    internal var _maxButtonTranslation : CGFloat!
    var maxButtonTranslation : CGFloat! {
        get {
            if _maxButtonTranslation == nil {
                _maxButtonTranslation = CGRectGetMinY(self.usernameField.frame) - CGRectGetMinY(self.passwordField.frame)
            }
            return _maxButtonTranslation
        }
    }
    var formStateProgress : CGFloat = 0 {
        didSet {
            
            self.usernameField.alpha = formStateProgress
            
            let passwordTranslationY = POPTransition(formStateProgress, startValue: maxButtonTranslation, endValue: 0)
            POPLayerSetTranslationY(self.passwordField.layer, passwordTranslationY)
            
        }
    }
    var state : LoginNodeState = .None {
        didSet {
            if state != oldValue {
                self.didChangeState(state)
            }
        }
    }
    var inputs : [WCLMaterialTextField]! {
        get {
            return [emailField, usernameField, passwordField]
        }
    }
    var usernameField : WCLMaterialTextField!
    var emailField : WCLMaterialTextField!
    var passwordField : WCLMaterialTextField!
    
    
    func didChangeState(state : LoginNodeState!) {
        self.formStateAnimation.toValue = state.rawValue
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.resignFirstResponder()
    }
    override func isFirstResponder() -> Bool {
        var b : Bool = false
        for x in self.inputs {
            if x.isFirstResponder() {
                b = true
                break
            }
        }
        return b
    }
    override func resignFirstResponder() -> Bool {
        for x in self.inputs {
            x.textNode.resignFirstResponder()
        }
        return true
    }
    
    override init() {
        super.init()
        
        self.usernameField = WCLMaterialTextField()
        self.usernameField.alignSelf = .Stretch
        self.usernameField.flexBasis = ASRelativeDimension(type: .Points, value: 25)
        self.usernameField.textNode.returnKeyType = .Next
        self.usernameField.textNode.textView.autocapitalizationType = .None
        self.usernameField.attributedPlaceholderText = NSAttributedString(string: "username", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48), NSKernAttributeName : 1])
        
        self.emailField = WCLMaterialTextField()
        self.emailField.alignSelf = .Stretch
        self.emailField.flexBasis = ASRelativeDimension(type: .Points, value: 25)
        self.emailField.textNode.returnKeyType = .Next
        self.emailField.textNode.textView.autocapitalizationType = .None
        self.emailField.attributedPlaceholderText = NSAttributedString(string: "email", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48), NSKernAttributeName : 1])
        
        self.passwordField = WCLMaterialTextField()
        self.passwordField.alignSelf = .Stretch
        self.passwordField.flexBasis = ASRelativeDimension(type: .Points, value: 25)
        self.passwordField.textNode.returnKeyType = .Go
        self.passwordField.textNode.textView.autocapitalizationType = .None
        self.passwordField.attributedPlaceholderText = NSAttributedString(string: "password", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48), NSKernAttributeName : 1])
        
        self.addSubnode(usernameField)
        self.addSubnode(emailField)
        self.addSubnode(passwordField)
    }
    
    var buttonTopTarget : CGFloat = 0
    var keyboardTop : CGFloat = 0
    var keyboardHeight : CGFloat = 0
    var inputAreaTopTarget : CGFloat = 0
    var keyboardVisible : Bool = false
    
    var formTopGuide : CGFloat! = 0
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: (25*0.75) + 5, justifyContent: .Center, alignItems: .Center, children: self.inputs)
        let x = constrainedSize.max.width * 0.25 / 2
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: x, bottom: 0, right: x), child: a)
    
    }
}

extension LSFormNode {
    var formStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("formStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LSFormNode).formStateProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LSFormNode).formStateProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var formStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("formStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("formStateAnimation")
                }
                x.springBounciness = 0
                x.property = self.formStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "formStateAnimation")
                return x
            }
        }
    }
}