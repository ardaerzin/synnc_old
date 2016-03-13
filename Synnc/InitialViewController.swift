//
//  LoginViewController.swift
//  Synnc
//
//  Created by Arda Erzin on 2/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop

enum InitialVCState {
    case Onboarding
    case Login
}

class InitialViewController : WCLPopupViewController {
    
    var state : InitialVCState! {
        didSet {
            if state != oldValue {
                self.screenNode.state = state
            }
        }
    }
    
    var screenNode : InitialControllerNode!
    var pages : [Any] = []
    
    var onboardingController : OnboardingVC!
    var loginController : LoginViewController!
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Center), withShadow: true)
        
        loginController = LoginViewController()
        loginController.view.frame = UIScreen.mainScreen().bounds
        self.addChildViewController(loginController)
        
        onboardingController = OnboardingVC()
        onboardingController.view.frame = UIScreen.mainScreen().bounds
        self.addChildViewController(onboardingController)
        
        self.screenNode.loginNode = loginController.node as! LoginNode
        self.screenNode.onboardingNode = onboardingController.node as! OnboardingVCNode
        self.screenNode.delegate = self
        
        var screen : AnalyticsScreen!
        if let seenOnboarding = WildDataManager.sharedInstance().getUserDefaultsValue("seenOnboarding") as? Bool where seenOnboarding {
            state = .Login
            self.screenNode.addSubnode(self.screenNode.loginNode)
        } else {
            state = .Onboarding
            self.screenNode.addSubnode(self.screenNode.onboardingNode)
        }
        self.screenNode.state = self.state
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        self.draggable = false
        
        let node = InitialControllerNode()

        self.screenNode = node
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            n.measureWithSizeRange(ASSizeRangeMake(self.size, self.size))
        }
    }
    
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        if self.state == .Onboarding {
            self.didChangeStateScreen(self.screenNode.onboardingNode)
        } else {
            self.didChangeStateScreen(self.screenNode.loginNode)
        }
    }
    override func didHide() {
        super.didHide()
        AnalyticsManager.sharedInstance.newScreen(oldScreen)
    }
}

extension InitialViewController : NodeTransitionDelegate {
    func didChangeStateScreen(node: ASDisplayNode) {
        AnalyticsScreen.new(node: node as! TrackedView)
    }
}

protocol NodeTransitionDelegate {
    func didChangeStateScreen(node : ASDisplayNode)
}

class InitialControllerNode : ASDisplayNode {
    
    var state : InitialVCState! {
        didSet {
            if oldValue != nil {
                self.transitionLayoutWithAnimation(true, shouldMeasureAsync: false, measurementCompletion: nil)
//                self.transitionLayoutWithSizeRange(<#T##constrainedSize: ASSizeRange##ASSizeRange#>, animated: <#T##Bool#>, shouldMeasureAsync: <#T##Bool#>, measurementCompletion: <#T##(() -> Void)!##(() -> Void)!##() -> Void#>)
//                    transitionLayoutWithAnimation(true)
            }
        }
    }
    var loginNode : LoginNode!
    var onboardingNode : OnboardingVCNode!
    var delegate : NodeTransitionDelegate!

    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func animateLayoutTransition(context: ASContextTransitioning!) {
        if self.state == .Login {            
            self.loginNode.alpha = 0
            self.onboardingNode.hideAnimation.toValue = 0
            
            
            UIView.animateWithDuration(0.4, animations: {
            
                self.loginNode.alpha = 1
                
            }, completion: {
            
                    finished in
                    context.completeTransition(finished)
                    self.delegate?.didChangeStateScreen(self.loginNode)
            })
        } else {
            self.onboardingNode.hideAnimation.toValue = 1
            
            
            UIView.animateWithDuration(0.4, animations: {
                
                self.loginNode.alpha = 0
                
                }, completion: {
                    
                    finished in
                    context.completeTransition(finished)
                    self.delegate?.didChangeStateScreen(self.onboardingNode)
            })
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let node : ASDisplayNode
        if state == .Onboarding {
            node = self.onboardingNode
    
        } else {
            node = self.loginNode
        }
        
        node.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        return ASStaticLayoutSpec(children: [node])
    }
}