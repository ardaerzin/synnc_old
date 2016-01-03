//
//  WildTransitioning.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

//
//  WildTransitioning.swift
//  HomeManager
//
//  Created by Arda Erzin on 2/4/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import UIKit

class WildTransitioning : UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    var presenting : Bool = false
    var interactive : Bool = false
    var animationDuration : NSTimeInterval = 0.5
    var initialView : UIView!
    var initialSnapShot : UIView!
    
    //animation related properties
    var fromVC: UIViewController!
    var toVC: UIViewController!
    
    var containerView: UIView!
    var animatedView : UIView!
    
    var initialFrame : CGRect!
    var initialPath : CGPath!
    var finalFrame : CGRect!
    var finalPath : CGPath!
    
    var initialScale : CGAffineTransform!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        containerView = transitionContext.containerView()
        fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        animatedView = presenting ? toVC.view : fromVC.view
    }
}