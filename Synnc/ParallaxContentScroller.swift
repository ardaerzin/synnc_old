//
//  ParallaxContentScroller.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit

protocol ParallaxContentScrollerDelegate {
    func scrollViewDidScroll(scroller : ParallaxContentScroller, position: CGFloat)
}

class ParallaxContentScroller : WCLScrollNode, UIScrollViewDelegate {
    var tabbarHeight : CGFloat = 0
    var topLimit : CGFloat = 150
    
    var delegate : ParallaxContentScrollerDelegate?
    var backgroundNode : ParallaxBackgroundNode! {
        didSet {
            if let ov = oldValue {
                ov.removeFromSupernode()
            }
            if let nv = backgroundNode {
                self.addSubnode(nv)
            }
        }
    }
    var parallaxContentNode : ASDisplayNode! {
        didSet {
            if let ov = oldValue {
                ov.removeFromSupernode()
            }
            if let nv = parallaxContentNode {
                self.addSubnode(nv)
            }
        }
    }
    init(backgroundNode : ParallaxBackgroundNode? = ParallaxBackgroundNode(), contentNode : ASDisplayNode? = ASDisplayNode()) {
        super.init()
        
        self.backgroundNode = backgroundNode
        self.parallaxContentNode = contentNode
        
        self.addSubnode(self.parallaxContentNode)
        self.addSubnode(self.backgroundNode)
    }
    override func didLoad() {
        super.didLoad()
        
        if let scrollView = self.view as? UIScrollView {
            scrollView.delegate = self
            scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
            scrollView.delaysContentTouches = false
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != self.view {
            return
        }
        let position: CGFloat = scrollView.contentOffset.y
        var delta : CGFloat = 0
        let limit : CGFloat = self.calculatedSize.width - topLimit
        
        self.delegate?.scrollViewDidScroll(self, position: position)
        
        let x = (self.view.frame.size.height / 2 - topLimit/2) + self.view.frame.size.width
        var bgScalePosition : CGFloat = 0
        
        var a : CGFloat = 0
        
        if scrollView.contentOffset.y < 0 {
            
            self.backgroundNode.scrollNode.clipsToBounds = false
//            self.backgroundNode.scrollNode.view.setContentOffset(CGPointMake(0, 0), animated: false)
            
            
            let y = 1 + abs(position / self.calculatedSize.width)
            bgScalePosition = position / 2 - position
            
            POPLayerSetTranslationY(self.backgroundNode.scrollNode.imageGradientNode.layer, 0)
            POPLayerSetTranslationY(self.backgroundNode.scrollNode.imageNode.layer, 0)
            POPLayerSetScaleXY(self.backgroundNode.imageGradientNode.layer, CGPointMake(y, y))
            POPLayerSetScaleXY(self.backgroundNode.imageNode.layer, CGPointMake(y, y))
            
            self.parallaxContentNode.position.y = x - (tabbarHeight / 2)
            
        } else {
            
            self.backgroundNode.scrollNode.clipsToBounds = true
            
            delta = max(0,position - limit)
            let shit = min(position, limit)
            
            self.parallaxContentNode.position.y = x + delta - (tabbarHeight / 2)
            
            a = -delta
            let width = self.backgroundNode.calculatedSize.width
            let p =  (width - shit - (-position / 2 - (a / 2))) / width
            
            if p.isFinite {
                POPLayerSetScaleY(self.backgroundNode.imageGradientNode.layer, p)
                POPLayerSetTranslationY(self.backgroundNode.scrollNode.imageNode.layer, position / 2 + (a / 2))
                POPLayerSetTranslationY(self.backgroundNode.scrollNode.imageGradientNode.layer, position + a - ((1-p)*width/2))
            }
            if let x = self.parallaxContentNode.view as? UIScrollView {
                x.setContentOffset(CGPointMake(0, delta), animated: false)
            }
        }
        
        self.backgroundNode.position.y = (self.backgroundNode.calculatedSize.height / 2) - bgScalePosition - a
        self.backgroundNode.updateScrollPositions(position)
    }
    
    override func layout() {
        super.layout()
        self.scrollViewDidScroll(self.view)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.parallaxContentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - topLimit - tabbarHeight))
        self.backgroundNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        
        return ASStaticLayoutSpec(children: [backgroundNode, self.parallaxContentNode])
    }
}