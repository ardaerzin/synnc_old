//
//  WildUser+SpotifyUser.swift
//  RadioHunt
//
//  Created by Arda Erzin on 9/19/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUserManager
import WCLUtilities
import SwiftyJSON
import WCLNotificationManager
import WCLPopupManager

public extension WCLUser {
    public func spotifyInit(object : AnyObject!) -> WCLUserExtension {
        var options : [WCLUserExtensionOptions] = []
        if let obj = object as? WCLUserOptions, let o = obj.data {
            options = o
        }
        return WildSpotifyUser(options: options)
    }
    
    
    var spotify : WCLUserExtension? {
        get {
            if self.userExtension(.Spotify) == nil {
                self.setExtension(WildSpotifyUser(options: []), type: .Spotify)
            }
            return self.userExtension(.Spotify)
        }
        set {
            if newValue != nil {
                if self.userExtension(.Spotify) == nil {
                    self.setExtension(WildSpotifyUser(options: []), type: .Spotify)
                }
                self.userExtension(.Spotify)!.profileInfo = newValue
            }
        }
    }
    
}


class WildSpotifyUser : WCLUserExtension {
    
    var loginController : SpotifyLoginViewController!
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
    var territory : String!
    override var accessToken : String? {
        didSet {
            var a : String = ""
            if let at = accessToken {
                a = at
            }
            self.loginData = ["accessToken" : a]
        }
    }
    
    required init(options : [WCLUserExtensionOptions] = []) {
        super.init(options: options)
        self.type = .Spotify
    }
    required init() {
        fatalError("init() has not been implemented")
    }
    
    //Mark: Protocol Functions
    override func socialLogin() {
        self.loginWithSpotify()
    }
    override func socialLogout() {
        self.logoutSoundcloudSession()
    }
    override func loadOldSession() {
        self.loadSpotifySession()
    }
    override func refresh(){
        loadOldSession()
    }
    override func avatarUrl(frame: CGRect, scale: CGFloat) -> NSURL? {
        
        var url : String? = "http://icons.iconarchive.com/icons/pelfusion/long-shadow-media/128/Contact-icon.png"
        
        if self.profileInfo != nil {
            var json = JSON(profileInfo!)
            let avatarUrl = json["avatar_url"].string
            if avatarUrl != nil {
                url = avatarUrl!
            }
        }
        
        return url == nil ? nil : NSURL(string: url!)
    }
    
    private func loadSpotifySession() {
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session, callback: { (err, session) -> Void in
            if session != nil && session!.isValid() {
                self.accessToken = session.accessToken
                self.getUserSpotifyProfile(nil)
//                self.loginStatus = true
            } else {
                self.accessToken = nil
                self.loginStatus = false
            }
        })
    }
    
    //Mark: Login
    private func loginWithSpotify(){
        print("login url:", SPTAuth.defaultInstance().loginURL)
//        Async.main {
//            
//            if self.loginController == nil {
//                if let url = SPTAuth.defaultInstance().loginURL {
//                    print("login url:", url)
//                    var str = url.absoluteString
//                    if str.rangeOfString("spotify-action://") != nil {
//                        str = str.stringByReplacingOccurrencesOfString("spotify-action://", withString: "https://api.spotify.com/")
//                    }
//                    
//                    if let url2 = NSURL(string: str) {
//                        self.loginController = SpotifyLoginViewController(url: url2)
//                    }
//                    
//                }
//            }
//            
////            UIApplication.sharedApplication().windows.first
//            
////            WCLPopupManager.sharedInstance.newPopup(self.loginController)
//            UIApplication.sharedApplication().openURL(SPTAuth.defaultInstance().loginURL)
//        }
        
        let loginViewController = SPTAuthViewController.authenticationViewController()
        loginViewController.delegate = self
        loginViewController.modalPresentationStyle = .OverFullScreen
        
        //root view controller for presenting loginViewController
        let rootViewController = UIApplication.sharedApplication().delegate?.window!!.rootViewController
        
        //present loginViewController
        let x = rootViewController?.presentedViewController
        if x == nil {
            rootViewController?.presentViewController(loginViewController, animated: true, completion: nil)
        } else {
            x!.presentViewController(loginViewController, animated: true, completion: nil)
        }
    }
    
    //Mark: Logout
    /*
    Delete Soundcloud Session Cookies
    */
    private func logoutSoundcloudSession(){
        SPTAuth.defaultInstance().session = nil
        self.accessToken = nil
        self.loginStatus = false
    }
    
    lazy var spotifyQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Spotify queue"
        queue.maxConcurrentOperationCount = 1
        return queue
        }()
    
    internal func getUserSpotifyProfile(callback: ((status: Bool) -> Void)?){
        SPTUser.requestCurrentUserWithAccessToken(self.accessToken, callback: { (err, obj) in
            if let user = obj as? SPTUser {
                
                self.territory = user.territory
                self.profileInfo = user
                
                if user.product == SPTProduct.Premium {
                    self.loginStatus = true
                } else {
                    self.loginStatus = false
                }
                
                callback?(status: self.loginStatus)
            } else {
                self.profileInfo = nil
            }
        })
    }
    
    //Mark: Observers
    
    internal override func loginStatusChanged(){
        if let status = loginStatus where status {
//            self.getUserSpotifyProfile()
        } else {
            self.profileInfo = nil
        }
        super.loginStatusChanged()
    }
    
    func sptAuthenticationStatus(session : SPTSession!, error : NSError!) {
        if let err = error {
            print(#function, err.description)
            self.loginStatus = false
        } else if let sess = session {
            self.accessToken = sess.accessToken
            self.getUserSpotifyProfile({
                status in
                
                Async.main {
                    if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                        if status == false {
                            let info = WCLNotificationInfo(defaultActionName: "", body: "You need a Spotify Premium Account to use Synnc.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                                notif in
                                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.spotify.com/premium")!)
                            }
                            WCLNotificationManager.sharedInstance().newNotification(a, info: info)
                        }
                    }
                }
            })
//            self.loginStatus = true
        }
    }
}

extension WildSpotifyUser : SPTAuthViewDelegate {
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        self.loginStatus = false
    }
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        
        self.sptAuthenticationStatus(session, error: nil)
//        self.getUserSpotifyProfile()
//        self.loginStatus = true
        
    }
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        self.loginStatus = false
    }
}