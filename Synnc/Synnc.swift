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
import DeviceKit
import WCLSoundCloudKit
import WCLDataManager
import Cloudinary
import WCLLocationManager
import WCLUtilities
import CoreLocation
import WCLPopupManager
import AsyncDisplayKit
import WCLUserManager
import Appsee
import WCLNotificationManager

#if DEBUG
    let serverURLString = "https://digital-reform.codio.io:9500"
    let appSeeKey = "86ad476123434fe0a2b616f443f0f1a3"
#else
    let serverURLString = "https://synnc.herokuapp.com"
    let appSeeKey = "86ad476123434fe0a2b616f443f0f1a3"
#endif

@UIApplicationMain
class Synnc : UIResponder, UIApplicationDelegate {
    
    class var appIcon : UIImage! {
        get {
            let primaryIconsDictionary = NSBundle.mainBundle().infoDictionary?["CFBundleIcons"]?["CFBundlePrimaryIcon"] as? NSDictionary
            let iconFiles = primaryIconsDictionary!["CFBundleIconFiles"] as! NSArray
            let lastIcon = iconFiles.lastObject as! NSString //last seems to be largest, use first for smallest
            return UIImage(named: lastIcon as String)
        }
    }
    
    var bgTime : NSTimer!
    var backgroundTask : UIBackgroundTaskIdentifier!
    
    lazy var streamNavigationController : StreamNavigationController! = {
        if let rvc = self.window?.rootViewController as? RootViewController {
            let a = StreamNavigationController()
            a.view.frame = UIScreen.mainScreen().bounds
            rvc.addChildViewController(a)
            rvc.view.addSubview(a.view)
            a.didMoveToParentViewController(rvc)
            return a
        } else {
            return nil
        }
    }()
    var locationManager : WCLLocationManager = WCLLocationManager.sharedInstance()
    var chatManager : ChatManager!
    var imageUploader : CLUploader!
    var user : MainUser!
    var socket: SocketIOClient!
    var device = Device()
    var window: UIWindow?
    
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
        Twitter.sharedInstance().startWithConsumerKey("gcHZAHdyyw3DaTZmgqqj8ySlH", consumerSecret: "mf1qWT6crYL7h3MUhaNeV7A7tByqdMx1AXjFqBzUnuIo1c8OES")
        Fabric.with([Twitter.sharedInstance()])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("detectedScreen:"), name: AppseeScreenDetectedNotification, object: nil)
        self.socket = initSocket()
        WCLUserManager.sharedInstance.configure(self.socket, cloudinaryInstance : _cloudinary)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        Appsee.start(appSeeKey)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("detectedScreen:"), name: AppseeScreenDetectedNotification, object: nil)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        self.chatManager = ChatManager.sharedInstance()
        self.chatManager.setupSocket(self.socket)
        
        self.locationManager.delegate = self
        self.locationManager.initLocationManager()
        
        WildDataManager.sharedInstance().setCoreDataStack(dbName: "SynncDB", modelName: "SynncDataModel", bundle: nil, iCloudSync: false)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.user = MainUser(socket: self.socket)
        
        //Notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willChangeStatusBarFrame:"), name: UIApplicationWillChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didChangeStatusBarFrame:"), name: UIApplicationDidChangeStatusBarFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userProfileInfoChanged:"), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        
        //Initialize rootViewController for main window
        let rvc = RootViewController()
        self.window?.rootViewController = rvc
        self.window?.backgroundColor = UIColor.whiteColor()
        
        self.window?.makeKeyAndVisible()
        
        self.streamManager.setSocket(self.socket)
        
        NHNetworkClock.sharedNetworkClock().syncWithComplete({
            let networkDate = NSDate.networkDate()
            let normalDate = NSDate()
            
            self.streamManager.player.syncManager.offSet = normalDate.timeIntervalSince1970 - networkDate.timeIntervalSince1970
            let diff = normalDate.timeIntervalSince1970 - networkDate.timeIntervalSince1970
            print("normal date:", normalDate.timeIntervalSince1970, "network date:", networkDate.timeIntervalSince1970, "diff is:", diff)
        })
        
        return true
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
    
    func detectedScreen(notification: NSNotification) {
        
        var userInfo = notification.userInfo
        let screenName = userInfo![kAppseeScreenName] as! String
        // To ignore a new screen set its value to nil
        
        print("detected screenName", screenName)
        
        userInfo![kAppseeScreenName] = nil
    }
    
    func willChangeStatusBarFrame(notification : NSNotification!){
        print("willChangeStatusBarFrame")
    }
    func didChangeStatusBarFrame(notification : NSNotification!){
        print("didChangeStatusBarFrame")
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
            selector: "timerMethod:",
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

extension Synnc : WCLNotificationManagerDelegate {
    func notificationManager(manager: WCLNotificationManager, didTapInappNotification notification: WCLNotificationView) {
//        if let info = notification.info {
//            switch info.defaultActionName {
//            case "OpenTab" :
//                if let rvc = self.window?.rootViewController as? RootViewController {
//                    rvc.willSetTabItem(rvc.screenNode.tabbar, item: info.object as! TabItem)
//                }
//                break
//            default:
//                return
//            }
//        }
    }
}

extension Synnc {
    func initSocket() -> SocketIOClient! {
        print(serverURLString)
        guard let url = NSURL(string: serverURLString) else {
            assertionFailure("not a valid server address")
            return nil
        }
        
        let socket = SocketIOClient(socketURL: url, options: [SocketIOClientOption.Reconnects(true), SocketIOClientOption.ForceWebsockets(true)])
        socket.on("connect", callback: connectCallback)
        socket.connect()
        return socket
    }
    var connectCallback : NormalCallback {
        return {
            [weak self]
            (data, ack) in
            
            if self == nil {
                return
            }
            
            Genre.socketSync(self!.socket, inStack: nil)
        }
    }
}

extension Synnc {
    func userProfileInfoChanged(notification: NSNotification) {
        if self.user._id != nil {
            
            if self.user.generatedUsername {
                let x = FirstLoginPopupVC(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
                x.node.yesButton.addTarget(self, action: Selector("goToProfile:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
                WCLPopupManager.sharedInstance.newPopup(x)
            }
            StreamManager.sharedInstance.updateUserFeed()
            SynncPlaylist.socketSync(self.socket, inStack: nil, withMessage: "ofUser", dictValues: ["user_id" : self.user._id])
        }
    }
    
    func goToProfile(sender : ButtonNode!) {
        if let rvc = self.window?.rootViewController as? RootViewController {
            rvc.willSetTabItem(rvc.screenNode.tabbar, item: rvc.meTab)
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