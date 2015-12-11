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

class TabControllerNode : ASDisplayNode {
    
    var tabbar : TabNode!
    var headerNode : HeaderNode!
    var blurView : UIVisualEffectView!
    var scrollNode : TabbarContentScroller!
    var item: TabItem!
    
    override init!() {
        
        print("init")
        super.init()
        tabbar = TabNode()
        tabbar.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        
        headerNode = HeaderNode()
        headerNode.flexBasis = ASRelativeDimension(type: .Points, value: 130)
        
        self.scrollNode = TabbarContentScroller()
        self.scrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.scrollNode.backgroundColor = UIColor.whiteColor()
        self.scrollNode.delegate = self
        
        self.headerNode.subSectionArea.delegate = self.scrollNode
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(scrollNode)
        self.addSubnode(headerNode)
        self.addSubnode(tabbar)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let subsectionCount = item != nil ? item.subsections.count : 0
        self.scrollNode.view.contentSize = CGSizeMake(constrainedSize.max.width * CGFloat(subsectionCount), constrainedSize.max.height)
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [headerNode, spacer, tabbar])
        return ASBackgroundLayoutSpec(child: a, background: self.scrollNode)
    }
}

extension TabControllerNode : TabbarContentScrollerDelegate {
    func didScrollToRatio(ratio: CGFloat) {
        let subsection = self.headerNode.subSectionArea
        let a = POPTransition(ratio, startValue: subsection.minX, endValue: subsection.maxX)
        subsection.currentIndicatorPosition = a
    }
    func didChangeCurrentIndex(index: Int) {
        self.item.selectedIndex = index
        self.headerNode.subSectionArea.selectedSubsectionIndex = index
    }
    func updateForItem(item: TabItem){
        self.headerNode.updateForItem(item)
        self.scrollNode.updateForItem(item)
        didChangeCurrentIndex(item.selectedIndex)
    }
    func beganScrolling() {
        self.headerNode.subSectionArea.pop_removeAnimationForKey("indicatorPositionAnimation")
    }
}