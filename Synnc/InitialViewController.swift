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
        
//        if let seenOnboarding = WildDataManager.sharedInstance().getUserDefaultsValue("seenOnboarding") as? Bool where seenOnboarding {
//            state = .Login
//            self.screenNode.addSubnode(self.screenNode.loginNode)
//            print("already seen onboarding")
//        } else {
//            state = .Onboarding
//            self.screenNode.addSubnode(self.screenNode.onboardingNode)
//            print("not seen onboarding")
//        }
        
        state = .Login
        self.screenNode.addSubnode(self.screenNode.loginNode)
        
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
//        node.skipButton.addTarget(self, action: Selector("skipToLogin:"), forControlEvents: .TouchUpInside)
    }
    
//    func skipToLogin(sender: ButtonNode) {
////        print("skip action")
////        
////        self.closeView(true)
//    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
////        node.pager.setDataSource(self)
////        node.pager.view.asyncDelegate = self
//    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            n.measureWithSizeRange(ASSizeRangeMake(self.size, self.size))
        }
    }
}

class InitialControllerNode : ASDisplayNode {
    
    var state : InitialVCState! {
        didSet {
            if oldValue != nil {
                self.transitionLayoutWithAnimation(true)
            }
        }
    }
    var loginNode : LoginNode!
//        {
//        didSet {
//            self.addSubnode(loginNode)
//        }
//    }
    var onboardingNode : OnboardingVCNode!
//        {
//        didSet {
//            self.addSubnode(onboardingNode)
//        }
//    }
    
//    var switcher : ButtonNode!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
    }
    
    
    override func animateLayoutTransition(context: ASContextTransitioning!) {
        if self.state == .Login {
            
//            let onboardingFrame = context.initialFrameForNode(self.onboardingNode)
//            let loginFrame = context.initialFrameForNode(self.loginNode)
    
            self.loginNode.alpha = 0
            self.onboardingNode.hideAnimation.toValue = 0
            
            
            UIView.animateWithDuration(0.4, animations: {
            
                self.loginNode.frame.origin.y = 0
                self.loginNode.alpha = 1
                
            }, completion: {
            
                    finished in
                    context.completeTransition(finished)
//                    (UIApplication.sharedApplication().windows.first?.rootViewController as! RootViewController).initialController.loginController.didMoveToParentViewController((UIApplication.sharedApplication().windows.first?.rootViewController as! RootViewController).initialController)
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
        
        
//        node.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 0.5), ASRelativeDimension(type: .Percent, value: 0.5))
        
        return ASStaticLayoutSpec(children: [node])
    }
}