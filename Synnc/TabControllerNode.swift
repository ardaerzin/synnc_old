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
import SpinKit
import WCLUserManager
import DeviceKit

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
    
    var tabbar : TabNode!
    var contentHolder : ASDisplayNode!
    
//    var headerNode : HeaderNode!
//    var scrollNode : TabbarContentScroller!
//    var navigationNode : NavigationHolderNode!
    
    var item: TabItem!
    
    init(items: [TabItem]) {
        super.init()
        
        tabbar = TabNode(tabbarItems: items)
        tabbar.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        
        contentHolder = ASDisplayNode()
//        contentHolder.backgroundColor = UIColor.redColor()
        
//        headerNode = HeaderNode()
//        headerNode.flexBasis = ASRelativeDimension(type: .Points, value: 130)
        
//        navigationNode = NavigationHolderNode()
//        navigationNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        scrollNode = TabbarContentScroller()
//        scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        scrollNode.backgroundColor = UIColor.whiteColor()
//        scrollNode.delegate = self
//
//        self.headerNode.subSectionArea.delegate = self.scrollNode
        
        self.backgroundColor = UIColor.whiteColor()
        
//        self.addSubnode(scrollNode)
//        self.addSubnode(headerNode)
//        self.addSubnode(navigationNode)
        
        self.addSubnode(contentHolder)
        self.addSubnode(tabbar)
    }
    
    override func layout() {
        super.layout()
        self.tabbar.position.y = self.calculatedSize.height - (self.tabbar.calculatedSize.height / 2)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        self.contentHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        let subsectionCount = item != nil ? item.subsections.count : 0
//        self.scrollNode.view.contentSize = CGSizeMake(constrainedSize.max.width * CGFloat(subsectionCount), constrainedSize.max.height)
        return ASStaticLayoutSpec(children: [self.tabbar, self.contentHolder])
    }
}

//extension TabControllerNode : TabbarContentScrollerDelegate {
//    func didScrollToRatio(ratio: CGFloat) {
//        let subsection = self.headerNode.subSectionArea
//        let a = POPTransition(ratio, startValue: subsection.minX, endValue: subsection.maxX)
//        subsection.currentIndicatorPosition = a
//    }
//    func didChangeCurrentIndex(index: Int) {
//        self.item.selectedIndex = index
//        self.headerNode.subSectionArea.selectedSubsectionIndex = index
//    }
//    func updateForItem(item: TabItem){
//        self.headerNode.updateForItem(item)
////        self.scrollNode.updateForItem(item)
//        didChangeCurrentIndex(item.selectedIndex)
//    }
//    func beganScrolling() {
//        self.headerNode.subSectionArea.pop_removeAnimationForKey("indicatorPositionAnimation")
//    }
//}