//
//  LoginNode.swift
//  LonoNotes
//
//  Created by Arda Erzin on 11/14/15.
//  Copyright © 2015 Doguhan Okumus. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class SeperatorNode : ASDisplayNode {
    var seperatorLine1 : ASDisplayNode!
    var seperatorLine2 : ASDisplayNode!
    var seperatorText : ASTextNode!
    
    deinit {
//        print("deinit SeperatorNode")
    }
    
        override init() {
        super.init()
        
        self.seperatorLine1 = ASDisplayNode()
        self.seperatorLine1.preferredFrameSize = CGSizeMake(100, 1)
        self.seperatorLine1.layerBacked = true
        self.seperatorLine1.spacingAfter = 10
        self.seperatorLine1.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
        self.seperatorLine1.flexGrow = true
        
        self.seperatorLine2 = ASDisplayNode()
        self.seperatorLine2.layerBacked = true
        self.seperatorLine2.preferredFrameSize = CGSizeMake(100, 1)
        self.seperatorLine2.spacingBefore = 10
        self.seperatorLine2.backgroundColor = UIColor(red: 0/255, green: 151/255, blue: 151/255, alpha: 1)
        self.seperatorLine2.flexGrow = true
        
        self.seperatorText = ASTextNode()
        self.seperatorText.layerBacked = true
        self.seperatorText.attributedString = NSAttributedString(string: "OR", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)])
        
        self.addSubnode(self.seperatorLine1)
        self.addSubnode(self.seperatorText)
        self.addSubnode(self.seperatorLine2)
        
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: 10))
        self.alignSelf = .Stretch
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.seperatorLine1,self.seperatorText, self.seperatorLine2])
        a.alignSelf = .Stretch
        return a
    }
}

class ButtonHolder : ASDisplayNode {
    
    var regularLoginButton : LoginButtonNode!
    var facebookLoginButton : LoginButtonNode!
    var twitterLoginButton : LoginButtonNode!
    var seperatorNode : SeperatorNode!
    
    deinit {
//        print("deinit button holder")
    }
    
        override init() {
        super.init()
        
        var buttonHeight : CGFloat = 60
        
        let screenSize = UIScreen.mainScreen().bounds.size
        if screenSize.height < 600 {
            buttonHeight = 44
        } else {
            buttonHeight = 60
        }
        
        let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 1]
        
        let normalTitleString = NSAttributedString(string: "BORING SIGN UP FORM", attributes: attributes)
        let facebookTitleString = NSAttributedString(string: "JOIN WITH FACEBOOK", attributes: attributes)
        let twitterTitleString = NSAttributedString(string: "JOIN WITH TWITTER", attributes: attributes)
        
        self.regularLoginButton = LoginButtonNode(normalColor: UIColor(red: 236/255, green: 102/255, blue: 88/255, alpha: 1), selectedColor: UIColor(red: 236/255, green: 102/255, blue: 88/255, alpha: 1))
        self.regularLoginButton.minScale = 0.85
        self.regularLoginButton.flexShrink = true
        self.regularLoginButton.cornerRadius = 3
        self.regularLoginButton.alpha = 0
        self.regularLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.regularLoginButton.setAttributedTitle(normalTitleString, forState: ASControlState.Normal)
        
        self.seperatorNode = SeperatorNode()
        self.seperatorNode.alpha = 0
        self.seperatorNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: 15))
        
        self.facebookLoginButton = LoginButtonNode(normalColor: UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1), selectedColor: UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1))
        self.facebookLoginButton.alpha = 0
        self.facebookLoginButton.minScale = 0.85
        self.facebookLoginButton.setImage(UIImage(named: "facebook"), forState: ASControlState.Normal)
        self.facebookLoginButton.cornerRadius = 3
        self.facebookLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.facebookLoginButton.setAttributedTitle(facebookTitleString, forState: ASControlState.Normal)
        
        self.twitterLoginButton = LoginButtonNode(normalColor: UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1), selectedColor: UIColor(red: 0/255, green: 172/255, blue: 237/255, alpha: 1))
        self.twitterLoginButton.alpha = 0
        self.twitterLoginButton.minScale = 0.85
        self.twitterLoginButton.setImage(UIImage(named: "twitter"), forState: ASControlState.Normal)
        self.twitterLoginButton.cornerRadius = 3
        self.twitterLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.twitterLoginButton.setAttributedTitle(twitterTitleString, forState: ASControlState.Normal)
        
        
        
        self.addSubnode(self.regularLoginButton)
        self.addSubnode(self.seperatorNode)
        self.addSubnode(self.facebookLoginButton)
        self.addSubnode(self.twitterLoginButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let regularButtonStack = ASStaticLayoutSpec(children: [self.regularLoginButton])
        let facebookButtonStack = ASStaticLayoutSpec(children: [self.facebookLoginButton])
        let twitterButtonStack = ASStaticLayoutSpec(children: [self.twitterLoginButton])
        let seperatorStack = ASStaticLayoutSpec(children: [self.seperatorNode])
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [regularButtonStack, seperatorStack, facebookButtonStack, twitterButtonStack])
        
        return a
    }
}

