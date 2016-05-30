//
//  InviteNode.swift
//  Synnc
//
//  Created by Arda Erzin on 5/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class InviteNode : CardNodeBase {
    
    var feedbackArea : ASEditableTextNode!
    var sendButton : ButtonNode!
    
    override init() {
        super.init()
        
        feedbackArea = ASEditableTextNode()
        
        feedbackArea.typingAttributes =  [NSFontAttributeName : UIFont(name: "Ubuntu", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)]
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        feedbackArea.attributedPlaceholderText = NSAttributedString(string: "Email of your friend", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 158/255, green: 158/255, blue: 158/255, alpha: 0.5), NSParagraphStyleAttributeName : p])
        
        self.addSubnode(feedbackArea)
        feedbackArea.scrollEnabled = false
        
    }
    
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        feedbackArea.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 25))
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [feedbackArea])])
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(20, 20, 20, 20), child: x)
    }
}