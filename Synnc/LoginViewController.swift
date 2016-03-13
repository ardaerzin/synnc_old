//
//  LoginViewController.swift
//  Synnc
//
//  Created by Arda Erzin on 11/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
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
import SafariServices

class LoginViewController : ASViewController {
    
    var screenNode : LoginNode!
    var loginCallback : ((status : Bool)->Void)?
    var user : MainUser! {
        get {
            return Synnc.sharedInstance.user
        }
    }
    deinit {
    }
    
    init(){
        let node = LoginNode()
        super.init(node: node)
        
//        Gai.share
        
        
        node.buttonHolder.facebookLoginButton.addTarget(self, action: Selector("loginWithFacebook:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.buttonHolder.twitterLoginButton.addTarget(self, action: Selector("loginWithTwitter:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
//        node.buttonHolder.actionButton.addTarget(self, action: Selector("displaySignupForm:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.formSwitcher.switchButton.addTarget(self, action: Selector("switchForm:"), forControlEvents: .TouchUpInside)
        self.screenNode = node
        
        self.screenNode.legal.delegate = self
        self.screenNode.legal.userInteractionEnabled = true
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            self.user.delegate = nil
            self.screenNode.buttonHolder.facebookLoginButton.removeTarget(self, action: Selector("loginWithFacebook:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            self.screenNode.buttonHolder.twitterLoginButton.removeTarget(self, action: Selector("loginWithTwitter:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            
//            self.screenNode.buttonHolder.actionButton.removeTarget(self, action: Selector("displaySignupForm:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            self.screenNode.formSwitcher.switchButton.removeTarget(self, action: Selector("switchForm:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            self.screenNode.removeFromSupernode()
            self.screenNode = nil
            self.loginCallback = nil
        }
        
        super.didMoveToParentViewController(parent)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let root = self.parentViewController as? RootViewController {
            root.displayStatusBar = false
        }
        self.screenNode.alpha = 0
        if let c1 = self.user.isLoggedIn(.Facebook), let c2 = self.user.isLoggedIn(.Twitter), let c3 = self.user.isLoggingIn(.Facebook), let c4 = self.user.isLoggingIn(.Twitter) where c1 || c2 || c3 || c4 {
//            self.screenNode.formNode.serverCheckStatusAnimation.toValue = 1
        } else {
//            self.screenNode.formNode.serverCheckStatusAnimation.toValue = 0
        }
        self.user.delegate = self
        self.parentViewController?.prefersStatusBarHidden()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.screenNode.alpha = 1
    }
}

extension LoginViewController : ASTextNodeDelegate {
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

extension LoginViewController {
    
    func loginWithFacebook(sender : AnyObject){
        Synnc.sharedInstance.user.socialLogin(.Facebook)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "facebook_login", value: nil)
    }
    func displaySignupForm(sender : ASButtonNode) {
//        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
//            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "This login options is not available yet", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
//        }
//        self.screenNode.formHolder.state = .Signup
    }
    func loginWithTwitter(sender : AnyObject){
//        self.screenNode.serverCheckStatusAnimation.toValue = 1
//        Synnc.sharedInstance.user.socialLogin(.Twitter)
        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "This login options is not available yet", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
        }
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "twitter_login", value: nil)
    }
    
    func switchForm(sender : ASButtonNode){
//        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
//            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "This login options is not available yet", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
//        }
        
//        let a = self.screenNode.formSwitcher.targetState
        self.screenNode.state = self.screenNode.formSwitcher.targetState
//        self.screenNode.formSwitcher.targetState = a == .Login ? .Signup : .Login
    }
}

extension LoginViewController : WCLUserDelegate {
    func wildUser(user: WCLUser, loginStatusChanged status: Bool) {
        if status == true {
            //user is new?
            self.screenNode.spinnerNode.updateForUser(user as! MainUser)
            self.screenNode.spinnerNode.loginStatusAnimation.toValue = 1
            Async.main(after: 2) {
                if let root = self.parentViewController as? RootViewController {
                    root.displayStatusBar = true
                }
      
                
                if let p = self.parentViewController as? InitialViewController {
                    p.closeView(true)
                }
                
                
                Synnc.sharedInstance.socket!.emit("user:update", [ "id" : self.user._id, "lat" : 0, "lon" : 0])
            }
        } else {
            
        }
    }
    func wildUser(user: WCLUser, loginStatusChanged status: Bool, forExtension ext: String) {
        
        if status == false {
            self.screenNode.serverCheckStatusAnimation.toValue = 0
        } else {
            if ext == WCLUserLoginType.Facebook.rawValue || ext == WCLUserLoginType.Twitter.rawValue {
                self.screenNode.serverCheckStatusAnimation.toValue = 1
            } else {
            }
        }
    }
}