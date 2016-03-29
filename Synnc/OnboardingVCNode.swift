//
//  OnboardingVCNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/23/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class OnboardingPagerHolder : ASDisplayNode {
    var pager : OnboardingPager!
    override init() {
        super.init()
        
        let layout = ASPagerFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        self.shadowColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 0.5).CGColor
        self.shadowOffset = CGSizeMake(0, 1)
        self.shadowOpacity = 1
        self.shadowRadius = 2
        
        pager = OnboardingPager(collectionViewLayout: layout)
        self.addSubnode(pager)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        pager.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        return ASStaticLayoutSpec(children: [pager])
    }
}

class OnboardingVCNode : ASDisplayNode, TrackedView {
    
    var statusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! OnboardingVCNode).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! OnboardingVCNode).stateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.statusAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = 0 {
        didSet {
            
//            POPLayerSetScaleXY(decorationInner.layer, CGPointMake(stateAnimationProgress, stateAnimationProgress))
//            POPLayerSetScaleXY(decorationOuter.layer, CGPointMake(stateAnimationProgress, stateAnimationProgress))
            POPLayerSetScaleXY(pagerHolder.layer, CGPointMake(stateAnimationProgress, stateAnimationProgress))
        }
    }
    
    var title : String! = "OnboardingView"
    var pagerHolder : OnboardingPagerHolder!
    var pager : OnboardingPager {
        get {
            return pagerHolder.pager
        }
    }
    var pageControl : UIPageControl!
    var decorationOuter : ASDisplayNode!
    var decorationInner : ASDisplayNode!
    
    override init() {
        super.init()
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        decorationOuter = ASDisplayNode()
        decorationOuter.backgroundColor = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 0.3)
        decorationOuter.layerBacked = true
        self.addSubnode(decorationOuter)
        
        decorationInner = ASDisplayNode()
        decorationInner.backgroundColor = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)
        decorationInner.layerBacked = true
        self.addSubnode(decorationInner)
        
        pagerHolder = OnboardingPagerHolder()
        self.addSubnode(pagerHolder)
        
        pageControl = UIPageControl()
        pageControl.defersCurrentPageDisplay = true
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        self.view.addSubview(pageControl)
    }
    
    override func layout() {
        super.layout()
        
        pagerHolder.position.x = self.calculatedSize.width / 2
        pagerHolder.position.y = self.calculatedSize.height / 2
        
        decorationOuter.position = pagerHolder.position
        decorationInner.position = decorationOuter.position
        
        
        
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        pageControl.frame = CGRect(x: self.calculatedSize.width / 2 - size.width / 2, y: (pagerHolder.calculatedSize.height / 2 + pagerHolder.position.y + 10), width: size.width, height: size.height)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let cardHolder = ASStaticLayoutSpec(children: [pagerHolder])
        
        let x : CGFloat = 20
        
        //diff = bottom spacing + top spacing
        let diff : CGFloat = (37 + 2*x) + 20 + x
        
        pagerHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.8), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - diff))
        
        let y = constrainedSize.max.width + 15
        decorationOuter.cornerRadius = y / 2
        decorationOuter.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: y), ASRelativeDimension(type: .Points, value: y))
        
        let z = y * 0.9
        decorationInner.cornerRadius = z / 2
        decorationInner.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: z), ASRelativeDimension(type: .Points, value: z))
        
        return ASStaticLayoutSpec(children: [decorationOuter, decorationInner, cardHolder])
    }
    
}