//
//  HeaderNode.swift
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

class TitleHolderNode : ASDisplayNode {
    var titleItem : ASDisplayNode! {
        willSet {
            if let item = titleItem {
                item.removeFromSupernode()
            }
        }
        didSet {
            if titleItem != nil {
                self.addSubnode(titleItem)
            }
        }
    }
    override func layout() {
        super.layout()
        if let title = self.titleItem {
            title.position.x = (self.calculatedSize.width / 2)
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        if titleItem == nil {
            return ASLayoutSpec()
        } else {
            if let w = self.supernode?.calculatedSize.width {
                titleItem.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: w-100), ASRelativeDimension(type: .Points, value: 33))
            }
            let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [ASStaticLayoutSpec(children: [titleItem])])
            return x
        }
    }
}
class IconHolderNode : ASDisplayNode {
    var iconItem : ASDisplayNode! {
        willSet {
            if let item = iconItem {
                item.removeFromSupernode()
            }
        }
        didSet {
            if iconItem != nil {
                self.addSubnode(iconItem)
            }
        }
    }
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        if iconItem == nil {
            return ASLayoutSpec()
        } else {
            return ASStaticLayoutSpec(children: [iconItem])
        }
    }
}

class HeaderNode : ASDisplayNode {
    
    var titleHolderNode : TitleHolderNode!
    var nowPlayingIcon : AnimatedLogoNode!
    var subSectionArea : SubsectionSelectorNode!
    var actionButton : ButtonNode!
    var iconHolderNode : IconHolderNode!
    
    var selectedItem : TabItem! {
        didSet {
            if selectedItem.identifier != oldValue.identifier {
                self.updateForItem(selectedItem)
            }
        }
    }
    
    var titlePositionAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("titleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! HeaderNode).titlePositionAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! HeaderNode).titlePositionAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var titlePositionAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("titlePositionAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    if let a = anim as? POPBasicAnimation where finished {
                        if (a.toValue as! CGFloat) == 1 {
                            self.headerUpdateBlock?()
                            self.headerChangeAnimation.toValue = 0
                        } else {
                            self.pop_removeAnimationForKey("titlePositionAnimation")
                        }
                    }
                }
                x.duration = 0.2
                x.property = self.titlePositionAnimatableProperty
                self.pop_addAnimation(x, forKey: "titlePositionAnimation")
                return x
            }
        }
    }
    var titlePositionAnimationProgress : CGFloat = 0 {
        didSet {
            POPLayerSetTranslationX(self.titleHolderNode.layer, titlePositionAnimationProgress)
        }
    }
    
    var headerChangeAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("indicatorWidthAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! HeaderNode).headerChangeAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! HeaderNode).headerChangeAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var headerChangeAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("indicatorWidthAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    if let a = anim as? POPBasicAnimation where finished {
                        if (a.toValue as! CGFloat) == 1 {
                            self.headerUpdateBlock?()
                            self.headerChangeAnimation.toValue = 0
                        } else {
                            self.pop_removeAnimationForKey("indicatorWidthAnimation")
                        }
                    }
                }
                x.duration = 0.2
                x.property = self.headerChangeAnimatableProperty
                self.pop_addAnimation(x, forKey: "indicatorWidthAnimation")
                return x
            }
        }
    }
    var headerChangeAnimationProgress : CGFloat = 0 {
        didSet {
            let a = 1-headerChangeAnimationProgress
            self.titleHolderNode.alpha = a
            self.iconHolderNode.alpha = a
            for button in self.subSectionArea.subSectionButtons {
                button.alpha = 1-headerChangeAnimationProgress
            }
        }
    }
    var headerUpdateBlock : (()->Void)?
    
    
    override init!() {
        super.init()
        self.alignSelf = .Stretch
        
        self.titleHolderNode = TitleHolderNode()
        self.iconHolderNode = IconHolderNode()
        
        self.nowPlayingIcon = AnimatedLogoNode(barCount: 5)
        nowPlayingIcon.preferredFrameSize = CGSizeMake(40, 34)
        
        self.subSectionArea = SubsectionSelectorNode()
        
        self.addSubnode(self.titleHolderNode)
        self.addSubnode(self.iconHolderNode)
        
        self.addSubnode(nowPlayingIcon)
        self.addSubnode(subSectionArea)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layout() {
        super.layout()
        self.iconHolderNode.position.x = (self.iconHolderNode.calculatedSize.width / 2) + 10
        self.iconHolderNode.position.y = self.titleHolderNode.position.y
        self.nowPlayingIcon.position.x = self.calculatedSize.width - (self.nowPlayingIcon.calculatedSize.width / 2)
    }
    
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        self.nowPlayingIcon.startAnimation()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let statusSpacer = ASLayoutSpec()
        statusSpacer.flexBasis = ASRelativeDimension(type: .Points, value: 20)
        
        let titleSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [ASStaticLayoutSpec(children: [iconHolderNode, self.titleHolderNode, nowPlayingIcon])])
        titleSpec.spacingBefore = 17
        titleSpec.flexBasis = ASRelativeDimension(type: .Points, value: 67)
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [statusSpacer, titleSpec, subSectionArea])
        
        return x
    }
}

extension HeaderNode {
    func updateForItem(item : TabItem){
        self.subSectionArea.updateIndicator(item)
        self.headerUpdateBlock = {
            self.subSectionArea.updateButtons(item)
            
            self.iconHolderNode.iconItem = item.iconItem
            self.titleHolderNode.titleItem = item.titleItem
            
            self.iconHolderNode.setNeedsLayout()
            self.titleHolderNode.setNeedsLayout()
        }
        if item.iconItem == nil {
            self.titlePositionAnimation.toValue = -25
        } else {
            self.titlePositionAnimation.toValue = 0
        }
        self.headerChangeAnimation.toValue = 1
    }
}