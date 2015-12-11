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
import SpinKit
import WCLUserManager
import DeviceKit

protocol TabbarContentScrollerDelegate {
    func beganScrolling()
    func didScrollToRatio(ratio : CGFloat)
    func didChangeCurrentIndex(index : Int)
}

class TabbarContentScroller : ASScrollNode {
    
    var delegate : TabbarContentScrollerDelegate?
    var pages : [ASDisplayNode] = []
    var pageNodes : [ASLayoutable] = []
    var currentIndex : Int = -1 {
        didSet {
            if currentIndex != oldValue {
                self.delegate?.didChangeCurrentIndex(currentIndex)
            }
        }
    }
    var isScrolling : Bool = false
    var colors : [UIColor] = [UIColor.clearColor(), UIColor.blueColor(), UIColor.yellowColor()]
    
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
    
    
    func updateForItem(item: TabItem){
        for item in pages {
            item.removeFromSupernode()
        }
        self.pages = []
        for (index,subsection) in item.subsections.enumerate() {
            let a = ASDisplayNode()
//            a.backgroundColor = self.colors[index]
            self.addSubnode(a)
            self.pages.append(a)
        }
        self.updatePositionAnimation.toValue = CGFloat(item.selectedIndex) * self.calculatedSize.width
        self.setNeedsLayout()
    }
    
    override init!() {
        super.init()
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.pagingEnabled = true
        self.view.delegate = self
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        var staticSpecs : [ASStaticLayoutSpec] = []
        for node in pages {
            node.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeSize(ASRelativeSizeMake(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Percent, value: 1)))
            let a = ASStaticLayoutSpec(children: [node])
            staticSpecs.append(a)
        }
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: staticSpecs)
        return hStack
    }
}

extension TabbarContentScroller : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.pop_removeAnimationForKey("updatePositionAnimation")
        self.delegate?.beganScrolling()
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
//        self.isScrolling = false
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let ratio = self.view.contentOffset.x / (self.view.contentSize.width - self.calculatedSize.width)
        let xPosition = scrollView.contentOffset.x;
        let fractionalPage = CGFloat(xPosition / scrollView.frame.size.width)
        
        if !isUpdating {
            self.delegate?.didScrollToRatio(ratio)
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
            print("ZA")
        } else {
            print("SEX")
        }
    }
    func willSelectSubsection(subsectionIndex: Int) {
        
    }
}