class FormSwitcherNode : ASDisplayNode {
    var switchButton : ButtonNode!
    var textNode : ASTextNode!
    var targetForm : FormNodeState = .Login {
        didSet {
            didChangeState()
        }
    }
    
    deinit {
//        print("deinit FormSwitcherNode")
    }
    func didChangeState(){
        switch self.targetForm {
        case .Login :
            self.textNode.attributedString = NSAttributedString(string: "Already have an account?", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.51), NSKernAttributeName : 0.86])
            self.switchButton.setAttributedTitle(NSAttributedString(string: "LOGIN", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0]), forState: ASControlState.Normal)
            break
        case .Signup:
            self.textNode.attributedString = NSAttributedString(string: "Don't have an account?", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.51), NSKernAttributeName : 0.86])
            self.switchButton.setAttributedTitle(NSAttributedString(string: "SIGNUP", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0]), forState: ASControlState.Normal)
            break
        default:
            return
        }
        
        self.setNeedsLayout()
    }
        override init() {
        super.init()
        
        self.textNode = ASTextNode()
        self.textNode.attributedString = NSAttributedString(string: "Already have an account?", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.51), NSKernAttributeName : 0.86])
        
        self.switchButton = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
        self.switchButton.setAttributedTitle(NSAttributedString(string: "LOGIN", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.SynncColor()]), forState: ASControlState.Normal)
        self.switchButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(62, 30))
        self.switchButton.cornerRadius = 3
        self.switchButton.borderColor = UIColor.SynncColor().CGColor
        self.switchButton.borderWidth = 2
        
        self.addSubnode(self.textNode)
        self.addSubnode(self.switchButton)
        
        self.alignSelf = .Stretch
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.switchButton])
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [textNode, a])
    }
}


class SpinnerNode : ASDisplayNode {
    var spinnerHolder : ASDisplayNode!
    var msgNode : ASTextNode!
    
    var userImageNode : ASNetworkImageNode!
    var userLoginMsgNode : ASTextNode!
    
    deinit {
//        print("deinit spinner node")
    }
    
    var loginStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("loginStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SpinnerNode).loginStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SpinnerNode).loginStatusAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var loginStatusAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("loginStatusAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("loginStatusAnimation")
                }
                x.springBounciness = 0
                x.dynamicsFriction = 20
                x.property = self.loginStatusAnimatableProperty
                self.pop_addAnimation(x, forKey: "loginStatusAnimation")
                return x
            }
        }
    }
    var loginStatusAnimationProgress : CGFloat = 0 {
        didSet {
            let a = POPTransition(loginStatusAnimationProgress, startValue: 1, endValue: 0)
            msgNode.alpha = a
            
            POPLayerSetScaleXY(self.msgNode.layer, CGPointMake(a,a))
            
            let b = CGFloat(1-a)
            userLoginMsgNode.alpha = b
            POPLayerSetScaleXY(self.userImageNode.layer, CGPointMake(b,b))
            POPLayerSetScaleXY(self.userLoginMsgNode.layer, CGPointMake(b,b))
        }
    }
    
    
    var imageDisplayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("imageDisplayAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SpinnerNode).imageDisplayProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SpinnerNode).imageDisplayProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var imageDisplayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("imageDisplayAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("imageDisplayAnimation")
                }
                x.springBounciness = 0
                x.property = self.imageDisplayAnimatableProperty
                self.pop_addAnimation(x, forKey: "imageDisplayAnimation")
                return x
            }
        }
    }
    var imageDisplayProgress : CGFloat = 0 {
        didSet {
            POPLayerSetScaleXY(self.userImageNode.layer, CGPointMake(imageDisplayProgress,imageDisplayProgress))
            userImageNode.alpha = imageDisplayProgress
        }
    }
    
        override init() {
        super.init()
        
        self.spinnerHolder = ASDisplayNode()
        self.spinnerHolder.preferredFrameSize = CGSizeMake(75, 75)
        
        msgNode = ASTextNode()
        msgNode.attributedString = NSAttributedString(string: "Rolling a joint..", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
        msgNode.spacingBefore = 20
        
        userImageNode = ASNetworkImageNode()
        userImageNode.alpha = 0
        userImageNode.preferredFrameSize = CGSizeMake(75, 75)
//        userImageNode.imageModificationBlock = {
//            [unowned self]
//            img in
//            UIGraphicsBeginImageContextWithOptions(img.size, false, UIScreen.mainScreen().scale);
//            let rect = CGRectMake(0,0,img.size.width, img.size.height)
//            UIBezierPath(roundedRect: rect, cornerRadius: img.size.width / 2).addClip()
//            (img).drawInRect(rect)
//            
//            let circleimg = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            self.imageDisplayAnimation.toValue = 1
//            return circleimg
//        }
        
        userLoginMsgNode = ASTextNode()
        userLoginMsgNode.spacingBefore = 20
        userLoginMsgNode.alpha = 0
        
        
        self.addSubnode(userImageNode)
        self.addSubnode(userLoginMsgNode)
        self.addSubnode(msgNode)
        self.addSubnode(spinnerHolder)
    }
    
    func updateForUser(user: WCLUser) {
        
        let a = user.provider
        if let url = user.userExtension(WCLUserLoginType(rawValue: a)!)?.avatarUrl(userImageNode.bounds, scale: UIScreen.mainScreen().scale) {
            self.userImageNode.URL = url
        }
        userLoginMsgNode.attributedString = NSAttributedString(string: "Welcome back, \(user.name)", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
        self.setNeedsLayout()
    }
    override func didLoad() {
        super.didLoad()
        POPLayerSetScaleXY(self.userImageNode.layer, CGPointMake(0,0))
        POPLayerSetScaleXY(self.userLoginMsgNode.layer, CGPointMake(0,0))
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [self.spinnerHolder, self.msgNode])
        
        let y = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [self.userImageNode, self.userLoginMsgNode])
        
        return ASOverlayLayoutSpec(child: x, overlay: y)
    }
}
class FormNode : ASDisplayNode {
    
