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

class InputFieldArea : ASDisplayNode {
    
    var buttonSpacing : CGFloat {
        get {
            let screenSize = UIScreen.mainScreen().bounds.size
            if screenSize.height < 600 {
                return 20
            } else {
                return 35
            }
        }
    }
    var usernameField : JJMaterialTextfield!
    var emailField : JJMaterialTextfield!
    var passwordField : JJMaterialTextfield!
    var state : FormNodeState! = FormNodeState.None {
        didSet {
            self.changedState()
        }
    }
    var inputs : [JJMaterialTextfield] {
        get {
            return [usernameField, emailField, passwordField]
        }
    }
    var bottomGuide : CGFloat = 0
    
    var formStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! InputFieldArea).formStateProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! InputFieldArea).formStateProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var formStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("scaleAnimation")
                }
                x.springSpeed = 20
                x.springBounciness = 0
                x.property = self.formStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    var maxButtonTranslation : CGFloat!
    var formStateProgress : CGFloat = 0 {
        didSet {
            
            self.usernameField.alpha = formStateProgress
            let passwordTranslationY = POPTransition(formStateProgress, startValue: maxButtonTranslation, endValue: 0)
            
            POPLayerSetTranslationY(self.passwordField.layer, passwordTranslationY)
            
        }
    }
    
    func changedState(){
        if maxButtonTranslation == nil {
            maxButtonTranslation = CGRectGetMinY(self.usernameField.frame) - CGRectGetMinY(self.passwordField.frame)
        }
        
        var fieldTxt : String = ""
        if self.state == .Login {
            fieldTxt = "email/username"
        } else if self.state == .Signup {
            fieldTxt = "email"
        }
        emailField.attributedPlaceholder = NSAttributedString(string: fieldTxt, attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48)])
        emailField.enableMaterialPlaceHolder(true)
        
        self.formStateAnimation.toValue = self.state == .Login ? 0 : 1
    }
    override init!() {
        super.init()
    }
    override func layout() {
        let w = self.calculatedSize.width
        if emailField == nil {
            emailField = JJMaterialTextfield(frame: CGRectMake(0, 10, w, 25))
            emailField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48)])
            emailField.autocapitalizationType = .None
            emailField.enableMaterialPlaceHolder(true)
            self.view.addSubview(emailField)
            emailField.text = nil
            emailField.lineColor = UIColor.blackColor().colorWithAlphaComponent(0.07)
            emailField.returnKeyType = UIReturnKeyType.Next
            emailField.defaultTextAttributes = [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor()]
        }
        
        if usernameField == nil {
            usernameField = JJMaterialTextfield(frame: CGRectMake(0, 10+25+buttonSpacing, w, 25))
            usernameField.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48)])
            usernameField.enableMaterialPlaceHolder(true)
            self.view.addSubview(usernameField)
            usernameField.autocapitalizationType = .None
            usernameField.text = nil
            usernameField.lineColor = UIColor.blackColor().colorWithAlphaComponent(0.07)
            usernameField.returnKeyType = UIReturnKeyType.Next
            usernameField.defaultTextAttributes = [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor()]
        }
        
        
        if passwordField == nil {
            passwordField = JJMaterialTextfield(frame: CGRectMake(0, 10+50+(2*buttonSpacing), w, 25))
            passwordField.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48)])
            passwordField.enableMaterialPlaceHolder(true)
            self.view.addSubview(passwordField)
            passwordField.text = nil
            passwordField.secureTextEntry = true
            passwordField.lineColor = UIColor.blackColor().colorWithAlphaComponent(0.07)
            passwordField.defaultTextAttributes = [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor()]
            passwordField.returnKeyType = UIReturnKeyType.Go
            
            let x = 50+2*buttonSpacing+25+buttonSpacing
            self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: x))
            print(x)
        }
        
//        self.backgroundColor = UIColor.blueColor()
    }
}

enum FormNodeState : Int {
    case None = 0
    case Login
    case Signup
}
class LSFormNode : ASDisplayNode {
    
    var state : FormNodeState = .None {
        didSet {
            if state != oldValue {
                self.didChangeState(oldValue)
            }
        }
    }
    
    var titleNode : ASTextNode!
    var greetingMsgNode : ASTextNode!
    var inputArea : InputFieldArea!
    var actionButton : ButtonNode!
    
    var buttonMinY : CGFloat!
    var buttonMaxY : CGFloat!
    
    var titleSpacing : CGFloat {
        get {
            let screenSize = UIScreen.mainScreen().bounds.size
            if screenSize.height < 600 {
                return 40
            } else {
                return 80
            }
        }
    }
    var buttonHeight : CGFloat {
        get {
            let screenSize = UIScreen.mainScreen().bounds.size
            if screenSize.height < 600 {
                return 44
            } else {
                return 60
            }
        }
    }
    
