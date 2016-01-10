//
//  TabItemNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/25/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class NavigationHolderNode : ASDisplayNode {
    var headerNode : HeaderNode!
    var scrollNode : TabbarContentScroller!
    
        override init() {
        super.init()
        
        self.headerNode = HeaderNode()
        
        scrollNode = TabbarContentScroller()
        scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        scrollNode.backgroundColor = UIColor.whiteColor()
//        scrollNode.delegate = self
        
        self.headerNode.subSectionArea.delegate = self.scrollNode
        self.scrollNode.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(self.scrollNode)
        self.addSubnode(self.headerNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.headerNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, 130))
        return ASStaticLayoutSpec(children: [self.headerNode, self.scrollNode])
    }
//    override func hitTest(point: CGPoint, withEvent event: UIEvent!) -> UIView! {
//        
//        if let ht = super.hitTest(point, withEvent: event) {
//            if ht == self.view {
//                return nil
//            } else {
//                return ht
//            }
//        }
//        return nil
//    }
}