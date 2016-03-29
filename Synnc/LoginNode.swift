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
import FBSDKCoreKit
import FBSDKLoginKit

enum LoginNodeState : Int {
    case None = -1
    case Login = 0
    case Signup = 1
}

class LoginNode : ASDisplayNode, TrackedView {
    
    var title : String! = "LoginView"
    
    
    var brandNode : LoginBrandNode!
    var buttonHolder : ButtonHolder!
    var spinnerNode : SpinnerNode!
    var legal : ASTextNode!

    var state : LoginNodeState! = .None {
        didSet {
//            self.buttonHolder.state = state
        }
    }
    
    var panRecognizer : UIPanGestureRecognizer! {
        didSet {
            if let p = panRecognizer {
                self.view.addGestureRecognizer(p)
            }
        }
    }
    
    var mask : CAShapeLayer!
    var toggleButtonHolder : LoginToggleButtonHolder!
    var toggleButton : ButtonNode! {
        get {
            return self.toggleButtonHolder.toggleButton
        }
    }
    var toggleIndicator : ASImageNode!
    
    var translationY : CGFloat! {
        didSet{
            POPLayerSetTranslationY(self.layer, translationY)
        }
    }
    
    deinit {
        self.spinnerNode = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    override init() {
        super.init()
        
        self.buttonHolder = ButtonHolder()
        
        self.brandNode = LoginBrandNode()
        self.brandNode.alignSelf = .Stretch
        
        self.spinnerNode = SpinnerNode()
        self.spinnerNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.spinnerNode.alpha = 0
        
        self.legal = ASTextNode()
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        toggleButtonHolder = LoginToggleButtonHolder()
        toggleButtonHolder.backgroundColor = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)
        toggleButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 60))
        self.addSubnode(toggleButtonHolder)
        
        toggleIndicator = ASImageNode()
        toggleIndicator.image = UIImage(named: "chevron-up")
        toggleIndicator.contentMode = .ScaleAspectFit
        toggleIndicator.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(15,15))
        
        self.addSubnode(self.brandNode)
        self.addSubnode(self.buttonHolder)
        self.addSubnode(toggleIndicator)
        self.addSubnode(self.spinnerNode)
        self.addSubnode(legal)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginNode.serverStatusChanged(_:)), name: "SERVER STATUS CHANGED", object: nil)
    }
    
    override func didLoad() {
        super.didLoad()
        self.spinnerNode.state = .ServerConnect
        serverCheckStatusAnimationProgress = 1
    }
    override func fetchData() {
        let str = NSAttributedString(string: "Login", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName: 0.5])
        toggleButton.setAttributedTitle(str, forState: .Normal)
        
        
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
        
        self.setNeedsLayout()
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if mask != nil {
            return
        }
        
        let roundedCorners : UIRectCorner = [.TopLeft, .TopRight]
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = CGRect(origin: CGPointZero, size: self.calculatedSize)
        rectShape.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2)
        rectShape.path = UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: self.calculatedSize), byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: 10, height: 10)).CGPath
        
        rectShape.backgroundColor = UIColor.clearColor().CGColor
        self.layer.mask = rectShape
    }
    
    override func layout() {
        super.layout()
        
        toggleIndicator.position.y = toggleButtonHolder.position.y
        toggleIndicator.position.x = self.calculatedSize.width - (toggleIndicator.calculatedSize.width / 2) - 20
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.spinnerNode])
        let b = ASOverlayLayoutSpec(child: self.buttonHolder, overlay: a)
        
        self.brandNode.spacingBefore = 75
        
        let spacerTop = ASLayoutSpec()
        spacerTop.flexGrow = true
        
        b.spacingAfter = 50
        
        let l = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 50, 0, 50), child: legal)
        l.spacingAfter = 10
        
        let x = ASStaticLayoutSpec(children: [toggleButtonHolder, toggleIndicator])
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [x, brandNode, spacerTop, b, l])
    }
    
    
    func serverStatusChanged(notification : NSNotification){
        if let info = notification.userInfo, let status = info["status"] as? Bool {
            if status {
                self.spinnerNode.state = .LoggingIn
                if let _ = FBSDKAccessToken.currentAccessToken() {
                } else {
                    serverCheckStatusAnimation.toValue = 0
                }
            }
        }
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
//            self.legal.alpha = a
            
            self.spinnerNode.alpha = 1-a
        }
    }
    
    
    
    
    
    
    var loginStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("loginStatusAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! LoginNode).loginStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! LoginNode).loginStatusAnimationProgress = values[0]
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
                x.springSpeed = 1
                x.springBounciness = 0
                x.property = self.loginStatusAnimatableProperty
                self.pop_addAnimation(x, forKey: "loginStatusAnimation")
                return x
            }
        }
    }
    var loginStatusAnimationProgress : CGFloat = 0 {
        didSet {
            let alpha = 1-loginStatusAnimationProgress
            
            let brandTransition = POPTransition(loginStatusAnimationProgress, startValue: 0, endValue: -self.brandNode.calculatedSize.height/2)
            
            self.brandNode.alpha = alpha
            POPLayerSetTranslationY(self.brandNode.layer, brandTransition)
            
            let legalTransition = POPTransition(loginStatusAnimationProgress, startValue: 0, endValue: self.calculatedSize.height + self.legal.calculatedSize.height/2)
            
            self.legal.alpha = alpha
            POPLayerSetTranslationY(self.legal.layer, legalTransition)
            
            self.spinnerNode.alpha = alpha
        }
    }
}