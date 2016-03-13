//
//  PlaylistAnimatior.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import pop

class PlaylistAnimator : WildTransitioning {
    
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("displayAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PlaylistAnimator).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PlaylistAnimator).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("displayAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    if finished {
                        self.transitionContext!.completeTransition(!self.transitionContext!.transitionWasCancelled())
                    }
                }
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "displayAnimation")
                return x
            }
        }
    }
    var displayAnimationProgress : CGFloat = 0 {
        didSet {
            
            let shit = POPTransition(displayAnimationProgress, startValue: self.containerView.bounds.height, endValue: 0)
            POPLayerSetTranslationY(self.animatedView.layer, shit)
        }
    }

    
    var imageView : UIImageView!
    
    override init() {
        super.init()
        self.animationDuration = 0.5
    }
    override func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(transitionContext)
        
        if presenting {
            
            toVC.view.frame = containerView.bounds
            POPLayerSetTranslationY(toVC.view.layer, containerView.bounds.height)
//                CGRect(x: 0, y: 0, width: containerView.bounds, height: <#T##CGFloat#>)
            self.containerView.addSubview(toVC.view)
            self.displayAnimation.toValue = 1
            
//            toVC.view.setNeedsLayout()
//            toVC.view.layoutIfNeeded()
        } else {
            self.containerView.addSubview(toVC.view)
            self.containerView.sendSubviewToBack(toVC.view)

            self.displayAnimation.toValue = 0
            
        }
    }
    override func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
    }
}