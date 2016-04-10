//
//  SettingsNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox

class SettingsHolder : ASDisplayNode, TrackedView {
    var title : String! = "Settings Node"
    var settingsNode : SettingsNode!
    override init() {
        super.init()
        settingsNode = SettingsNode()
        settingsNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(settingsNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [settingsNode])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
    }
}

class SettingsNode : ASScrollNode {
    
    var loginSourcesTitle : ASTextNode!
    var loginSourcesNode : LoginSourceNode!
    
    var aboutTitle : ASTextNode!
    var aboutNode : AboutNode!
    
    var feedbackTitle : ASTextNode!
    var feedbackNode : FeedbackNode!
    
    var disconnectButton : ButtonNode!
    
    var contentSizeDiff : CGFloat! = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        
        loginSourcesTitle = ASTextNode()
        loginSourcesTitle.attributedString = NSAttributedString(string: "SYNCED ACCOUNTS", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        loginSourcesTitle.spacingBefore = 90
        loginSourcesTitle.spacingAfter = 10
        self.addSubnode(loginSourcesTitle)
        
        loginSourcesNode = LoginSourceNode()
        loginSourcesNode.alignSelf = .Stretch
        self.addSubnode(loginSourcesNode)
        
        aboutTitle = ASTextNode()
        aboutTitle.attributedString = NSAttributedString(string: "ABOUT", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        aboutTitle.spacingBefore = 20
        aboutTitle.spacingAfter = 10
        self.addSubnode(aboutTitle)
        
        aboutNode = AboutNode()
        aboutNode.alignSelf = .Stretch
        self.addSubnode(aboutNode)
        
        feedbackTitle = ASTextNode()
        feedbackTitle.attributedString = NSAttributedString(string: "FEEDBACK", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        feedbackTitle.spacingBefore = 20
        feedbackTitle.spacingAfter = 10
        self.addSubnode(feedbackTitle)
        
        feedbackNode = FeedbackNode()
        feedbackNode.alignSelf = .Stretch
        self.addSubnode(feedbackNode)
        
        disconnectButton = ButtonNode()
        let title = NSAttributedString(string: "logout", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1), NSKernAttributeName : 0.7])
        disconnectButton.setAttributedTitle(title, forState: .Normal)
        disconnectButton.spacingBefore = 20
        self.addSubnode(disconnectButton)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        self.view.contentSize = CGSizeMake(self.calculatedSize.width, self.disconnectButton.position.y + (self.disconnectButton.calculatedSize.height / 2) + 20 + 65 + contentSizeDiff)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent:.Start, alignItems: .Center, children: [loginSourcesTitle, loginSourcesNode, aboutTitle, aboutNode, feedbackTitle, feedbackNode, disconnectButton])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 35, 0, 35), child: stack)
    }
}