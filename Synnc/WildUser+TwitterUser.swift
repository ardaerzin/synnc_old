//
//  TwitterUser.swift
//  Synnc
//
//  Created by Arda Erzin on 12/5/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUserManager
import WCLUtilities
import SwiftyJSON
import TwitterKit

var twitterAPIClient : TWTRAPIClient?

public extension WCLUser {
    public func twitterInit(object : AnyObject!) -> WCLUserExtension {
        var options : [WCLUserExtensionOptions] = []
        if let obj = object as? WCLUserOptions, let o = obj.data {
            options = o
        }
        return WildTwitterUser(options: options)
    }
    
    
    var twitter : WCLUserExtension? {
        get {
            if self.userExtension(.Twitter) == nil {
                
                self.setExtension(WildTwitterUser(options: []), type: .Twitter)
            }
            return self.userExtension(.Twitter)
        }
        set {
            if newValue != nil {
                if self.userExtension(.Twitter) == nil {
                    self.setExtension(WildTwitterUser(options: []), type: .Twitter)
                }
                self.userExtension(.Twitter)!.profileInfo = newValue
            }
        }
    }
    
}

class WildTwitterUser : WCLUserExtension {
    
    override var id : String? {
        get {
            var x : String? = nil
            if self.profileInfo != nil {
                var json = JSON(self.profileInfo!)
                x = json["id"].string
            }
            return x
        }
    }
    var accessTokenSecret : String?
    var session : TWTRAuthSession!
    
    required init(options : [WCLUserExtensionOptions] = []) {
        super.init(options: options)
        self.type = .Twitter
    }

    required init() {
        fatalError("init() has not been implemented")
    }
    
    
    //Mark: Protocol Functions
    override func socialLogin() {
        self.loginWithTwitter()
    }
    override func socialLogout() {
        self.logoutTwitterSession()
    }
    override func loadOldSession() {
        self.loadTwitterSession()
    }
    override func refresh(){
        loadOldSession()
        if let status = self.loginStatus where status {
            loginStatusChanged()
        }
    }
    override func avatarUrl(frame: CGRect, scale: CGFloat) -> NSURL? {
        
        var url : String? = "http://icons.iconarchive.com/icons/pelfusion/long-shadow-media/128/Contact-icon.png"
        
        if let ui = self.profileInfo as? TWTRUser {
            if let largeUrl = ui.profileImageLargeURL {
                url = largeUrl
            } else if let smallUrl = ui.profileImageURL {
                url = smallUrl
            }
        }
        return url == nil ? nil : NSURL(string: url!)
    }
    
    private func loadTwitterSession() {
        var status : Bool = false
        if let b = Twitter.sharedInstance().sessionStore.session() {
//            Twitter.sharedInstance().sessionStore.logOutUserID(b.userID)
            self.session = b
            self.accessTokenSecret = b.authTokenSecret
            self.accessToken = b.authToken
            status = true
        } else {
            self.session = nil
            self.accessToken = ""
            self.accessTokenSecret = ""
            status = false
        }
        
        self.loginData = ["accessToken" : self.accessToken!, "accessTokenSecret" : self.accessTokenSecret!]
        
        if status {
            twitterAPIClient = TWTRAPIClient.init(userID: self.session.userID)
        }
        self.loginStatus = status
    }
    
    //Mark: Login
    private func loginWithTwitter(){
        
        Twitter.sharedInstance().logInWithViewController(nil) { (session, error) -> Void in
            self.loadTwitterSession()
        }
    }
    
    //Mark: Logout
    /*
    Delete Soundcloud Session Cookies
    */
    private func logoutTwitterSession(){
        
//        SPTAuth.defaultInstance().session = nil
        self.accessToken = nil
        self.loginStatus = false
        
        //        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        //        //get soundcloud cookies
        //        let scCookies = storage.cookies?.filter({$0.domain.rangeOfString("soundcloud.com") != nil})
        //        for cookie in scCookies!{
        //            storage.deleteCookie(cookie)
        //        }
        //        NSUserDefaults.standardUserDefaults().synchronize()
        //        self.accessToken = nil
        //        SPTAuth.defaultInstance()
    }
  
    internal func getUserTwitterProfile(){
        twitterAPIClient?.loadUserWithID(self.session.userID) { (user, err) -> Void in
            self.profileInfo = user
        }
    }
    
    //Mark: Observers
    
    internal override func loginStatusChanged(){
        if let status = loginStatus where status {
            self.getUserTwitterProfile()
        } else {
            self.profileInfo = nil
        }
        super.loginStatusChanged()
    }
}