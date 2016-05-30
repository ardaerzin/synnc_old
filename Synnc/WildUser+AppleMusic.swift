//
//  WildUser+AppleMusic.swift
//  Synnc
//
//  Created by Arda Erzin on 4/30/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUserManager
import WCLUtilities
import SwiftyJSON
import TwitterKit
import WCLMusicKit
import WCLNotificationManager

public extension WCLUser {
    public func applemusicInit(object : AnyObject!) -> WCLUserExtension {
        var options : [WCLUserExtensionOptions] = []
        if let obj = object as? WCLUserOptions, let o = obj.data {
            options = o
        }
        return WildAppleMusicUser(options: options)
    }
    
    
    var applemusic : WCLUserExtension? {
        get {
            if self.userExtension(.AppleMusic) == nil {
                
                self.setExtension(WildAppleMusicUser(options: []), type: .AppleMusic)
            }
            return self.userExtension(.AppleMusic)
        }
        set {
            if newValue != nil {
                if self.userExtension(.AppleMusic) == nil {
                    self.setExtension(WildAppleMusicUser(options: []), type: .AppleMusic)
                }
                self.userExtension(.AppleMusic)!.profileInfo = newValue
            }
        }
    }
    
}

extension WildAppleMusicUser : WCLMusicKitDelegate {
    func wclMusicKit(musicKit: WCLMusicKit, didChangeAuthStatus status: Bool?, withError error: NSError?) {
        self.loginStatus = status
        if let s1 = musicKit.status, let s2 = status where s1 {
            
            if !s2 && enableNotif {
                enableNotif = false
                SynncNotification(body: ("You need to login to Apple Music with your premium account.", "premium account"), image: "notification-access") {
                    notif in
                    
                    UIApplication.sharedApplication().openURL(NSURL(string: "music:account")!)
                }.addToQueue()
            }
        }
    }
    func wclMusicKit(musicKit: WCLMusicKit, didChangeAvailability status: Bool?, withError error: NSError?) {
        if let s = status where enableNotif {
            print("ENABLE NOTIF?", enableNotif)
            if !s {
                SynncNotification(body: ("You need to allow access to Apple Music before continuing", "allow access"), image: "notification-access") {
                    notif in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }.addToQueue()
            }
        } else if enableNotif {
            
            
            do {
                try musicKit.requestAuth()
            } catch {
                SynncNotification(body: ("Apple Music Playback is supported on iOS 9.3 or newer.", "iOS 9.3 or newer."), image: "notification-access").addToQueue()
            }
            
        }
    }
}

class WildAppleMusicUser : WCLUserExtension {
    
    var enableNotif : Bool = false
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
        self.type = .AppleMusic
        
        WCLMusicKit.sharedInstance.delegate = self
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    //Mark: Protocol Functions
    override func socialLogin() {
        self.loginWithAppleMusic()
    }
    override func socialLogout() {
        self.logoutAppleMusicSession()
    }
    override func loadOldSession() {
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
            
            url = ui.profileImageLargeURL
            
            if frame.width <= 15 {
                url = url?.stringByReplacingOccurrencesOfString("_normal", withString: "_mini")
            } else if frame.width <= 24 {
                
            } else if frame.width <= 35 {
                url = url?.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger")
            } else {
                url = url?.stringByReplacingOccurrencesOfString("_normal", withString: "")
            }
        }
        return url == nil ? nil : NSURL(string: url!)
    }
    
    //Mark: Login
    private func loginWithAppleMusic() {
        self.enableNotif = true
        WCLMusicKit.sharedInstance.authenticate()
    }
    
    //Mark: Logout
    /*
     Delete Soundcloud Session Cookies
     */
    private func logoutAppleMusicSession() {
        
    }
    
    internal func getUserAppleMusicProfile(){
//        twitterAPIClient?.loadUserWithID(self.session.userID) { (user, err) -> Void in
//            self.profileInfo = user
//        }
    }
    
    //Mark: Observers
    
    internal override func loginStatusChanged(){
        if let status = loginStatus where status {
            self.getUserAppleMusicProfile()
        } else {
            self.profileInfo = nil
        }
        super.loginStatusChanged()
        
        print("apple music user login status", self.loginStatus)
    }
}