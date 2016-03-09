//
//  LoginSeperatorNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class SeperatorNode : ASDisplayNode {
    var seperatorLine1 : ASDisplayNode!
    var seperatorLine2 : ASDisplayNode!
    var seperatorText : ASTextNode!
    
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