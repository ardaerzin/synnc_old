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

protocol PagerHeaderDelegate {
    func pagerHeaderDidTapOnHeeader(header : PagerHeaderNode)
    func pagerHeader(header: PagerHeaderNode, didSelectPageControl direction: Int)
}

class PagerHeaderNode : ASDisplayNode {
    
    var delegate : PagerHeaderDelegate?
    var leftButtonHolder : PagerHeaderIconNode!
    var rightButtonHolder : PagerHeaderIconNode!
    var titleHolder : PagerHeaderTitleNode!
    var pageControl : PageControlNode!

    init(backgroundColor : UIColor? = UIColor.SynncColor(), height: CGFloat? = 60) {
        
        super.init()
        
        self.backgroundColor = backgroundColor
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: height!))
        
        pageControl = PageControlNode()
        self.addSubnode(pageControl)
        
        titleHolder = PagerHeaderTitleNode()
        self.addSubnode(titleHolder)
        
        leftButtonHolder = PagerHeaderIconNode()
        leftButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30,30))
        self.addSubnode(leftButtonHolder)
        
        rightButtonHolder = PagerHeaderIconNode()
        rightButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30,30))
        self.addSubnode(rightButtonHolder)
    }
    
    func didTap(sender : UITapGestureRecognizer) {
        self.delegate?.pagerHeaderDidTapOnHeeader(self)
    }
    
//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        let x = super.hitTest(point, withEvent: event)
//        
//        if x == self.view {
//            return nil
//        }
//        
//        return x
//    }
    
    override func didLoad() {
        super.didLoad()
        
        let x = UITapGestureRecognizer(target: self, action: #selector(PagerHeaderNode.didTap(_:)))
        self.view.addGestureRecognizer(x)
        
//        self.view.roundCorners([UIRectCorner.TopLeft,UIRectCorner.TopRight], radius: 15)
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
        self.pageControl.update(scrollPosition: scrollPosition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}