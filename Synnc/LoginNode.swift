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
import WCLUserManager

class SpinnerNode : ASDisplayNode {
    var spinnerHolder : ASDisplayNode!
    var msgNode : ASTextNode!
    
    var userImageNode : ASNetworkImageNode!
    var userLoginMsgNode : ASTextNode!
    
    deinit {
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
        msgNode.attributedString = NSAttributedString(string: "Logging you in..", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
        msgNode.spacingBefore = 20
        
        userImageNode = ASNetworkImageNode()
        userImageNode.alpha = 0
        userImageNode.preferredFrameSize = CGSizeMake(75, 75)
        userImageNode.cornerRadius = 5
        
        userLoginMsgNode = ASTextNode()
        userLoginMsgNode.spacingBefore = 20
        userLoginMsgNode.alpha = 0
        
        
        self.addSubnode(userImageNode)
        self.addSubnode(userLoginMsgNode)
        self.addSubnode(msgNode)
        self.addSubnode(spinnerHolder)
    }
    
    func updateForUser(user: MainUser) {
        
        let a = user.provider
        if let url = user.userExtension(WCLUserLoginType(rawValue: a)!)?.avatarUrl(userImageNode.bounds, scale: UIScreen.mainScreen().scale) {
            self.userImageNode.URL = url
            self.imageDisplayAnimation.toValue = 1
        }
        
        var welcomeMsg : String = "Welcome back,"
        if user.generatedUsername {
            welcomeMsg = "Welcome"
        }
        let str = NSMutableAttributedString(string: welcomeMsg + " \(user.name)", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
        str.addAttribute(NSFontAttributeName, value: UIFont(name: "Ubuntu", size: 18)!, range: str.string.NSRangeFromRange(str.string.rangeOfString(user.name)!))
        userLoginMsgNode.attributedString = str
        
        
        self.fetchData()
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

enum LoginNodeState : Int {
    case None = -1
    case Login = 0
    case Signup = 1
}
enum LoginNodeKeyboardState : Int {
    case Down = 0
    case Up = 1
}
typealias NodeKeyboardState = (state: LoginNodeKeyboardState, frame: CGRect)

class LoginNode : ASDisplayNode, TrackedView {
    
    var title : String! = "LoginView"
    
    var brandNode : LoginBrandNode!
    var buttonHolder : ButtonHolder!
    var spinnerNode : SpinnerNode!
    var formSwitcher : FormSwitcherNode!
    var formHolder : LSFormNode!
    var legal : ASTextNode!
    
    var keyboardState : NodeKeyboardState! {
        didSet {
            self.buttonHolder.keyboardState = keyboardState
        }
    }
    var state : LoginNodeState! = .None {
        didSet {
            self.formHolder.state = state
            self.formSwitcher.state = state
            self.buttonHolder.state = state
        }
    }
    
    deinit {
        self.spinnerNode = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        self.formHolder.resignFirstResponder()
    }
    
    override init() {
        super.init()
        
        self.buttonHolder = ButtonHolder()
        
        self.formHolder = LSFormNode()
        self.formSwitcher = FormSwitcherNode()
        
        self.brandNode = LoginBrandNode()
        self.brandNode.alignSelf = .Stretch
        
        self.spinnerNode = SpinnerNode()
        self.spinnerNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.spinnerNode.alpha = 0
        
        self.legal = ASTextNode()
        
//        var str = NSMutableAttributedString()
//        str.appendAttributedString(<#T##attrString: NSAttributedString##NSAttributedString#>)
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6)]
        let linkAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor.blackColor()]
        
        let str1 = NSAttributedString(string: "By using Synnc, you agree to the ", attributes: attributes)
        
        var x = linkAttributes
        x[NSLinkAttributeName] = NSURL(string: "https://synnc.live/privacy/")!
        let str2 = NSAttributedString(string: "Privacy Policy", attributes: x)
        
        let str3 = NSAttributedString(string: " and ", attributes: attributes)
        
        var y = linkAttributes
        y[NSLinkAttributeName] = NSURL(string: "https://synnc.live/terms/")!
        let str4 = NSAttributedString(string: "Terms of Service.", attributes: y)
        
        let mutableStr = NSMutableAttributedString()
        mutableStr.appendAttributedString(str1)
        mutableStr.appendAttributedString(str2)
        mutableStr.appendAttributedString(str3)
        mutableStr.appendAttributedString(str4)
        let r = mutableStr.string.NSRangeFromRange(mutableStr.string.rangeOfString(mutableStr.string)!)
        mutableStr.addAttribute(NSParagraphStyleAttributeName, value: p, range: r)
        mutableStr.addAttribute(NSUnderlineColorAttributeName, value: UIColor.clearColor(), range: r)
        
        self.legal.attributedString = mutableStr
        
        self.addSubnode(self.brandNode)
//        self.addSubnode(self.formHolder)
        self.addSubnode(self.buttonHolder)
        self.addSubnode(self.spinnerNode)
//        self.addSubnode(self.formSwitcher)
        self.addSubnode(legal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        let a = KeyboardAnimationInfo(dict: notification.userInfo!)
        
        if CGRectGetMinY(a.finalFrame) - self.calculatedSize.height <= 0 {
            self.keyboardState = (.Down,a.finalFrame)
        } else {
            self.keyboardState = (.Up,a.finalFrame)
        }
    }

    override func layoutDidFinish() {
        super.layoutDidFinish()
        if self.state == .None {
            self.state = .Login
        }
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.spinnerNode])
        let b = ASOverlayLayoutSpec(child: self.buttonHolder, overlay: a)
        
        self.brandNode.spacingBefore = 75
        self.formSwitcher.spacingAfter = 10
        
        let spacerTop = ASLayoutSpec()
        spacerTop.flexGrow = true
        
        let spacerBottom = ASLayoutSpec()
        spacerBottom.flexGrow = true
        
        let spacerB = ASLayoutSpec()
        spacerB.flexGrow = true
        
        b.spacingAfter = 50
        
        self.formHolder.flexGrow = true
        
        let l = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 50, 0, 50), child: legal)
        l.spacingAfter = 10
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.brandNode, spacerTop, b, l])
        
        return x
    }
    
    var serverCheckStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("serverStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LoginNode).serverCheckStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LoginNode).serverCheckStatusAnimationProgress = values[0]
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
            self.buttonHolder.alpha = a
            self.formSwitcher.alpha = a
            self.legal.alpha = a
            
            self.spinnerNode.alpha = 1-a
        }
    }
}