    var keyboardStateProgress : CGFloat = 0 {
        didSet {
            
            if formDisplayProgress != 1 {
                return
            }
            
            var a = (self.titleNode.calculatedSize.height / 2) - titleSpacing
            a = max(-50, a)
            
            let titleTranslation = POPTransition(keyboardStateProgress, startValue: 0, endValue: a)
            POPLayerSetTranslationY(self.titleNode.layer, titleTranslation)
            POPLayerSetTranslationY(self.greetingMsgNode.layer, titleTranslation)
            self.greetingMsgNode.alpha = 1 - keyboardStateProgress
        }
    }
    
    var buttonTranslationY : CGFloat = 0
    var formStateProgress : CGFloat = 0 {
        didSet {
            let a = POPTransition(formStateProgress, startValue: 0, endValue: buttonTranslationY)
            POPLayerSetTranslationY(self.actionButton.layer, a)
        }
    }
    var formDisplayProgress : CGFloat = 0 {
        didSet {
            self.titleNode.alpha = formDisplayProgress
            self.greetingMsgNode.alpha = formDisplayProgress
            self.inputArea.alpha = formDisplayProgress
            self.actionButton.alpha = formDisplayProgress
        }
    }
    var titleStateProgress : CGFloat = 0 {
        didSet {
            self.titleNode.alpha = titleStateProgress
            self.greetingMsgNode.alpha = titleStateProgress
        }
    }
    
    
    func didChangeState(previousState : FormNodeState!) {
        
        if previousState == FormNodeState.None {
            var titleString : String!
            var greetingString : String!
            
            if self.state == .Login {
                titleString = "HI AGAIN"
                greetingString = "GOT SOME WEED?"
            } else if self.state == .Signup {
                titleString = "JOIN US"
                greetingString = "WE HAVE FREE COOKIES"
            }
            self.titleNode.attributedString = NSAttributedString(string: titleString, attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 18)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 2.57])
            self.greetingMsgNode.attributedString = NSAttributedString(string: greetingString, attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 106/255, green: 104/255, blue: 104/255, alpha: 1), NSKernAttributeName : 2])
        } else if self.state != .None {
            
            self.titleAreaAnimation.fromValue = 1
            self.titleAreaAnimation.completionBlock = {
                anim, finished in
                if finished {
                    var titleString : String!
                    var greetingString : String!
                    
                    if self.state == .Login {
                        titleString = "HI AGAIN"
                        greetingString = "GOT SOME WEED?"
                    } else if self.state == .Signup {
                        titleString = "JOIN US"
                        greetingString = "WE HAVE FREE COOKIES"
                    }
                    self.titleNode.attributedString = NSAttributedString(string: titleString, attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 18)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 2.57])
                    self.greetingMsgNode.attributedString = NSAttributedString(string: greetingString, attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 106/255, green: 104/255, blue: 104/255, alpha: 1), NSKernAttributeName : 2])
                    self.setNeedsLayout()
                    
                    self.titleAreaAnimation.toValue = 1
                }
            }
            self.titleAreaAnimation.toValue = 0
            
        }
        
        if self.state != .None {
            if self.state == .Login {
                self.buttonTranslationY = -60
                self.formStateAnimation.toValue = 1
            } else {
                self.formStateAnimation.toValue = 0
            }
        } else {
            self.buttonTranslationY = 0
            if let x = self.supernode as? FormNode {
                x.formSwitcher.targetForm = .Login
            }
        }
        
        self.inputArea.state = self.state
        formDisplayAnimation.toValue = self.state != .None ? 1 : 0
        
        self.setNeedsLayout()
    }
    
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.resignFirstResponder()
    }
    override func isFirstResponder() -> Bool {
        var b : Bool = false
        for x in self.inputArea.inputs {
            if x.isFirstResponder() {
                b = true
                break
            }
        }
        return b
    }
    override func resignFirstResponder() -> Bool {
        for x in self.inputArea.inputs {
            x.resignFirstResponder()
        }
        return true
    }
    override init!() {
        super.init()
        
        self.titleNode = ASTextNode()
        self.titleNode.alpha = 0
        self.titleNode.spacingBefore = titleSpacing
        self.titleNode.attributedString = NSAttributedString(string: "HI AGAIN", attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 18)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 2.57])
        
        self.greetingMsgNode = ASTextNode()
        self.greetingMsgNode.alpha = 0
        self.greetingMsgNode.spacingBefore = 25
        self.greetingMsgNode.attributedString = NSAttributedString(string: "GOT SOME WEED?", attributes: [NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 106/255, green: 104/255, blue: 104/255, alpha: 1), NSKernAttributeName : 2])
        
        self.inputArea = InputFieldArea()
        self.inputArea.alpha = 0
        self.inputArea.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: 10))
        
        let attributes = [NSFontAttributeName : UIFont(name: "FuturaBold", size: 12)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        let normalTitleString = NSAttributedString(string: "CONTINUE YOUR JOURNEY", attributes: attributes)
        
        self.actionButton = ButtonNode(normalColor: UIColor.SynncColor(), selectedColor: UIColor.SynncColor())
        self.actionButton.alpha = 0
        self.actionButton.flexShrink = true
        self.actionButton.minScale = 0.85
        self.actionButton.cornerRadius = 3
        self.actionButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.actionButton.setAttributedTitle(normalTitleString, forState: ASButtonStateNormal)
        
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.addSubnode(self.titleNode)
        self.addSubnode(self.greetingMsgNode)
        self.addSubnode(self.inputArea)
        self.addSubnode(self.actionButton)
        
        self.backgroundColor = UIColor.clearColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    var buttonTopTarget : CGFloat = 0
    var keyboardTop : CGFloat = 0
    var keyboardHeight : CGFloat = 0
    var inputAreaTopTarget : CGFloat = 0
    var keyboardVisible : Bool = false
    
    var formTopGuide : CGFloat! = 0
    
    func keyboardWillHide() {
        keyboardVisible = false
        formTopGuide = self.greetingMsgNode.position.y + (self.greetingMsgNode.calculatedSize.height / 2)
        keyboardStateAnimation.toValue = 0
    }
    func keyboardWillDisplay() {
        keyboardVisible = true
        formTopGuide = self.titleNode.position.y + (self.titleNode.calculatedSize.height / 2)
        keyboardStateAnimation.toValue = 1
    }
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        let a = KeyboardAnimationInfo(dict: notification.userInfo!)
        
        if CGRectGetMinY(a.finalFrame) - self.calculatedSize.height == 0 {
            self.keyboardWillHide()
        } else {
            self.keyboardWillDisplay()
        }
        
        let keyboardTop = self.calculatedSize.height - (CGRectGetMinY(a.finalFrame) - 5)
        let b = min(0, (self.calculatedSize.height - keyboardTop) - self.actionButton.position.y - (self.actionButton.calculatedSize.height / 2) )
        
        let formBottomY = self.actionButton.position.y + b - (self.actionButton.calculatedSize.height / 2)
        let x = (formTopGuide + formBottomY ) / 2
        let c = min(0, x - self.inputArea.position.y)
        
        POPLayerSetTranslationY(self.inputArea.layer, c)
        POPLayerSetTranslationY(self.actionButton.layer, b)
    }
    override func layout() {
        super.layout()
        print("layout")
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let inputSpec = ASStaticLayoutSpec(children: [inputArea])
        let b = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: inputSpec)
        b.alignSelf = .Stretch
        let c = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [inputSpec])
        c.alignSelf = .Stretch
        c.flexGrow = true
        c.spacingBefore = 20
        
        print("za")
        
        let spacer = ASLayoutSpec()
        spacer.flexBasis = ASRelativeDimension(type: .Points, value: 60)
        
        let buttonSpec = ASStaticLayoutSpec(children: [actionButton])
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [buttonSpec])
        a.flexGrow = true
        a.spacingAfter = 20
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [titleNode, greetingMsgNode, c, a, spacer])
    }
}


extension LSFormNode {
    var keyboardStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("keyboardStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LSFormNode).keyboardStateProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LSFormNode).keyboardStateProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var keyboardStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("keyboardStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("keyboardStateAnimation")
                }
                x.springSpeed = 20
                x.springBounciness = 0
                x.property = self.keyboardStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "keyboardStateAnimation")
                return x
            }
        }
    }
}

extension LSFormNode {
    var titleAreaAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("titleStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LSFormNode).titleStateProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LSFormNode).titleStateProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var titleAreaAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("titleStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("titleStateAnimation")
                }
                x.springSpeed = 50
                x.springBounciness = 0
                x.property = self.titleAreaAnimatableProperty
                self.pop_addAnimation(x, forKey: "titleStateAnimation")
                return x
            }
        }
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
extension LSFormNode {
    var formDisplayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LSFormNode).formDisplayProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LSFormNode).formDisplayProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var formDisplayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("scaleAnimation")
                }
                x.springSpeed = 1
                x.springBounciness = 0
                x.property = self.formDisplayAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
}