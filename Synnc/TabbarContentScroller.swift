//
//  TabbarContentScroller.swift
//  Synnc
//
//  Created by Arda Erzin on 12/10/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop

protocol TabbarContentLoaderDelegate {
    func loadSubsections(item: TabItem, inScroller scroller : TabbarContentScroller)
}

protocol TabbarContentScrollerDelegate {
    func beganScrolling()
    func didScrollToRatio(ratio : CGFloat)
    func didChangeCurrentIndex(index : Int)
}

class TabbarContentScroller : ASPagerNode {
    
    var contentDelegate : TabbarContentLoaderDelegate?
    var scrollerDelegate : TabbarContentScrollerDelegate?
    
    var pages : [ASDisplayNode] = []
    var pageNodes : [ASLayoutable] = []
    var currentIndex : Int = -1 {
        didSet {
            if currentIndex != oldValue && currentIndex != -1 {
                self.scrollerDelegate?.didChangeCurrentIndex(currentIndex)
            }
        }
    }
    var isScrolling : Bool = false
    
    var isUpdating : Bool = false
    
    var updatePositionAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("indicatorPositionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TabbarContentScroller).updatePositionAnimationPosition
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TabbarContentScroller).updatePositionAnimationPosition = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var updatePositionAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("updatePositionAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                self.isUpdating = true
                x.completionBlock = {
                    anim, finished in
                    
                    self.isUpdating = false
                    self.pop_removeAnimationForKey("updatePositionAnimation")
                }
                x.springBounciness = 0
                x.property = self.updatePositionAnimatableProperty
                self.pop_addAnimation(x, forKey: "updatePositionAnimation")
                return x
            }
        }
    }
    var updatePositionAnimationPosition : CGFloat! = 0 {
        didSet {
            self.view.contentOffset = CGPointMake(updatePositionAnimationPosition, 0)
        }
    }
    
    
    func updateForItem(item: TabItem, controller : TabItemController){
        self.currentIndex = item.selectedIndex
    }
    
    override init(viewBlock: ASDisplayNodeViewBlock, didLoadBlock: ASDisplayNodeDidLoadBlock?) {
        super.init(viewBlock: viewBlock, didLoadBlock: didLoadBlock)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, layoutFacilitator: ASCollectionViewLayoutFacilitatorProtocol?) {
        super.init(frame: frame, collectionViewLayout: layout, layoutFacilitator: layoutFacilitator)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    override init!(collectionViewLayout flowLayout: ASPagerFlowLayout!) {
        super.init(collectionViewLayout: flowLayout)
    }
    
    override init() {
        super.init()
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.asyncDelegate = self
        self.view.delaysContentTouches = false
        
        let a = ASRangeTuningParameters(leadingBufferScreenfuls: 1, trailingBufferScreenfuls: 1)
        self.setTuningParameters(a, forRangeMode: .Full, rangeType: ASLayoutRangeType.FetchData)
    }
}

extension TabbarContentScroller : ASCollectionDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.pop_removeAnimationForKey("updatePositionAnimation")
        self.scrollerDelegate?.beganScrolling()
        self.isUpdating = false
        self.isScrolling = true
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isScrolling = false
    }
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.memory.x
        let ci = Int(x / self.view.frame.width)
        self.currentIndex = ci
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let ratio = self.view.contentOffset.x / (self.view.contentSize.width - self.calculatedSize.width)
        if !isUpdating {
            self.scrollerDelegate?.didScrollToRatio(ratio)
        }
    }
}

extension TabbarContentScroller : SubsectionSelectorDelegate {
    func didSelectSubsection(subsectionIndex: Int) {
        if !self.isScrolling {
            self.updatePositionAnimation.fromValue = self.view.contentOffset.x
            self.updatePositionAnimation.toValue = CGFloat(subsectionIndex) * self.calculatedSize.width
            self.isUpdating = false
            self.currentIndex = subsectionIndex
        }
    }
    func willSelectSubsection(subsectionIndex: Int) {
        
    }
}