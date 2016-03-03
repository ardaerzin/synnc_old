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
        
        let layout = ASPagerFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        scrollNode = TabbarContentScroller(collectionViewLayout: layout)
        scrollNode.flexGrow = true
        scrollNode.alignSelf = .Stretch
//        (frame: UIScreen.mainScreen.bounds, collectionViewLayout: <#T##UICollectionViewLayout#>)
        scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.headerNode.subSectionArea.delegate = self.scrollNode
//        self.scrollNode.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(self.scrollNode)
        self.addSubnode(self.headerNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.headerNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, 130))
        return ASStaticLayoutSpec(children: [self.headerNode, self.scrollNode])
//        return ASStaticLayoutSpec(children: [self.scrollNode])
//            ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [scrollNode])
    }
}