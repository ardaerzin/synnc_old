////
////  SpotifyLoginViewController.swift
////  Synnc
////
////  Created by Arda Erzin on 5/9/16.
////  Copyright © 2016 Arda Erzin. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SafariServices
//import WCLPopupManager
//import WCLUserManager
//import WCLUtilities
//
//class AnaneController : UINavigationController {
//    var safariController : SFSafariViewController!
//    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        
//    }
//    init(url : NSURL) {
//        let a = SFSafariViewController(URL: url)
//        super.init(rootViewController: a)
//        self.navigationBar.hidden = true
//        safariController = a
//        
//        self.safariController.title = "ANANEN"
//        self.safariController.view.tintColor = .SynncColor()
////        self.safariController.delegate = self
//        
//        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SpotifyLoginViewController.safariViewControllerDidFinish(_:)))
//        self.safariController.navigationItem.rightBarButtonItem = cancelButton
//        
//        self.view.addSubview(self.safariController.view)
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        self.safariController.view.frame = self.view.bounds
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//class SpotifyLoginViewController : WCLPopupViewController {
//    var safariHolderController : AnaneController!
//    var url : NSURL!
//    
////    Controller : SFSafariViewController!
//    
//    init(size: CGSize?){
//        var s : CGSize
//        if let x = size {
//            s = x
//        } else {
//            s = UIScreen.mainScreen().bounds.size
//        }
//        super.init(nibName: nil, bundle: nil, size: s)
//        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center,.Bottom), toLocation: (.Center, .Center), withShadow: true)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    init(url: NSURL) {
//        let s = UIScreen.mainScreen().bounds.size
//        super.init(nibName: nil, bundle: nil, size: s)
//        self.url = url
//        
//        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center,.Bottom), toLocation: (.Center, .Center), withShadow: true)
//        
//        
//        safariHolderController = AnaneController(url: url)
//        safariHolderController.safariController.delegate = self
//        
//        self.view.addSubview(safariHolderController.view)
//        
//        
////        safariController = SFSafariViewController(URL: url)
//        
//        
////        safariController.navigationController?.navigationBar.barTintColor = UIColor.SynncColor()
////        safariController.delegate = self
////        safariController.view.backgroundColor = .redColor()
//        
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SpotifyLoginViewController.loginStatusChanged(_:)), name: "\(WCLUserLoginType.Spotify.rawValue)LoginStatusChanged", object: nil)
//    }
//    
//    func loginStatusChanged(notif: NSNotification) {
//        print("ANANEN")
////        self.closeView(true)
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        safariHolderController.view.frame = self.view.bounds
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
//
//extension SpotifyLoginViewController : SFSafariViewControllerDelegate {
//    func safariViewControllerDidFinish(controller: SFSafariViewController) {
//        self.closeView(true)
//    }
//    
//    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
//        print("******didCompleteInitialLoad")
//    }
////    func safariViewController(controller: SFSafariViewController, activityItemsForURL URL: NSURL, title: String?) -> [UIActivity] {
////        print("activity items:")
////    }
//}