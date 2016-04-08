//
//  ProfileNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUserManager
import pop

class ProfileHolder : ASDisplayNode, TrackedView {
    var title : String! = "Profile Node"
    var profile : ProfileNode!
    override init() {
        super.init()
        self.profile = ProfileNode()
        self.profile.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(profile)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [profile])
    }
}

class ProfileNode : ASScrollNode {
    
    var profileTitle : ASTextNode!
    var profileCard : ProfileCardNode!
    
    override init() {
        super.init()
        
        profileTitle = ASTextNode()
        profileTitle.attributedString = NSAttributedString(string: "USER INFO", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        profileTitle.spacingBefore = 90
        profileTitle.spacingAfter = 7
        self.addSubnode(profileTitle)
        
        profileCard = ProfileCardNode()
        self.addSubnode(profileCard)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        self.view.contentSize = CGSizeMake(self.calculatedSize.width, self.profileCard.position.y + (self.profileCard.calculatedSize.height / 2) + 20)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent:.Start, alignItems: .Center, children: [profileTitle, profileCard])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 35, 0, 35), child: stack)
    }
    
}