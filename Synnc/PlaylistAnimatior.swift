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
            
//            if fromVC.view.frame.origin.y - initialFrame.origin.y > containerView.frame.height {
//                initialFrame.origin.y = fromVC.view.frame.origin.y + containerView.frame.height
//            }
            
            //            self.containerView.addSubview(fromVC.view)
            //            print("za")
        }
       
//        UIView.animateWithDuration(2/3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.BeginFromCurrentState], animations: {
//            //        UIView.animateWithDuration(1/3, delay: 0, options: [], animations: {
//            
//            self.toVC.setNeedsStatusBarAppearanceUpdate()
//            self.fromVC.setNeedsStatusBarAppearanceUpdate()
//            
//            if self.presenting {
//                
//                //                y.frame = self.containerView.frame
//                //                y.layoutIfNeeded()
//                //                z.alpha = 1
////                if let tvc : TabbarController = self.fromVC.topmostVC() as? TabbarController {
////                    tvc.setTabBarVisible(false, animated:true)
////                    tvc.view.layoutSubviews()
////                }
//                
//                ////                self.toVC.view.frame.origin.y = 0
//                //                self.toVC.view.frame = self.fromVC.view.frame
//                //                let translate = CGAffineTransformTranslate(x.transform, 100, 0)
//                //                x.transform = CGAffineTransformIdentity
//                //                x.transform = CGAffineTransformScale(translate, 1, 1)
////                self.toVC.view.frame = self.containerView.frame
//                //                self.toVC.view.layoutIfNeeded()
//                ////                self.toVC.view.alpha = 1
//                //                print("sector")
//            } else {
////                if let tvc : TabbarController = self.fromVC.topmostVC() as? TabbarController {
////                    tvc.setTabBarVisible(true, animated:true)
////                    tvc.view.layoutSubviews()
////                }
////                
//                
//                //                containerView.addSubview(self.toVC.view)
//                //                if let nvc = self.fromVC as? MyStreamBaseNavigationController, let vc = nvc.viewControllers.last {
//                //                    vc.view.alpha = 0
//                //                }
//                //                print("CENTER Y SHIT:", self.containerView.center.y + self.containerView.frame.height, self.fromVC)
//                //                self.toVC.view.alpha = 0
//                //                self.animatedView.backgroundColor = UIColor.blueColor()
////                self.fromVC.view.frame = self.initialFrame
////                self.fromVC.view.layoutIfNeeded()
//                //                    center.y = self.containerView.center.y + self.containerView.frame.height
//            }
//            
//            }, completion: {
//                
//                completed in
//                
//                //                self.animatedView.removeFromSuperview()
//                
//                if !transitionContext.transitionWasCancelled() {
//                    if self.presenting {
//                        //                        y.removeFromSuperview()
//                        //                        self.fromVC.view.removeFromSuperview()
//                    } else {
//                        //                        self.fromVC.view.removeFromSuperview()
//                    }
//                } else {
//                    
//                }
//                
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//
//        })
    }
    override func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
    }
}