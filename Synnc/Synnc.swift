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
import WCLSoundCloudKit
import WCLDataManager
import Cloudinary

extension UIColor {
    class func SynncColor() -> UIColor {
        return UIColor(red: 236/255, green: 102/255, blue: 88/255, alpha: 1)
    }
}

@UIApplicationMain
class Synnc : UIResponder, UIApplicationDelegate {
    
    var imageUploader : CLUploader!
    var user : MainUser!
    var socket: SocketIOClient!
    var device = Device()
    var window: UIWindow?
    
    var moc : NSManagedObjectContext {
        get {
            return WildDataManager.sharedInstance().coreDataStack.getMainContext()
        }
    }
    
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
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        SPTAuth.defaultInstance().sessionUserDefaultsKey = "SynncSPT"
        SPTAuth.defaultInstance().clientID = "45dabbd3f3e946618030f229ad92b721"
        SPTAuth.defaultInstance().tokenRefreshURL = NSURL(string: "https://ivory-yes.codio.io:9500/refresh")
        SPTAuth.defaultInstance().tokenSwapURL = NSURL(string: "https://ivory-yes.codio.io:9500/swap")
        SPTAuth.defaultInstance().redirectURL = NSURL(string: "synnc://callback")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthUserReadPrivateScope, SPTAuthStreamingScope]
        
        WildDataManager.sharedInstance().setCoreDataStack(dbName: "SynncDB", modelName: "SynncDataModel", bundle: nil, iCloudSync: false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.user = MainUser(socket: self.socket)
        
        //Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userProfileInfoChanged:"), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        
        //Initialize rootViewController for main window
        self.window?.rootViewController = RootViewController()
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
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

extension Synnc {
    func userProfileInfoChanged(notification: NSNotification) {
        if self.user._id != nil {
            print("socket synnc now")
            SynncPlaylist.socketSync(self.socket, inStack: nil, withMessage: "ofUser", dictValues: ["user_id" : self.user._id])
        }
    }
}

var SCEngine : WildSoundCloud = {
    return  WildSoundCloud.sharedInstance()
}()
var _cloudinary = CLCloudinary(url: "cloudinary://326995197724877:tNcnWLiEn2oQJDrHIai_546rwrQ@dyl3itg0k")