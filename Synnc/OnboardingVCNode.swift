//
//  OnboardingVCNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/23/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnboardingVCNode : ASDisplayNode, TrackedView {
    
    var title : String! = "OnboardingView"
    var pager : OnboardingPager!
    var pageControl : UIPageControl!
    
    
    override init() {
        super.init()
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        pageControl = UIPageControl()
        pageControl.defersCurrentPageDisplay = true
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        
        let layout = ASPagerFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        pager = OnboardingPager(collectionViewLayout: layout)
        
        self.addSubnode(pager)
        self.view.addSubview(pageControl)
    }
    
    override func layout() {
        super.layout()
        
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        pageControl.frame = CGRect(x: self.calculatedSize.width / 2 - size.width / 2, y: (pager.calculatedSize.height / 2 + pager.position.y), width: size.width, height: size.height)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let cardHolder = ASStaticLayoutSpec(children: [pager])
        
        let x : CGFloat = 10
        
        //diff = bottom spacing + top spacing
        let diff : CGFloat = (37 + 2*x) + 20 + x
        
        pager.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.8), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - diff))
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 40, justifyContent: .Center, alignItems: .Center, children: [cardHolder])
    }
    
}