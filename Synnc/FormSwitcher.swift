//
//  FormSwitcher.swift
//  Synnc
//
//  Created by Arda Erzin on 3/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class FormSwitcherNode : ASDisplayNode {
    var switchButton : ButtonNode!
    var textNode : ASTextNode!
    
    var state : LoginNodeState! {
        didSet {
            self.targetState = state == .Login ? .Signup : state == .Signup ? .Login : .None
        }
    }
    var targetState : LoginNodeState = .Signup {
        didSet {
            didSetState()
        }
    }
    
    func didSetState(){
        switch self.targetState {
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
        
        self.didSetState()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.switchButton])
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [textNode, a])
    }
}
