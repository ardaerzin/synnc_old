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
//    var imageGradientNode : ASImageNode!
    
    init(backgroundNode : ParallaxBackgroundNode? = ParallaxBackgroundNode(), contentNode : ASDisplayNode? = ASDisplayNode()) {
        super.init()
        
        self.backgroundNode = backgroundNode
        self.parallaxContentNode = contentNode
        
//        imageGradientNode = ASImageNode()
//        imageGradientNode.image = UIImage(named: "imageGradient")

        self.addSubnode(self.backgroundNode)
//        self.addSubnode(self.imageGradientNode)
        self.addSubnode(self.parallaxContentNode)
    }
    override func didLoad() {
        super.didLoad()
        
        if let scrollView = self.view as? UIScrollView {
            scrollView.delegate = self
            scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if !scrollView.panGestureRecognizer.enabled {
//            return
//        }
        let position: CGFloat = scrollView.contentOffset.y
        var delta : CGFloat = 0
        let limit : CGFloat = self.calculatedSize.width - 150
        let x = (self.view.frame.size.height / 2 - 150 / 2) + self.view.frame.size.width
        var bgScalePosition : CGFloat = 0
        if scrollView.contentOffset.y < 0 {
            self.backgroundNode.view.setContentOffset(CGPointMake(0, 0), animated: false)
            let y = 1 + abs(position / self.calculatedSize.width)
            bgScalePosition = position / 2
            
            POPLayerSetTranslationY(self.backgroundNode.imageGradientNode.layer, 0)
            POPLayerSetScaleXY(self.backgroundNode.imageNode.layer, CGPointMake(y, y))
            POPLayerSetScaleXY(self.backgroundNode.imageGradientNode.layer, CGPointMake(y, y))
            
            self.parallaxContentNode.position.y = x
        } else {
            delta = max(0,position - limit)
            let sp = min(limit * 0.25, max(0,position) * 0.25)
//            print(sp / (limit * 0.25))
            self.parallaxContentNode.position.y = x + delta
            POPLayerSetScaleXY(self.backgroundNode.imageNode.layer, CGPointMake(1, 1))
            self.backgroundNode.view.setContentOffset(CGPointMake(0, sp), animated: false)
            POPLayerSetTranslationY(self.backgroundNode.imageGradientNode.layer, sp)
            
            if let x = self.parallaxContentNode.view as? UIScrollView {
                x.setContentOffset(CGPointMake(0, delta), animated: false)
            }
        }
        self.backgroundNode.position.y = (self.backgroundNode.calculatedSize.height / 2) + position - bgScalePosition
        
//        self.backgroundNode.imageGradientNode.position.y = (self.backgroundNode.calculatedSize.height / 2) + position
        
        self.delegate?.scrollViewDidScroll(self, position: position)
    }
    
    override func layout() {
        super.layout()
        self.scrollViewDidScroll(self.view)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        print(self.parallaxContentNode)
        self.parallaxContentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - 150))
        self.backgroundNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
//        imageGradientNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
        
        return ASStaticLayoutSpec(children: [backgroundNode, self.parallaxContentNode])
    }
}