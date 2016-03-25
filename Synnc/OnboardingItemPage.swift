//
//  OnboardingPage.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnboardingItemPage : ASCellNode {
    
    var titleNode : ASTextNode!
    var titleAttributes : [String : AnyObject] {
        get {
            let paragraphAtrributes = NSMutableParagraphStyle()
            paragraphAtrributes.alignment = .Center
            return [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.blackColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]
        }
    }
    var item : OnboardingItem!
    
    override func fetchData() {
        super.fetchData()
        titleNode.attributedString = NSAttributedString(string: item.title, attributes: titleAttributes)
        self.setNeedsLayout()
    }
    init(item : OnboardingItem) {
        super.init()
        self.item = item
        titleNode = ASTextNode()
        
        self.addSubnode(titleNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleNode])
    }
}