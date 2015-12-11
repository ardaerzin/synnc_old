//
//  AppDelegate.swift
//  Synnc
//
//  Created by Arda Erzin on 11/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Socket_IO_Client_Swift
import TwitterKit
import Fabric
import DeviceKit

extension UIColor {
    class func SynncColor() -> UIColor {
        return UIColor(red: 236/255, green: 102/255, blue: 88/255, alpha: 1)
    }
}
@UIApplicationMain
class Synnc : UIResponder, UIApplicationDelegate {
    
    var user : MainUser!
    var socket: SocketIOClient!
    var device = Device()
    var window: UIWindow?
    
    class var sharedInstance : Synnc {
        get {
            return UIApplication.sharedApplication().delegate as! Synnc
        }
    }
    
    override init() {
        super.init()
        
        Twitter.sharedInstance().startWithConsumerKey("gcHZAHdyyw3DaTZmgqqj8ySlH", consumerSecret: "mf1qWT6crYL7h3MUhaNeV7A7tByqdMx1AXjFqBzUnuIo1c8OES")
        Fabric.with([Twitter.sharedInstance()])
        
        self.socket = initSocket("https://silver-sister.codio.io:9500")
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.user = MainUser(socket: self.socket)
        
        //Initialize rootViewController for main window
//        let a = BackgroundViewController()
//        let b = MainMapStripController(backgroundController: a)
//        
//        
//        self.menuController = MenuViewController()
        self.window?.rootViewController = RootViewController()
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
//
//        let window = WCLWindowManager.sharedInstance.newWindow(b, animated: false, options: WCLWindowOptions(link: true, drag: true, limit: 315))
//        if let x = window.rootViewController as? WCLWindowRootVC {
//            x.navigationBarHidden = true
//        }
        
//        window.layer.shadowPath = UIBezierPath(rect: CGRectMake(0, 0, window.bounds.width + 50, window.bounds.height)).CGPath
//        
//        window.layer.shadowColor = UIColor.blackColor().CGColor
//        window.layer.shadowOpacity = 0.5
//        window.layer.shadowRadius = 5
//        window.layer.shadowOffset = CGSizeMake(-20, -5)
        
//        window.dismissButton.alpha = 0
//        self.user = MainUser(alternatives: [.Facebook])
//        self.user.needsToNotify = true
//        
//        if !self.user.status {
//            let lc = LoginController(callback: { (status) -> Void in
//                if status {
//                    b.updateUIForUser()
//                }
//            })
//            
//            let opts = WCLPopupAnimationOptions(fromLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Bottom), toLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Center), withShadow: false)
//            let x = WCLPopupViewController(nibName: nil, bundle: nil, options: opts, size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size)
//            x.addChildViewController(lc)
//            lc.view.frame = x.view.bounds
//            x.view.addSubview(lc.view)
//            lc.didMoveToParentViewController(x)
//            
//            x.view.backgroundColor = UIColor.redColor()
//            WCLPopupManager.sharedInstance.newPopup(x)
//            
//        } else {
//            menuController.updateForUser()
//        }
        
        for name in UIFont.familyNames() {
//            print("*!*!*!*!**!*!*!")
//            print(name)
//            if let nameString = name as? String
//            {
//                print(UIFont.fontNamesForFamilyName(name))
//            }
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

extension Synnc {
    func initSocket(urlStr : String) -> SocketIOClient {
        let x = SocketIOClient(socketURL: urlStr, options: [.Reconnects(false), .ForceWebsockets(true)])
        x.on("connect", callback: connectCallback)
        x.connect()
        return x
    }
    var connectCallback : NormalCallback {
        return {
            [weak self]
            (data, ack) in
            
            print("SOCKET CONNECTED")
            
            if self == nil {
                return
            }
        }
    }
}