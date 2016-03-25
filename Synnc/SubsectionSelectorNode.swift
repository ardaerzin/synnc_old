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
        
        self.setAttributedTitle(normalTitle, forState: ASControlState.Normal)
        self.setAttributedTitle(selectedTitle, forState: ASControlState.Highlighted)
    }
    
    override func changedSelected() {
        super.changedSelected()
        let title = self.selected ? self.selectedTitle : self.normalTitle
        self.setAttributedTitle(title, forState: ASControlState.Normal)
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
            }
        }
    }
    var sectionIndicator : ASDisplayNode!
    var delegate : SubsectionSelectorDelegate?
    
    var currentIndicatorPosition : CGFloat = 0 {
        didSet {
            POPLayerSetTranslationX(self.sectionIndicator.layer, currentIndicatorPosition)
        }
    }
    
    var minX : CGFloat!
    var maxX : CGFloat!
    
    override init() {
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
            POPLayerSetScaleX(self.sectionIndicator.layer, 1.0 / CGFloat(subSectionCount))
        } else {
            POPLayerSetScaleX(self.sectionIndicator.layer, 0)
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
            button.addTarget(self, action: #selector(SubsectionSelectorNode.didSelectSubsection(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
            let title = NSAttributedString(string: item.title, attributes: self.titleAttributes)
            button.setAttributedTitle(title, forState: ASControlState.Normal)
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
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: subSectionNodes)
        
        if self.minX == nil {
            let width = constrainedSize.max.width
            let c = (width / CGFloat(self.subSectionButtons.count)) / 2
            let currentPos = width / 2
            
            self.minX = c - currentPos
            self.maxX = (width - c) - currentPos
            
            let a = POPTransition(CGFloat(self.selectedSubsectionIndex) / CGFloat(self.subSectionButtons.count - 1), startValue: minX, endValue: maxX)
            self.currentIndicatorPosition = a
        }
        
        return ASStaticLayoutSpec(children: [x, self.sectionIndicator])
    }
}

extension SubsectionSelectorNode {
    
    func didSelectSubsection(sender : SubsectionButtonNode){
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: sender.item.subsections[sender.index].publicIdentifier, value: nil)
        self.delegate?.didSelectSubsection(sender.index)
    }
}