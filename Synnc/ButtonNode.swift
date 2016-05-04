//
//  ButtonNode.swift
//  LonoNotes
//
//  Created by Arda Erzin on 11/15/15.
//  Copyright © 2015 Doguhan Okumus. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit

class ButtonNode : ASButtonNode {
    
    var minScale : CGFloat = 0.75
    var normalBgColor : UIColor!
    var selectedBgColor : UIColor!
    
    internal var _spinView : RTSpinKitView!
    var spinView : RTSpinKitView {
        get {
            if _spinView == nil {
                let x = self.calculatedSize.height
                
                _spinView = RTSpinKitView(frame: CGRectMake(0, 0, x - 20, x - 20))
                _spinView.color = UIColor.whiteColor()
                _spinView.style = RTSpinKitViewStyle.StyleArcAlt
                _spinView.spinnerSize = x - 20
                _spinView.alpha = 0
                _spinView.center = self.view.convertPoint(self.position, fromView: self.supernode!.view)
                self.view.addSubview(_spinView)
            }
            
            return _spinView
        }
    }
    var backgroundAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("bgAnim") as? POPSpringAnimation {
                return anim
            } else {
                let x = POPSpringAnimation(propertyNamed: kPOPViewBackgroundColor)
                x.springBounciness = 0
                x.completionBlock = {
                    anim, finished in
                    
                    if finished {
                        self.pop_removeAnimationForKey("bgAnim")
                    }
                }
                self.pop_addAnimation(x, forKey: "bgAnim")
                return x
            }
        }
    }
    var scaleAnimationProgress : CGFloat = 0 {
        didSet {
            
            let x = POPTransition(scaleAnimationProgress, startValue: 1, endValue: minScale)
            POPLayerSetScaleXY(self.layer, CGPointMake(x, x))
        }
    }
    var scaleAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! ButtonNode).scaleAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! ButtonNode).scaleAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var scaleAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("scaleAnimation")
                }
                x.springBounciness = 10
                x.property = self.scaleAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    
    var spinStateAnimationProgress : CGFloat = 0 {
        didSet {
            let x = POPTransition(spinStateAnimationProgress, startValue: 1, endValue: 0)
            self.titleNode.alpha = x
            spinView.alpha = abs(1-x)
        }
    }
    var spinStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("spinStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! ButtonNode).spinStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! ButtonNode).spinStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var spinStateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("spinStateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("spinStateAnimation")
                }
                x.property = self.spinStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "spinStateAnimation")
                return x
            }
        }
    }
    
    func changedSelected(){
        if selected {
            self.backgroundAnimation.toValue = self.selectedBgColor
        } else {
            self.backgroundAnimation.toValue = self.normalBgColor
        }
    }
    
    override var selected : Bool {
        didSet {
            self.changedSelected()
        }
    }
    
    init(normalColor : UIColor? = .clearColor(), selectedColor : UIColor? = .clearColor()) {
        super.init()
        
        self.normalBgColor = normalColor
        self.selectedBgColor = selectedColor
        
        self.backgroundColor = normalColor
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        scaleAnimation.toValue = 1
        self.backgroundAnimation.toValue = self.selectedBgColor
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        scaleAnimation.toValue = 0
        self.backgroundAnimation.toValue = self.selected ? self.selectedBgColor : self.normalBgColor
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        scaleAnimation.toValue = 0
        self.backgroundAnimation.toValue = self.selected ? self.selectedBgColor : self.normalBgColor
    }
    
    
    
    func showSpinView(){
        spinView.startAnimating()
        self.spinStateAnimation.toValue = 1
    }
    func hideSpinView(){
        self.spinStateAnimation.completionBlock = {
            anim, finished in
            
            if finished {
                self.spinView.stopAnimating()
            }
            self.pop_removeAnimationForKey("spinStateAnimation")
        }
        self.spinStateAnimation.toValue = 0
    }
}
