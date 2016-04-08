//
//  AppDelegate.swift
//  Synnc
//
//  Created by Arda Erzin on 11/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import SocketIOClientSwift
import TwitterKit
import Fabric
import WCLSoundCloudKit
import WCLDataManager
import Cloudinary
import WCLLocationManager
import WCLUtilities
import CoreLocation
import WCLPopupManager
import AsyncDisplayKit
import WCLUserManager
import WCLNotificationManager
import Crashlytics
import SwiftyJSON
import WCLUIKit

#if DEBUG
let socketURLString = "https://digital-reform.codio.io:9500"
//let socketURLString = "https://synnc.herokuapp.com"
let analyticsId = "UA-65806539-3"
#else
let socketURLString = "https://synnc.herokuapp.com"
let analyticsId = "UA-65806539-4"
#endif

@UIApplicationMain
class Synnc : UIResponder, UIApplicationDelegate {
    
    var serverAvailable : Bool = false {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("SERVER STATUS CHANGED", object: nil, userInfo: ["status" : serverAvailable])
        }
    }
    class var appIcon : UIImage! {
        get {
            let primaryIconsDictionary = NSBundle.mainBundle().infoDictionary?["CFBundleIcons"]?["CFBundlePrimaryIcon"] as? NSDictionary
            let iconFiles = primaryIconsDictionary!["CFBundleIconFiles"] as! NSArray
            let lastIcon = iconFiles.lastObject as! NSString //last seems to be largest, use first for smallest
            return UIImage(named: lastIcon as String)
        }
    }
    
    var topPopupManager : WCLPopupManager!
    let version: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    var bgTime : NSTimer!
    var backgroundTask : UIBackgroundTaskIdentifier!
    
    var locationManager : WCLLocationManager = WCLLocationManager.sharedInstance()
    var chatManager : ChatManager!
    var imageUploader : CLUploader!
    dynamic var user : MainUser!
    var socket: SocketIOClient!
    var window: UIWindow?
    lazy var firstLogin : Bool = {
        if let x = WildDataManager.sharedInstance().getUserDefaultsValue("firstLogin") as? Bool {
            return x
        } else {
            return true
        }
    }()
    var streamManager : StreamManager! {
        return StreamManager.sharedInstance
    }
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
        
        let gai = GAI.sharedInstance()
        gai.trackerWithName("SynncTracker", trackingId: analyticsId)
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.Error  // remove before app release
        gai.dispatchInterval = 10
        
        Twitter.sharedInstance().startWithConsumerKey("gcHZAHdyyw3DaTZmgqqj8ySlH", consumerSecret: "mf1qWT6crYL7h3MUhaNeV7A7tByqdMx1AXjFqBzUnuIo1c8OES")
        Fabric.with([Answers(), Crashlytics.sharedInstance(), Twitter.sharedInstance()])
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let request = NSMutableURLRequest(URL: NSURL(string: socketURLString+"/api/settings")!)
        request.HTTPMethod = "GET"
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
        
            guard let d = data else {
                print("NO RESPONSE FROM SERVER")
                return
            }
        
            let json = JSON(data: d)
            Async.main {
                if let minReqVersion = json["minCompatibleVersion"].string where self.version.compareToMinRequiredVersion(minReqVersion) >= 0 {
                    self.serverAvailable = true
                    self.socket?.connect()
                } else {
                    let x = NotCompatiblePopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
                    self.topPopupManager.newPopup(x)
                }
            }
            
        }.resume()
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.locationManager.delegate = self
        self.locationManager.initLocationManager()
        
        WildDataManager.sharedInstance().setCoreDataStack(dbName: "SynncDB", modelName: "SynncDataModel", bundle: nil, iCloudSync: false)
        
        let x = RootWindowController()
        
        let opts = WCLWindowOptions(link: true, draggable: false, windowLevel : 0, limit: 0)
        
        let a = WCLWindowManager.sharedInstance.newWindow(x, animated: false, options: opts)
        a.delegate = x
        self.window = a
        a.display(false)
        
        //Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Synnc.willChangeStatusBarFrame(_:)), name: UIApplicationWillChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Synnc.didChangeStatusBarFrame(_:)), name: UIApplicationDidChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Synnc.userProfileInfoChanged(_:)), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Synnc.syncCompleteNotification(_:)), name: kNHNetworkTimeSyncCompleteNotification, object: nil)
        
        self.window?.makeKeyAndVisible()

        self.initSynnc()
        performNTPCheck()
        
        topPopupManager = WCLPopupManager()
        
        
        let lagFreeField: UITextField = UITextField()
        self.window?.addSubview(lagFreeField)
        lagFreeField.becomeFirstResponder()
        lagFreeField.resignFirstResponder()
        lagFreeField.removeFromSuperview()
        
        return true
    }
    
    func initSynnc(){
        self.socket = self.initSocket()
        WCLUserManager.sharedInstance.configure(self.socket, cloudinaryInstance : _cloudinary)
        
        self.chatManager = ChatManager.sharedInstance()
        self.chatManager.setupSocket(self.socket)
        
        self.user = MainUser(socket: self.socket)
        self.streamManager.setSocket(self.socket)
    }
    
    var ntpShit : NSDate!
    func performNTPCheck(){
        ntpShit = NSDate()
        NHNetworkClock.sharedNetworkClock().syncWithComplete(nil)
    }
    
    func syncCompleteNotification(notification : NSNotification){
        
        let x = NSDate().timeIntervalSince1970 - ntpShit.timeIntervalSince1970
        if x >= 5 {
            self.performNTPCheck()
            NHNetworkClock.sharedNetworkClock().networkOffset
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event != nil && event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPause :
                //                MusicApp.sharedInstance().streamManager.playPauseStream(false)
                break
            case UIEventSubtype.RemoteControlPlay :
                //                MusicApp.sharedInstance().streamManager.playPauseStream(true)
                break
            default :
                return
            }
        }
    }
    
    func willChangeStatusBarFrame(notification : NSNotification!){
    }
    func didChangeStatusBarFrame(notification : NSNotification!){
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        bgTime = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: #selector(Synnc.timerMethod(_:)),
            userInfo: nil,
            repeats: true)
        
        backgroundTask =
            UIApplication.sharedApplication().beginBackgroundTaskWithName("task1",
                expirationHandler: {[weak self] in
                    self!.endBackgroundTask()
                })
    }
    
    func endBackgroundTask(){
        
        let mainQueue = dispatch_get_main_queue()
        
        dispatch_async(mainQueue, {[weak self] in
            if let timer = self!.bgTime{
                timer.invalidate()
                self!.bgTime = nil
                UIApplication.sharedApplication().endBackgroundTask(
                    self!.backgroundTask)
                self!.backgroundTask = UIBackgroundTaskInvalid
            }
            })
    }
    func timerMethod(sender: NSTimer){
        
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
        //        let authCallback : SPTAuthCallback = {
        //            (err, session) in
        //
        //            if let u = self.user.userExtension(.Spotify) as? WildSpotifyUser {
        //                u.sptAuthenticationStatus(session, error: err)
        //            }
        //        }
        
        //        if SPTAuth.defaultInstance().canHandleURL(url) {
        //            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: authCallback)
        //            return true
        //        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

extension Synnc {
    func initSocket() -> SocketIOClient! {
        guard let url = NSURL(string: socketURLString) else {
            assertionFailure("not a valid server address")
            return nil
        }
        
        let socket = SocketIOClient(socketURL: url, options: [SocketIOClientOption.Reconnects(true), SocketIOClientOption.ForceWebsockets(true)])
        socket.on("connect", callback: connectCallback)
        
        if self.serverAvailable {
            socket.connect()
        }
        return socket
    }
    var connectCallback : NormalCallback {
        return {
            [weak self]
            (data, ack) in
            
            if self == nil {
                return
            }
            
            Genre.socketSync(self!.socket, inStack: WildDataManager.sharedInstance().coreDataStack)
        }
    }
}

extension Synnc {
    func userProfileInfoChanged(notification: NSNotification) {
        if self.user._id != nil {
            socket!.emit("user:update", [ "id" : self.user._id, "lat" : 0, "lon" : 0])
            if self.user.generatedUsername {
//                let x = FirstLoginPopupVC(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
//                x.node.yesButton.addTarget(self, action: Selector("goToProfile:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
//                WCLPopupManager.sharedInstance.newPopup(x)
            }
            StreamManager.sharedInstance.updateUserFeed()
            SynncPlaylist.socketSync(self.socket, inStack: WildDataManager.sharedInstance().coreDataStack, withMessage: "ofUser", dictValues: ["user_id" : self.user._id])
        }
    }
}

extension Synnc : WCLLocationManagerDelegate {
    //Mark: LocationManager Delegate
    func locationManager(manager: WCLLocationManager, updatedLocation location: CLLocation) {
        if self.user._id == nil {
            return
        }
    }
    func locationManager(manager: WCLLocationManager, changedAuthStatus newStatus: Int) {
        switch newStatus {
        case 1:
            locationManager.initGPSTracking()
            break
        default:
            return
        }
    }
    
    func locationAuthController() -> SynncLocationAuthVC {
        let x = SynncLocationAuthVC(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
        return x
    }
}

var SCEngine : WildSoundCloud = {
    return  WildSoundCloud.sharedInstance()
}()
var _cloudinary = CLCloudinary(url: "cloudinary://326995197724877:tNcnWLiEn2oQJDrHIai_546rwrQ@dyl3itg0k")