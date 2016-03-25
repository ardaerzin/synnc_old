//
//  RVC.swift
//  Synnc
//
//  Created by Arda Erzin on 3/18/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import pop
import WCLUIKit
import WCLPopupManager
import WCLDataManager

enum RootWindowControllerState : Int {
    case Login = 1
    case LoggedIn = 2
}

//class RootWindowController : ASViewController {
//    init(){
//        let a = ASDisplayNode()
//        super.init(node: a)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//    }
//}
class RootWindowController : PagerBaseController {
    
    var displayFeed : Bool = false {
        didSet {
            if displayFeed {
                self.toggleFeed()
            }
        }
    }
    lazy var loginVC : LoginVC = {
        let x = LoginVC()
        x.view.frame = UIScreen.mainScreen().bounds
        self.addChildViewController(x)
        return x
    }()
    var state : RootWindowControllerState! = .Login {
        didSet {
            (self.screenNode as! RootNode).state = state
        }
    }
    
    lazy var profileController : ProfileController = {
        return ProfileController()
    }()
    lazy var settingsController : SettingsController = {
        return SettingsController()
    }()
    override var subControllers : [ASViewController]! {
        get {
            if self.childViewControllers.indexOf(profileController) == nil {
                self.addChildViewController(profileController)
            }
            if self.childViewControllers.indexOf(settingsController) == nil {
                self.addChildViewController(settingsController)
            }
            return [profileController, settingsController]
        }
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    init(){
        let node = RootNode()
        super.init(pagerNode: node)
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.screenNode = node
    }
    
    override func loadView() {
        super.loadView()
        (self.screenNode as! RootNode).loginNode = loginVC.node
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        print("touches began shit")
    }
    
    var homeWindow : WCLWindow!
    
    func toggleFeed(status : Bool? = nil){
        guard let s = status else {
            let vc = HomeController()
            let opts = WCLWindowOptions(link: false, draggable: true, windowLevel : UIWindowLevelStatusBar, limit: UIScreen.mainScreen().bounds.height - 60, dismissable : false)
            
            let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
            a.delegate = vc
            a.roundCorners([UIRectCorner.TopLeft, UIRectCorner.TopRight], radius: 10)
            a.animation.toValue = a.lowerPercentage
            
            self.homeWindow = a
            
            return
        }
        
        self.homeWindow.animation.toValue = s ? homeWindow.lowerPercentage : 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenNode.pager.setDataSource(self)
        self.screenNode.pager.delegate = self
    }
}