    var buttonHolder : ButtonHolder!
    var spinnerNode : SpinnerNode!
    var formSwitcher : FormSwitcherNode!
    var closeFormButton : ButtonNode!
    
    var formHolder : LSFormNode!
    
    deinit {
//        print("deinit form node")
        self.spinnerNode = nil
    }
    
    var serverCheckStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("serverStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! FormNode).serverCheckStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! FormNode).serverCheckStatusAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var serverCheckStatusAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("serverStatusAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("serverStatusAnimation")
                }
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.serverCheckStatusAnimatableProperty
                self.pop_addAnimation(x, forKey: "serverStatusAnimation")
                return x
            }
        }
    }
    var serverCheckStatusAnimationProgress : CGFloat = 0 {
        didSet {
            let a = POPTransition(serverCheckStatusAnimationProgress, startValue: 1, endValue: 0)
            self.buttonHolder.regularLoginButton.alpha = a
            self.buttonHolder.twitterLoginButton.alpha = a
            self.buttonHolder.facebookLoginButton.alpha = a
            self.buttonHolder.seperatorNode.alpha = a
            self.formSwitcher.alpha = a
            
            self.spinnerNode.alpha = 1-a
        }
    }
    var closeButtonY : CGFloat {
        get {
            let screenSize = UIScreen.mainScreen().bounds.size
            if screenSize.height < 600 {
                return 0
            } else {
                return 10
            }
        }
    }
    var buttonHolderAlpha : CGFloat = 0
    var formSwitcherAlpha : CGFloat = 0
    
    var formDisplayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! FormNode).fullDisplayProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! FormNode).fullDisplayProgress = values[0]
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
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.formDisplayAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    var fullDisplayProgress : CGFloat = -1 {
        didSet {
            let positionY = POPTransition(fullDisplayProgress, startValue: self.calculatedSize.height, endValue: self.calculatedSize.height / 2)
           
            buttonHolderAlpha = max(0,min(1,POPTransition(fullDisplayProgress, startValue: 1, endValue: 0)))
            
            let closeButtonAlpha = POPTransition(fullDisplayProgress, startValue: 0, endValue: 1)
            let tbyMax = self.calculatedSize.height - (self.formSwitcher.frame.height / 2) - 10
            let tbyMin = self.calculatedSize.height / 2 - (self.formSwitcher.frame.height / 2) - 10
            let textButtonY = POPTransition(fullDisplayProgress, startValue: tbyMin, endValue: tbyMax)
            
            self.position = CGPoint(x: self.position.x, y: positionY)
            self.buttonHolder.alpha = buttonHolderAlpha
            self.closeFormButton.alpha = closeButtonAlpha
            self.formSwitcher.position.y = textButtonY
        }
    }
    
        override init() {
        super.init()
        
        self.buttonHolder = ButtonHolder()
        
        self.closeFormButton = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
        self.closeFormButton.minScale = 0.85
        self.closeFormButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(44, 44))
        self.closeFormButton.imageNode.preferredFrameSize = CGSizeMake(15, 15)
        self.closeFormButton.imageNode.contentMode = .Center
        self.closeFormButton.alpha = 0
        self.closeFormButton.setImage(UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate), forState: ASControlState.Normal)
