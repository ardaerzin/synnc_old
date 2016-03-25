//
//  TabControllerNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/9/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager

extension ASDisplayNode {
    var tabControllerNode : TabControllerNode! {
        get {
            if let tb = self as? TabControllerNode {
                return tb
            } else if let sn = self.supernode {
                return sn.tabControllerNode
            } else {
                return nil
            }
        }
    }
}

class TabControllerNode : ASDisplayNode {
    
    var contentHolder : ASDisplayNode!

    var item: TabItem!
    
    init(items: [TabItem]) {
        super.init()
        
        contentHolder = ASDisplayNode()
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(contentHolder)
    }
    
    override func layout() {
        super.layout()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        self.contentHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        return ASStaticLayoutSpec(children: [self.contentHolder])
    }
}