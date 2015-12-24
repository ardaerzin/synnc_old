//
//  MyPlaylistsEmptyStateNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
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

extension MyPlaylistsEmptyStateNode {
    func newPlaylistAction(sender: ButtonNode) {
        
        sender.alpha = 0
        
        self.animationButton.scaleAnimation.fromValue = sender.scaleAnimationProgress
        self.animationButton.scaleAnimation.toValue = 0
        
        self.animationButton.alpha = 1
        
        buttonInitialPosition = sender.position
        buttonFinalPosition = self.tabControllerNode!.headerNode.iconHolderNode.position
        buttonStateAnimation.toValue = 1
    }
}

class MyPlaylistsEmptyStateNode : ASDisplayNode {
    
    var mainTextNode : ASTextNode!
    var subTextNode : ASTextNode!
    var newPlaylistButton : ButtonNode!
    var animationButton : ButtonNode!
    
    var buttonInitialPosition : CGPoint!
    var buttonFinalPosition : CGPoint!
    
    var buttonStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("titleAnimationProperty", initializer: {
                prop in
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! MyPlaylistsEmptyStateNode).buttonStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! MyPlaylistsEmptyStateNode).buttonStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var buttonStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("buttonStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.animationButton.removeFromSupernode()
//                    if let a = anim as? POPBasicAnimation where finished {
//                        if (a.toValue as! CGFloat) == 1 {
//                            self.headerUpdateBlock?()
//                            self.headerChangeAnimation.toValue = 0
//                        } else {
//                            self.pop_removeAnimationForKey("titlePositionAnimation")
//                        }
//                    }
                }
                x.dynamicsFriction *= 1.5
//                x.springSpeed = 0.0
//                x.springBounciness = 0.1
                x.property = self.buttonStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "buttonStateAnimation")
                return x
            }
        }
    }
    var buttonStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            let translationX = POPTransition(buttonStateAnimationProgress, startValue: 0, endValue: buttonFinalPosition.x - buttonInitialPosition.x)
            let translationY = POPTransition(buttonStateAnimationProgress, startValue: 0, endValue: buttonFinalPosition.y - buttonInitialPosition.y)
            
            let scale = POPTransition(buttonStateAnimationProgress, startValue: 1, endValue: 20/62)
            let buttonTranslation = CGPointMake(translationX, translationY)
            let buttonScale = CGPointMake(scale, scale)
            
            POPLayerSetTranslationXY(self.animationButton.layer, buttonTranslation)
            POPLayerSetScaleXY(self.animationButton.layer, buttonScale)
        }
    }
    
    override init!() {
        super.init()
        
        mainTextNode = ASTextNode()
        
        subTextNode = ASTextNode()
        subTextNode.spacingBefore = 5
        
        newPlaylistButton = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
        newPlaylistButton.spacingBefore = 20
        newPlaylistButton.addTarget(self, action: Selector("newPlaylistAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        newPlaylistButton.zPosition = 1000
        newPlaylistButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(62, 62))
        newPlaylistButton.setImage(UIImage(named: "add_playlist"), forState: ASButtonStateNormal)
        
        animationButton = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
        animationButton.setImage(UIImage(named: "add_playlist"), forState: ASButtonStateNormal)
        animationButton.alpha = 0
        
        self.addSubnode(mainTextNode)
        self.addSubnode(subTextNode)
        self.addSubnode(newPlaylistButton)
    }
    override func fetchData() {
        mainTextNode.attributedString = NSAttributedString(string: "Start and stream your music", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 113/255, green: 113/255, blue: 113/255, alpha: 1), NSKernAttributeName : -0.1])
        subTextNode.attributedString = NSAttributedString(string: "Create a new playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1), NSKernAttributeName : -0.1])
//        newPlaylistButton.setImage(UIImage(named: "add_playlist"), forState: ASButtonStateNormal)
    }
    override func layout() {
        super.layout()
        
        if animationButton.supernode == nil {
            animationButton.view.frame = CGRectMake(0, 0, 62, 62)
            animationButton.position = self.newPlaylistButton.position
            animationButton.measure(CGSizeMake(62, 62))
            self.tabControllerNode.headerNode.view.addSubview(animationButton.view)
        }
    }
    override func didExitHierarchy() {
        super.didExitHierarchy()
//        newPlaylistButton.removeFromSupernode()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        var headerHeight : CGFloat = 0
        var spacerPercent : CGFloat = 0.15
        
        if let tcn = self.tabControllerNode {
            headerHeight = tcn.headerNode.calculatedSize.height
            let x = headerHeight / constrainedSize.max.height
            spacerPercent = max(0, 0.35 - x)
        }
        let headerSpacer = ASLayoutSpec()
        headerSpacer.flexBasis = ASRelativeDimension(type: .Points, value: headerHeight)
        
        let spacerBefore = ASLayoutSpec()
        spacerBefore.flexBasis = ASRelativeDimension(type: .Percent, value: spacerPercent)
        
        let spacerAfter = ASLayoutSpec()
        spacerAfter.flexGrow = true
        
        let buttonSpec = ASStaticLayoutSpec(children: [newPlaylistButton])
        buttonSpec.spacingBefore = 20
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [headerSpacer, spacerBefore, mainTextNode, subTextNode, buttonSpec, spacerAfter])
    }
}