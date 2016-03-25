//
//  HomeHeaderNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class PagerHeaderNode : ASDisplayNode {
    
    var leftButtonHolder : PagerHeaderIconNode!
    var rightButtonHolder : PagerHeaderIconNode!
    var titleHolder : PagerHeaderTitleNode!
    var pageControl : PageControlNode!
    
    init(backgroundColor : UIColor? = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1), height: CGFloat? = 60, pageControlColor : UIColor? = UIColor.lightGrayColor(), pageControlSelectedColor : UIColor? = UIColor.blackColor()) {
        super.init()
        
        self.backgroundColor = backgroundColor
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: height!))
        
        pageControl = PageControlNode()
        self.addSubnode(pageControl)
        
        titleHolder = PagerHeaderTitleNode()
        titleHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 20))
        self.addSubnode(titleHolder)
        
        pageControl.pageIndicatorTintColor = pageControlColor
        pageControl.currentPageIndicatorTintColor = pageControlSelectedColor
        
        leftButtonHolder = PagerHeaderIconNode()
        leftButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30,30))
        self.addSubnode(leftButtonHolder)
        
        rightButtonHolder = PagerHeaderIconNode()
        rightButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30,30))
        self.addSubnode(rightButtonHolder)
    }
    
    override func layout() {
        super.layout()
        
        leftButtonHolder.position.y = self.position.y
        leftButtonHolder.position.x = (leftButtonHolder.calculatedSize.width / 2) + 15
            
        rightButtonHolder.position.y = self.position.y
        rightButtonHolder.position.x = self.calculatedSize.width - ((rightButtonHolder.calculatedSize.width / 2) + 15)
        
        titleHolder.position.x = self.calculatedSize.width / 2
        titleHolder.position.y = self.calculatedSize.height / 2 - 10
        
        pageControl.position.x = self.calculatedSize.width / 2
        pageControl.position.y = titleHolder.position.y + (titleHolder.calculatedSize.height / 2) + 15
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [pageControl, leftButtonHolder, rightButtonHolder, titleHolder])
    }
    
    func update(scrollPosition : CGFloat) {
        self.leftButtonHolder.update(scrollPosition: scrollPosition)
        self.rightButtonHolder.update(scrollPosition: scrollPosition)
        self.titleHolder.update(scrollPosition: scrollPosition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}