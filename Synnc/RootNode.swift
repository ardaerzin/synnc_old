//
//  RootHolderNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/20/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import pop
import WCLUIKit
import WCLPopupManager
import WCLDataManager

class RootNode : PagerBaseControllerNode {
    
    var loginNode : ASDisplayNode! {
        didSet {
            if let n = loginNode {
                self.addSubnode(n)
            }
        }
    }
    var state : RootWindowControllerState = .Login {
        didSet {
            if state != oldValue {
                self.didSetState()
            }
        }
    }
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("serverStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! RootNode).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! RootNode).stateAnimationProgress = values[0]
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
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = -1 {
        didSet {
           
            self.loginNode.alpha = 1 - stateAnimationProgress
            
            let x = POPTransition(stateAnimationProgress, startValue: 0, endValue: self.headerNode.calculatedSize.height)
            POPLayerSetTranslationY(headerNode.layer, x)
            
            let y = self.pager.view.nodeForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0))
            if let pn = y.subnodes.first as? ProfileHolder {
                let p = max(0,stateAnimationProgress)
                POPLayerSetScaleXY(pn.layer, CGPointMake(p, p))
            }
        }
    }
    
    init() {
        let header = RootHeaderNode()
        super.init(header: header, pager: nil)
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    func didSetState() {
        self.stateAnimation.toValue = state == .Login ? 0 : 1
    }
    
    override func layout() {
        super.layout()
        
        self.headerNode.position.y = -self.headerNode.calculatedSize.height/2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        
        loginNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        return ASStaticLayoutSpec(children: [loginNode, x])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}