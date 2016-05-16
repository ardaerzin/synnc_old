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
import WCLUIKit
import Async

class SpotifyLVC : WCLPopupViewController {
    var loginController : SPTAuthViewController!
    
    init(controller : SPTAuthViewController) {
        super.init(nibName: nil, bundle: nil, size: UIScreen.mainScreen().bounds.size)
        self.loginController = controller
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didDisplay() {
        super.didDisplay()
        self.presentViewController(loginController, animated: true, completion: nil)
    }
    override func didHide() {
        super.didHide()
        loginController.dismissViewControllerAnimated(true, completion: nil)
    }
}

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
    
    var loginPopup : WCLPopupViewController!
//    var loginController : SpotifyLoginViewController!
    
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
        self.logoutSpotifySession()
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
            } else {
                self.accessToken = nil
                self.loginStatus = false
            }
        })
    }
    
    //Mark: Login
    private func loginWithSpotify(){
        
        let loginViewController = SPTAuthViewController.authenticationViewController()
        loginViewController.delegate = self
        loginViewController.modalPresentationStyle = .OverFullScreen
        
        let x = SpotifyLVC(controller: loginViewController)
        
        Synnc.sharedInstance.topPopupManager.newPopup(x)
        loginPopup = x
    }
    
    //Mark: Logout
    /*
    Delete Soundcloud Session Cookies
    */
    private func logoutSpotifySession(){
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
                    Async.main {
                        WCLNotification(body: ("You need a Spotify Premium Account to use Synnc.", "Premium Account"), image: "notification-access") {
                            notif in
                            
                            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.spotify.com/premium")!)
                        }.addToQueue()
                    }
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
            self.getUserSpotifyProfile(nil)
        }
    }
}

extension WildSpotifyUser : SPTAuthViewDelegate {
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        self.loginStatus = false
        if let p = loginPopup {
            p.closeView(true)
        }
    }
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        
        self.sptAuthenticationStatus(session, error: nil)
        if let p = loginPopup {
            p.closeView(true)
        }
    }
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        self.loginStatus = false
        if let p = loginPopup {
            p.closeView(true)
        }
    }
}