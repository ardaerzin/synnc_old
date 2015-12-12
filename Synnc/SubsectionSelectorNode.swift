//
//  SubsectionSelectorNode.swift
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

protocol SubsectionSelectorDelegate {
    func willSelectSubsection(subsectionIndex: Int)
    func didSelectSubsection(subsectionIndex: Int)
}

class SubsectionButtonNode : ButtonNode {
    var normalTitle : NSAttributedString!
    var selectedTitle : NSAttributedString!
    var item : TabItem!
    var index : Int = -1
    
    init(item : TabItem, index: Int) {
        super.init(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
        
        self.item = item
        self.index = index
        
        let normalAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.3), NSKernAttributeName : 0.17]
        let selectedAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.17]
        
        self.minScale = 0.95
        
        self.normalTitle = NSAttributedString(string: item.subsections[index].title, attributes: normalAttributes)
        self.selectedTitle = NSAttributedString(string: item.subsections[index].title, attributes: selectedAttributes)
        
        self.setAttributedTitle(normalTitle, forState: ASButtonStateNormal)
        self.setAttributedTitle(selectedTitle, forState: ASButtonStateHighlighted)
    }
    
    override func changedSelected() {
        super.changedSelected()
        let title = self.selected ? self.selectedTitle : self.normalTitle
        self.setAttributedTitle(title, forState: ASButtonStateNormal)
    }
}

class SubsectionSelectorNode : ASDisplayNode {
    
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.3), NSKernAttributeName : 0.17]
    var subSectionButtons : [SubsectionButtonNode] = []
    var subSectionNodes : [ASLayoutable] = []
    var needsButtonUpdate : Bool = false
    
    var selectedSubsectionIndex : Int = -1 {
        willSet {
            if newValue != selectedSubsectionIndex {
                self.delegate?.willSelectSubsection(newValue)
            }
        }
        didSet {
            if selectedSubsectionIndex != oldValue {
                if selectedSubsectionIndex <= self.subSectionButtons.count - 1 {
                    self.subSectionButtons[selectedSubsectionIndex].selected = true
                    if oldValue != -1 {
                        self.subSectionButtons[oldValue].selected = false
                    }
                } else {
                }
//                self.delegate?.didSelectSubsection(selectedSubsectionIndex)
            }
        }
    }
    var sectionIndicator : ASDisplayNode!
    var delegate : SubsectionSelectorDelegate?
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
    }
   
//    var colors = [UIColor.blueColor(), UIColor.greenColor(), UIColor.orangeColor()]
    
    
    /**
    Animation Progress Values
    */
    var indicatorWidthAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("indicatorWidthAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SubsectionSelectorNode).indicatorWidthAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SubsectionSelectorNode).indicatorWidthAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var indicatorWidthAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("indicatorWidthAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("indicatorWidthAnimation")
                }
                x.springBounciness = 0
                x.property = self.indicatorWidthAnimatableProperty
                self.pop_addAnimation(x, forKey: "indicatorWidthAnimation")
                return x
            }
        }
    }
    var indicatorWidthAnimationProgress : CGFloat = 1 {
        didSet {
            POPLayerSetScaleX(self.sectionIndicator.layer, indicatorWidthAnimationProgress)
        }
    }
    
    
    
    
    /**
    Animation Progress Values
    */
    var indicatorPositionAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("indicatorPositionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SubsectionSelectorNode).indicatorPositionAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SubsectionSelectorNode).indicatorPositionAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var indicatorPositionAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("indicatorPositionAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("indicatorPositionAnimation")
                }
                x.springBounciness = 0
                x.property = self.indicatorPositionAnimatableProperty
                self.pop_addAnimation(x, forKey: "indicatorPositionAnimation")
                return x
            }
        }
    }
    var indicatorPositionAnimationProgress : CGFloat! {
        didSet {
            let a = POPTransition(indicatorPositionAnimationProgress, startValue: minX, endValue: maxX)
            self.currentIndicatorPosition = a
        }
    }
    var currentIndicatorPosition : CGFloat = 0 {
        didSet {
            POPLayerSetTranslationX(self.sectionIndicator.layer, currentIndicatorPosition)
        }
    }
    var minX : CGFloat!
    var maxX : CGFloat!
    
    
    override init!() {
        super.init()
        self.alignSelf = .Stretch
        self.flexBasis = ASRelativeDimension(type: .Points, value: 30)
        
        sectionIndicator = ASDisplayNode()
        sectionIndicator.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 2))
        sectionIndicator.backgroundColor = UIColor.SynncColor()
        self.addSubnode(sectionIndicator)
    }
    func updateIndicator(tabItem: TabItem) {
        let subSectionCount = tabItem.subsections.count
        if subSectionCount > 0 {
            self.indicatorWidthAnimation.toValue = 1.0 / CGFloat(subSectionCount)
            
            let width = self.calculatedSize.width
            let x = (width / CGFloat(subSectionCount)) / 2
            
            let currentPos = width / 2
            self.minX = x - currentPos
            self.maxX = (width - x) - currentPos
            let z = CGFloat(tabItem.selectedIndex) / CGFloat(subSectionCount - 1)
            
            if self.indicatorPositionAnimationProgress == nil {
                self.indicatorPositionAnimationProgress = 0.5
            } else {
                self.indicatorPositionAnimationProgress = POPProgress(self.currentIndicatorPosition, startValue: minX, endValue: maxX)
            }
            self.indicatorPositionAnimation.toValue = z
        } else {
            self.indicatorWidthAnimation.toValue = 0
        }
    }
    func updateButtons(tabItem: TabItem) {
        
        for button in subSectionButtons {
            button.removeFromSupernode()
        }
        self.subSectionNodes = []
        var buttons : [SubsectionButtonNode] = []
        let subSectionCount = tabItem.subsections.count
        for (index,item) in tabItem.subsections.enumerate() {
            let button = SubsectionButtonNode(item: tabItem, index: index)
            button.addTarget(self, action: Selector("didSelectSubsection:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            let title = NSAttributedString(string: item.title, attributes: self.titleAttributes)
            button.setAttributedTitle(title, forState: ASButtonStateNormal)
            button.flexGrow = true
            buttons.append(button)
            self.addSubnode(button)
            
            if selectedSubsectionIndex != -1 && selectedSubsectionIndex == index {
                button.selected = true
            }
            
            let x = UIScreen.mainScreen().bounds.width / CGFloat(subSectionCount)
            
            button.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: x), ASRelativeDimension(type: .Percent, value: 1))
            let spec = ASStaticLayoutSpec(children: [button])
            subSectionNodes.append(spec)
        }
        subSectionButtons = buttons
        self.setNeedsLayout()
    }
    
    override func layout() {
        super.layout()
        self.sectionIndicator.position.y = self.calculatedSize.height - 1
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: subSectionNodes)
        return ASStaticLayoutSpec(children: [x, self.sectionIndicator])
    }
}

extension SubsectionSelectorNode {
    
    func didSelectSubsection(sender : SubsectionButtonNode){
//        self.selectedSubsectionIndex = sender.index
        self.delegate?.didSelectSubsection(sender.index)
    }
//    func didScrollToRatio(ratio: CGFloat) {
//        let a = POPTransition(ratio, startValue: minX, endValue: maxX)
//        self.currentIndicatorPosition = a
//    }
}