//        self.closeFormButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.blackColor().colorWithAlphaComponent(0.6))
        
        self.formHolder = LSFormNode()
        
        self.formSwitcher = FormSwitcherNode()
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.spinnerNode = SpinnerNode()
        self.spinnerNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.spinnerNode.alpha = 0
        
        self.addSubnode(self.formHolder)
        self.addSubnode(self.buttonHolder)
        self.addSubnode(self.spinnerNode)
        self.addSubnode(self.formSwitcher)
        self.addSubnode(self.closeFormButton)
    }
    override func didLoad() {
        super.didLoad()
    }
    
    var formDisplayStatus : Bool! {
        didSet {
            if formDisplayStatus != oldValue {
                if !formDisplayStatus && self.formHolder.isFirstResponder() {
                    self.formHolder.resignFirstResponder()
                }
                self.formDisplayAnimation.toValue = formDisplayStatus! ? 1 : 0
            }
        }
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
        let a = fullDisplayProgress
        self.fullDisplayProgress = a
    }
    override func layout() {
        super.layout()
        let size = self.calculatedSize
        
        self.closeFormButton.position.x = size.width - self.closeFormButton.calculatedSize.width/2 - 10
        self.closeFormButton.position.y += closeButtonY
        
        let x = self.calculatedSize.height / 2 - (self.formSwitcher.frame.height) - 15
        self.buttonHolder.position = CGPoint(x: self.calculatedSize.width / 2, y: x/2)
        self.spinnerNode.position = self.buttonHolder.position
        self.formSwitcher.position.x = size.width / 2
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.spinnerNode])
        let b = ASOverlayLayoutSpec(child: self.buttonHolder, overlay: a)
        let x = ASStaticLayoutSpec(children: [self.formHolder, b, self.closeFormButton, self.formSwitcher])
        
        return x
    }
}

class BackgroundNode : ASDisplayNode {
    var logoHolder : AnimatedLogoNode!
    var titleNode : ASTextNode!
    
    deinit {
//        print("deinit background node")
    }
    
        override init() {
        super.init()
        
        self.logoHolder = AnimatedLogoNode(barCount: 15)
        
        self.titleNode = ASTextNode()
        self.titleNode.spacingBefore = 20
        self.titleNode.attributedString = NSAttributedString(string: "SYNNC", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 32)!, NSForegroundColorAttributeName : UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1), NSKernAttributeName : 2])
        
        self.addSubnode(self.logoHolder)
        self.addSubnode(self.titleNode)
    }
    override func layout() {
        super.layout()
        self.logoHolder.position.x = self.calculatedSize.width - self.logoHolder.calculatedSize.width / 2
        self.logoHolder.position.y = self.titleNode.position.y
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexBasis = ASRelativeDimension(type: .Percent, value: 0.1)
        
        let bottomSpacer = ASLayoutSpec()
        bottomSpacer.flexGrow = true
        
        self.logoHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 50))
        let c = ASStaticLayoutSpec(children: [self.logoHolder])
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [spacer, titleNode, c, bottomSpacer])
        
        
        return x
    }
}

class LoginNode : ASDisplayNode {
    
    var formNode : FormNode!
    var backgroundNode : BackgroundNode!
    
    deinit {
//        print("deinit login node")
    }
    
        override init() {
        super.init()
        
        self.backgroundNode = BackgroundNode()
        self.backgroundNode.backgroundColor = UIColor.whiteColor()
      
        self.formNode = FormNode()
        self.formNode.backgroundColor = UIColor.whiteColor()
        self.formNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.addSubnode(backgroundNode)
        self.addSubnode(formNode)
        backgroundColor = UIColor.clearColor()
    }

    override func layout() {
        super.layout()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        let a = ASStaticLayoutSpec(children: [formNode])
        let x = ASBackgroundLayoutSpec(child: a, background: backgroundNode)
        return x
    }
    
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LoginNode).displayProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LoginNode).displayProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("scaleAnimation")
                }
                x.springBounciness = 0
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    var displayProgress : CGFloat = 1 {
        didSet {
            let positionY = POPTransition(displayProgress, startValue: self.calculatedSize.height, endValue: 0)
            POPLayerSetTranslationY(self.layer, positionY)
            
            let min = self.calculatedSize.width - self.backgroundNode.logoHolder.calculatedSize.width / 2
            let max = self.calculatedSize.width + self.backgroundNode.logoHolder.calculatedSize.width / 2
            
            let x = POPTransition(displayProgress, startValue: min, endValue: max)
            POPLayerSetTranslationX(self.backgroundNode.logoHolder.layer, x)
            self.backgroundNode.logoHolder.alpha = displayProgress
        }
    }
}
