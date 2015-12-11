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

class HeaderNode : ASDisplayNode {
    
    var titleNode : ASTextNode!
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 30)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.15]
    
    var nowPlayingIcon : AnimatedLogoNode!
    var subSectionArea : SubsectionSelectorNode!
    var actionButton : ButtonNode!
    var selectedItem : TabItem! {
        didSet {
            if selectedItem != oldValue {
                self.updateForItem(selectedItem)
            }
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
    var headerChangeAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("indicatorWidthAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    if let a = anim as? POPSpringAnimation where finished {
                        if (a.toValue as! CGFloat) == 1 {
                            self.headerUpdateBlock?()
                            self.headerChangeAnimation.toValue = 0
                        } else {
                            self.pop_removeAnimationForKey("indicatorWidthAnimation")
                        }
                    }
                }
                x.springBounciness = 0
                x.springSpeed = 50
                x.property = self.headerChangeAnimatableProperty
                self.pop_addAnimation(x, forKey: "indicatorWidthAnimation")
                return x
            }
        }
    }
    var headerChangeAnimationProgress : CGFloat = 0 {
        didSet {
            let a = 1-headerChangeAnimationProgress
            self.titleNode.alpha = a
            for button in self.subSectionArea.subSectionButtons {
                button.alpha = 1-headerChangeAnimationProgress
            }
        }
    }
    var headerUpdateBlock : (()->Void)?
    
    
    override init!() {
        super.init()
        self.alignSelf = .Stretch
        
        self.titleNode = ASTextNode()
        
        self.nowPlayingIcon = AnimatedLogoNode(barCount: 5)
        nowPlayingIcon.preferredFrameSize = CGSizeMake(40, 34)
        
        self.subSectionArea = SubsectionSelectorNode()
        
        self.addSubnode(self.titleNode)
        self.addSubnode(nowPlayingIcon)
        self.addSubnode(subSectionArea)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layout() {
        super.layout()
    }
    
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        self.nowPlayingIcon.startAnimation()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let statusSpacer = ASLayoutSpec()
        statusSpacer.flexBasis = ASRelativeDimension(type: .Points, value: 20)
        
        let titleSpacer = ASLayoutSpec()
        titleSpacer.flexGrow = true
        let titleSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.titleNode, titleSpacer, ASStaticLayoutSpec(children: [nowPlayingIcon])])
        titleNode.spacingBefore = 50
        titleSpec.spacingBefore = 15
        titleSpec.alignSelf = .Stretch
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [statusSpacer, titleSpec, spacer, subSectionArea])
        
        return x
    }
}

extension HeaderNode {
    func updateForItem(item : TabItem){
        self.subSectionArea.updateIndicator(item)
        self.headerUpdateBlock = {
            self.titleNode.attributedString = NSAttributedString(string: item.title, attributes: self.titleAttributes)
            self.subSectionArea.updateButtons(item)
            self.setNeedsLayout()
        }
        self.headerChangeAnimation.toValue = 1
    }
}