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

class LoginViewController : ASViewController {
    
    var screenNode : LoginNode!
    var loginCallback : ((status : Bool)->Void)?
    var user : MainUser! {
        get {
            return Synnc.sharedInstance.user
        }
    }
    deinit {
        print("deinit shit")
    }
    init(){
        let node = LoginNode()
        super.init(node: node)
        
        node.formNode.buttonHolder.facebookLoginButton.addTarget(self, action: Selector("loginWithFacebook:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.formNode.buttonHolder.twitterLoginButton.addTarget(self, action: Selector("loginWithTwitter:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.formNode.buttonHolder.regularLoginButton.addTarget(self, action: Selector("displaySignupForm:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.formNode.closeFormButton.addTarget(self, action: Selector("closeFormView:"), forControlEvents: .TouchUpInside)
        
        node.formNode.formSwitcher.switchButton.addTarget(self, action: Selector("switchForm:"), forControlEvents: .TouchUpInside)
        
        self.screenNode = node
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let root = self.parentViewController as? RootViewController {
            root.displayStatusBar = true
            root.setNeedsStatusBarAppearanceUpdate()
        }
        self.screenNode.formNode.alpha = 0
        if let c1 = self.user.isLoggedIn(.Facebook), let c2 = self.user.isLoggedIn(.Twitter), let c3 = self.user.isLoggingIn(.Facebook), let c4 = self.user.isLoggingIn(.Twitter) where c1 || c2 || c3 || c4 {
            print("ZA")
            self.screenNode.formNode.serverCheckStatusAnimation.toValue = 1
        } else {
            print("ZA2")
            self.screenNode.formNode.serverCheckStatusAnimation.toValue = 0
        }
        self.user.delegate = self
        self.parentViewController?.prefersStatusBarHidden()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.screenNode.formNode.formDisplayStatus = false
        self.screenNode.formNode.alpha = 1
//        self.screenNode.formNode.formDisplayAnimation.toValue = 0
    }
}

extension LoginViewController {
    
    func loginWithFacebook(sender : AnyObject){
        Synnc.sharedInstance.user.socialLogin(.Facebook)
    }
    func displaySignupForm(sender : ASButtonNode) {
        self.screenNode.formNode.formDisplayStatus = true
        self.screenNode.formNode.formHolder.state = .Signup
//        let v = WCLNotificationView.new(nibName: "NotificationView")!
//        WCLNotificationManager.sharedInstance().newNotification(v, info: WCLNotificationInfo(body: "You can try Facebook login instead.", title: "Feature not Available", image : "exclamation-medium"))
    }
    func loginWithTwitter(sender : AnyObject){
        Synnc.sharedInstance.user.socialLogin(.Twitter)
    }
    
    func switchForm(sender : ASButtonNode){
//        let v = WCLNotificationView.new(nibName: "NotificationView")!
//        WCLNotificationManager.sharedInstance().newNotification(v, info: WCLNotificationInfo(body: "You can try Facebook login instead.", title: "Feature not Available", image : "exclamation-medium"))
        let a = self.screenNode.formNode.formSwitcher.targetForm
        self.screenNode.formNode.formDisplayStatus = true
        self.screenNode.formNode.formHolder.state = self.screenNode.formNode.formSwitcher.targetForm
        self.screenNode.formNode.formSwitcher.targetForm = a == .Login ? .Signup : .Login
    }
    func closeFormView(sender : ASButtonNode) {
        self.screenNode.formNode.formHolder.state = FormNodeState.None
        self.screenNode.formNode.formDisplayStatus = false
    }
}

extension LoginViewController : WCLUserDelegate {
    func wildUser(user: WCLUser, loginStatusChanged status: Bool) {
        if status == true {
            //user is new?
            self.screenNode.formNode.spinnerNode.updateForUser(user)
            self.screenNode.formNode.spinnerNode.loginStatusAnimation.toValue = 1
            Async.main(after: 2) {
                self.screenNode.displayAnimation.toValue = 0
            }
        } else {
            
        }
    }
    func wildUser(user: WCLUser, loginStatusChanged status: Bool, forExtension ext: String) {
       
        if status == false {
        } else {
            
            if ext == WCLUserLoginType.Facebook.rawValue || ext == WCLUserLoginType.Twitter.rawValue {
                print("WAIT FOR SERVER RESPONSE")
                self.screenNode.formNode.serverCheckStatusAnimation.toValue = 1
            } else {
//                print("sex")
            }
        }
    }
}
