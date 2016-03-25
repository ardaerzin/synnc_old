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
    
    var facebookLoginButton : LoginButtonNode!
    var twitterLoginButton : LoginButtonNode!
    
    var buttonHeight : CGFloat = 50

    var translationY : CGFloat = 0
    var maxTranslationY : CGFloat = 0

    override init() {
        super.init()
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : p]
              
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
        
        self.addSubnode(self.facebookLoginButton)
        self.addSubnode(self.twitterLoginButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let facebookButtonStack = ASStaticLayoutSpec(children: [self.facebookLoginButton])
        let twitterButtonStack = ASStaticLayoutSpec(children: [self.twitterLoginButton])
        
        let socialSpacer = ASLayoutSpec()
        socialSpacer.flexGrow = true
        
        self.facebookLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        self.twitterLoginButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.75), ASRelativeDimension(type: .Points, value: buttonHeight))
        
        let socialLoginStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [facebookButtonStack, socialSpacer, twitterButtonStack])
        socialLoginStack.alignSelf = .Stretch
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [facebookButtonStack, twitterButtonStack])
        
        return a
    }
}