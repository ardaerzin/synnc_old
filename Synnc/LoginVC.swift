//
//  LoginVC.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import FBSDKLoginKit
import WCLNotificationManager
import WCLUserManager
import WCLDataManager
import SafariServices

enum LoginVCState : Int {
    case Onboarding = 0
    case Login = 1
}

class LoginVC : ASViewController {
    
    var user : MainUser! {
        get {
            return Synnc.sharedInstance.user
        }
    }
    var gestureInitPoint : CGFloat!
    
    var screenNode : LoginVCHolder!
    var state : LoginVCState! {
        didSet {
            if state == .Onboarding {
                self.screenNode.onboardingNode = onboardingController.node
            }
            self.screenNode.state = state
            AnalyticsScreen.new(node: self.analyticsScreen)
        }
    }
    
    var analyticsScreen : TrackedView {
        get {
            return state == .Onboarding ? onboardingController.screenNode : self.screenNode.loginNode
        }
    }
    
    lazy var onboardingController : OnboardingVC = {
        let x = OnboardingVC()
        x.view.frame = UIScreen.mainScreen().bounds
        self.addChildViewController(x)
        
        return x
    }()
    
    init(){
        let node = LoginVCHolder()
        super.init(node: node)
        self.screenNode = node
        
        self.screenNode.loginNode.legal.delegate = self
        self.screenNode.loginNode.legal.userInteractionEnabled = true
        Synnc.sharedInstance.addObserver(self, forKeyPath: "user", options: [], context: nil)
        
        node.loginNode.buttonHolder.facebookLoginButton.addTarget(self, action: #selector(LoginVC.loginWithFacebook(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.loginNode.buttonHolder.twitterLoginButton.addTarget(self, action: #selector(LoginVC.loginWithTwitter(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        node.loginNode.toggleButton.addTarget(self, action: #selector(LoginVC.toggleLogin(_:)), forControlEvents: .TouchUpInside)
        node.loginNode.panRecognizer.addTarget(self, action: #selector(LoginVC.loginNodeDidPan(_:)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        if Synnc.sharedInstance.firstLogin {
            self.state = .Onboarding
        } else {
            self.state = .Login
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.user?.delegate = self
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        Synnc.sharedInstance.user.delegate = self
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}

extension LoginVC : ASTextNodeDelegate {
    func textNode(textNode: ASTextNode, tappedLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint, textRange: NSRange) {
        if let url = value as? NSURL {
            let a = (textNode.attributedString!.string as NSString).substringWithRange(textRange)
            let x = SFSafariViewController(URL: url)
            x.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(x, animated: true, completion: nil)
            AnalyticsEvent.new(category : "ui_action", action: "text_tap", label: a, value: nil)
        }
    }
}

extension LoginVC {
    func loginNodeDidPan(sender : UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        switch sender.state {
        case .Began :
            gestureInitPoint = screenNode.loginNode.translationY
            break
        case .Changed:
            let x = gestureInitPoint + translation.y
            let progress = POPProgress(x, startValue: self.screenNode.calculatedSize.height - 60, endValue: -60)
            self.screenNode.stateAnimationProgress = progress
            break
        case .Ended, .Cancelled :
            
            let vel = sender.velocityInView(self.view)
            let v = vel.y / (self.screenNode.calculatedSize.height)
            self.endedPanGesture(self.screenNode.stateAnimationProgress, velocity: v)
            break
        default:
            break
        }
    }
    
    func endedPanGesture(progress: CGFloat, velocity : CGFloat) {
        
        self.screenNode.stateAnimation.velocity = -velocity
        if progress > 0.5 || velocity < -3 {
            toggleLogin(nil)
        } else {
            self.state = .Onboarding
        }
    }
    
    func toggleLogin(sender: ButtonNode!) {
        self.state = .Login
        
        WildDataManager.sharedInstance().updateUserDefaultsValue("firstLogin", value: false)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Get Started", value: nil)
    }
}


extension LoginVC {
    
    func loginWithFacebook(sender : AnyObject){
        Synnc.sharedInstance.user.socialLogin(.Facebook)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "facebook_login", value: nil)
    }
    func loginWithTwitter(sender : AnyObject){
        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "This login options is not available yet", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
        }
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "twitter_login", value: nil)
    }
}

extension LoginVC : WCLUserDelegate {
    func wildUser(user: WCLUser, loginStatusChanged status: Bool) {
        if status == true {
            if let rvc = self.parentViewController as? RootWindowController {
                rvc.state = .LoggedIn
                rvc.displayFeed = true
            }
            self.screenNode.loginNode.loginStatusAnimation.toValue = 1
        } else {
            
        }
    }
    func wildUser(user: WCLUser, loginStatusChanged status: Bool, forExtension ext: String) {
        
        if status && ext == WCLUserLoginType.Facebook.rawValue || ext == WCLUserLoginType.Twitter.rawValue {
            self.screenNode.loginNode.serverCheckStatusAnimation.toValue = 1
        } else {
            self.screenNode.loginNode.serverCheckStatusAnimation.toValue = 0
        }
    }
}