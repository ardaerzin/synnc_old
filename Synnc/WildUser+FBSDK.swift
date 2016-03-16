//
//  WildUser+FBSDK.swift
//  UserManagerDev
//
//  Created by Arda Erzin on 3/2/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import WCLUtilities
import WCLUserManager
import SwiftyJSON

public extension WCLUser {
    
    public func facebookInit(object : AnyObject!) -> WCLUserExtension {
        var options : [WCLUserExtensionOptions] = []
        if let obj = object as? WCLUserOptions, let o = obj.data {
            options = o
        }
        return WildFacebookUser(options: options)
    }
    
    
    var facebook : WCLUserExtension? {
        get {
            if self.userExtension(.Facebook) == nil {
                self.setExtension(WildFacebookUser(options: []), type: .Facebook)
            }
            return self.userExtension(.Facebook)
        }
        set {
            if newValue != nil {
                if self.userExtension(.Facebook) == nil {
                    self.setExtension(WildFacebookUser(options: []), type: .Facebook)
                }
                self.userExtension(.Facebook)!.profileInfo = newValue
            }
        }
    }
}

class WildFacebookUser : WCLUserExtension {
    
    override var accessToken : String? {
        didSet {
            var a : String = ""
            if let at = accessToken {
                a = at
            }
            self.loginData = ["accessToken" : a]
        }
    }
    override var id : String? {
        get {
            var x : String? = nil
            if self.profileInfo != nil {
                var json = JSON(self.profileInfo!)
                x = json["userID"].string
            }
            return x
        }
    }
    required init(options : [WCLUserExtensionOptions] = []) {
        super.init(options: options)
        self.type = .Facebook
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("accessTokenObserver:"), name: FBSDKAccessTokenDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("profileInfoObserver:"), name: FBSDKProfileDidChangeNotification, object: nil)
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    }
    required init() {
        fatalError("init() has not been implemented")
    }
    
    //    required init(loadOldSession: Bool = false, requireServerAuth: Bool = false) {
    //
    //        super.init(loadOldSession: loadOldSession, requireServerAuth: requireServerAuth)
    //        self.type = .Facebook
    //
    //
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("accessTokenObserver:"), name: FBSDKAccessTokenDidChangeNotification, object: nil)
    //        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("profileInfoObserver:"), name: FBSDKProfileDidChangeNotification, object: nil)
    //
    //        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
    //    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //Mark: Protocol Functions
    override func socialLogin() {
        self.loginWithFacebook(self.defaultPermissions, showUI: true, completionHandler: nil)
    }
    override func socialLogout() {
        self.logoutFromFacebook()
    }
    override func refresh(){
        accessTokenObserver(nil)
    }
    override func loadOldSession() {
        if let _ = FBSDKAccessToken.currentAccessToken() {
            self.loginStatus = false
            self.isLoggingIn = true
        }
    }
    override func avatarUrl(frame: CGRect, scale: CGFloat) -> NSURL? {
        
        var url : String?
        if self.profileInfo != nil {
            var json = JSON(profileInfo!)
            var fbid : String!
            
            if let x = json["userID"].string {
                fbid = x
            } else if let y = json["id"].string {
                fbid = y
            }
            if fbid != nil {
                url = "https://graph.facebook.com/\(fbid!)/picture?height=\(Int(frame.height*scale))&width=\(Int(frame.width*scale))"
            }
        }
        
        return url == nil ? nil : NSURL(string: url!)
    }
    //Mark: Facebook Functions
    internal func checkOldSession(){
        
    }
    override func profileInfoChanged() {
        super.profileInfoChanged()
    }
    func profileInfoObserver(notification: NSNotification!){
        ENTRY_LOG()
        
        let profile : FBSDKProfile! = FBSDKProfile.currentProfile()
        if profile == nil || self.accessToken == nil {
            SLogVerbose("profile is nil")
            self.profileInfo = nil
        } else {
            
            self.updatedAt = profile.refreshDate
            var keys = profile.propertyNames(FBSDKProfile)
            keys.removeAtIndex(keys.indexOf("refreshDate")!)
            keys.removeAtIndex(keys.indexOf("linkURL")!)
            
            self.profileInfo = profile.dictionaryWithValuesForKeys(keys)
            SLogVerbose("profile is not nil")
        }
        
        EXIT_LOG()
    }
    func accessTokenObserver(notification: NSNotification!){
        ENTRY_LOG()
        
        let prevStatus = self.loginStatus
        let token = FBSDKAccessToken.currentAccessToken()
        self.isLoggingIn = false
        if token == nil {
            self.accessToken = nil
            self.loginStatus = false
            SLogVerbose("cannot find access token")
        } else {
            self.accessToken = token.tokenString
            self.loginStatus = true
            self.profileInfoObserver(nil)
            SLogVerbose("access token found")
        }
        
        if prevStatus == nil && loginStatus == false {
            return
        }
        
        let s = loginStatus!
        AnalyticsEvent.new(category : "login_handler", action: "facebook", label: s ? "true" : "false", value: nil)
        EXIT_LOG()
        
    }
    internal func loginWithFacebook(permissions: [String], showUI: Bool, completionHandler: ((state: Bool) -> Void)?){
        
        ENTRY_LOG()
        
        self.isLoggingIn = true
        
        FBSDKLoginManager().logInWithReadPermissions(permissions, fromViewController: nil, handler: {
            
            (result, error) in
            if error != nil {
                AnalyticsEvent.new(category : "login_action", action: "facebook", label: "error", value: error!.code)
                print(error!.description)
                SLogError("Error with FBLogin process")
            } else if result.isCancelled {
                AnalyticsEvent.new(category : "login_action", action: "facebook", label: "cancelled", value: nil)
                SLogWarning("Cancelled FBLogin process")
            } else {
                SLogVerbose("given permissions : \(result.grantedPermissions)")
                SLogVerbose("declined permissions : \(result.declinedPermissions)")
                SLogVerbose("token: \(result.token)")
            }
        })
        
        EXIT_LOG()
    }
    internal func logoutFromFacebook(){
        FBSDKLoginManager().logOut()
    }
    internal func getFacebookProfile(completionHandler : ((result: AnyObject?) -> Void)? ){
        
    }
    internal func userFBRequest(reqStr: String, callback: ((result: AnyObject?) -> Void)){
        
    }
    internal override func updateProfileInfo(json : JSON){
        self.profileInfo = json.object
    }
}