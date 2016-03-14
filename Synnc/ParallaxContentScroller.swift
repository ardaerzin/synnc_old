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
    // ****** 150
    
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
        
        if let scrollView = self.view {
            scrollView.delegate = self
            scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
            scrollView.delaysContentTouches = false
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView != self.view {
            return
        }
        var position: CGFloat = scrollView.contentOffset.y
        var delta : CGFloat = 0
        let limit : CGFloat = self.backgroundNode.calculatedSize.height - topLimit
        var ratioProgress : CGFloat!
        
        self.delegate?.scrollViewDidScroll(self, position: position)
        
        let x = (self.view.frame.size.height / 2 - topLimit/2) + (self.backgroundNode.calculatedSize.height)
        var bgScalePosition : CGFloat = 0
        
        var a : CGFloat = 0
        
        if scrollView.contentOffset.y <= 0 {
            
            var sizeHeight : CGFloat!
            
            if self.backgroundNode.calculatedSize.height - scrollView.contentOffset.y <= self.backgroundNode.calculatedSize.width {
                self.backgroundNode.clipsToBounds = false
                self.backgroundNode.scrollNode.clipsToBounds = true
                
                bgScalePosition = 0
                a = position - scrollView.contentOffset.y
                
                ratioProgress = (self.backgroundNode.calculatedSize.height - position) / self.calculatedSize.width
                
                sizeHeight = self.backgroundNode.calculatedSize.height - position
                
                let x = self.backgroundNode.calculatedSize.width - (self.backgroundNode.calculatedSize.height - position)
                self.backgroundNode.backgroundTranslation = x/2
                
            } else {
                
                let z = (self.backgroundNode.calculatedSize.height - self.backgroundNode.calculatedSize.width)
                let w = (position - z)/2
                position = z + w
                
                sizeHeight = self.backgroundNode.calculatedSize.height - position
                
                self.backgroundNode.clipsToBounds = false
                self.backgroundNode.scrollNode.clipsToBounds = false
                
                bgScalePosition = (self.backgroundNode.calculatedSize.height - position - self.backgroundNode.calculatedSize.width) / 4
               
                ratioProgress = (self.backgroundNode.calculatedSize.height - position) / self.calculatedSize.width
                
                let x = self.backgroundNode.calculatedSize.height - self.backgroundNode.calculatedSize.width
                a = (self.backgroundNode.calculatedSize.height - position - self.backgroundNode.calculatedSize.width) / 2 - (self.backgroundNode.calculatedSize.height - backgroundNode.calculatedSize.width) + z
                
                let y = (self.backgroundNode.calculatedSize.width - (self.backgroundNode.calculatedSize.height - position)) / 2 - bgScalePosition
                
                self.backgroundNode.backgroundTranslation = y
            }
            
            let y = max(1, abs(sizeHeight / self.calculatedSize.width))
            if let x = self.parallaxContentNode.view as? UIScrollView {
                x.setContentOffset(CGPointMake(0, 0), animated: false)
            }
            
            self.backgroundNode.backgroundScale = y
            self.parallaxContentNode.position.y = x - (tabbarHeight / 2) + scrollView.contentOffset.y - position
        } else {
            
            ratioProgress = 0
            
            self.backgroundNode.scrollNode.clipsToBounds = true
            
            delta = max(0,position - limit)
            let y = min(position, limit)
            
            self.parallaxContentNode.position.y = x + delta - (tabbarHeight / 2)
            
            a = -delta
            let width = self.backgroundNode.calculatedSize.width
            let p =  (width - y - (-position / 2 - (a / 2))) / width
            
            if p.isFinite {
                POPLayerSetScaleY(self.backgroundNode.imageGradientNode.layer, p)
                self.backgroundNode.backgroundTranslation = position / 2 + (a / 2) + (self.backgroundNode.calculatedSize.width - (self.backgroundNode.calculatedSize.height)) / 2
                
                POPLayerSetTranslationY(self.backgroundNode.scrollNode.imageGradientNode.layer, position + a - ((1-p)*width/2) + (self.backgroundNode.calculatedSize.width - (self.backgroundNode.calculatedSize.height)) / 2)
            }
            if let x = self.parallaxContentNode.view as? UIScrollView {
                x.setContentOffset(CGPointMake(0, delta), animated: false)
            }
        }
        
        if let s = self.supernode as? ParallaxNode {
            s.didScroll(position)
        }

        self.backgroundNode.position.y = (self.backgroundNode.calculatedSize.height / 2) - bgScalePosition - a
        self.backgroundNode.updateScrollPositions(position, ratioProgress: ratioProgress)
    }
    
    override func layout() {
        super.layout()
        self.scrollViewDidScroll(self.view)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if let x = self.supernode as? ParallaxNode, let sizeRange = x.backgroundSizeRange(forConstrainedSize: constrainedSize) {
            self.backgroundNode.sizeRange = sizeRange
        } else {
            self.backgroundNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        }
        
        self.parallaxContentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - topLimit - tabbarHeight))
        
        return ASStaticLayoutSpec(children: [backgroundNode, self.parallaxContentNode])
    }
}