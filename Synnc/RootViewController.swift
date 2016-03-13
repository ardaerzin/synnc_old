//
//  RootViewController.swift
//  Synnc
//
//  Created by Arda Erzin on 11/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit
import pop
import WCLUIKit
import WCLNotificationManager
import WCLPopupManager
import FBSDKCoreKit
import FBSDKLoginKit

extension UIViewController {
    var rootViewController : RootViewController? {
        get {
            if let tb = self as? RootViewController {
                return tb
            } else if let sn = self.parentViewController {
                return sn.rootViewController
            } else {
                return nil
            }
        }
    }
}

class RootNavigationController : UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class RootViewController : ASViewController {
    
    var screenNode : TabControllerNode!
    var initialPopup : InitialViewController!
    var displayStatusBar : Bool = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var displayItem : TabItem! {
        didSet {
            self.screenNode.item = displayItem
            //            self.screenNode.updateForItem(displayItem)
            if let vc = displayItem as? TabItemController {
                vc.willBecomeActiveTab()
            }
        }
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return !displayStatusBar
    }
    
    var meTab : MeController! = MeController()
    var homeTab : HomeController! = HomeController()
    var playlistsTab : PlaylistsController! = PlaylistsController()
    var mystreamTab : MyStreamController! = MyStreamController()
    var searchTab : SearchController! = SearchController()
    
    
    init(){
        
        let controllers : [TabItemController] = [
            homeTab,
            searchTab,
            mystreamTab,
            playlistsTab,
            meTab
        ]
        
        let node = TabControllerNode(items: controllers)
        super.init(node: node)
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.screenNode = node
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        UXCam.tagScreenName("RootVC")
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialPopup = InitialViewController(size: UIScreen.mainScreen().bounds.size)
        WCLPopupManager.sharedInstance.newPopup(initialPopup)
    
        // Node Related
        self.screenNode.tabbar.delegate = self
    }
    
    
    
    
    var tabChangeAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("tabChangeAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! RootViewController).tabChangeAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! RootViewController).tabChangeAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var tabChangeAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("tabChangeAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.duration = 0.2
                x.property = self.tabChangeAnimatableProperty
                self.pop_addAnimation(x, forKey: "tabChangeAnimation")
                return x
            }
        }
    }
    var tabChangeAnimationProgress : CGFloat = 0 {
        didSet {
        }
    }
}
extension RootViewController {
    func dismissLoginController() {

    }
}

// MARK: - TabbarDelegate
extension RootViewController : TabbarDelegate {
    func willSetTabItem(tabbar: TabNode!, item: TabItem) -> Bool {
        
        if item.identifier == self.displayItem.identifier {
            return false
        }
        
        AnalyticsEvent.new(category : "ui_action", action: "tabButton_tap", label: item.identifier, value: nil)
        
        if item.identifier == "MyStreamController" {
            
            Synnc.sharedInstance.streamNavigationController.displayMyStream()
            return false
            
        } else {
            if let vc = self.displayItem as? TabItemController, let nvc = vc.navController {
                nvc.willMoveToParentViewController(nil)
                nvc.removeFromParentViewController()
                nvc.view.removeFromSuperview()
                nvc.didMoveToParentViewController(nil)
            }
            tabbar.selectedButton = tabbar.buttonForItem(item)
            return true
        }
    }
    func didSetTabItem(tabbar: TabNode!, item: TabItem) {
        if let vc = item as? TabItemController, let rvc = self.rootViewController {
        
            let nvc = vc.navController
            
            self.addChildViewController(nvc)
            nvc.view.frame = UIScreen.mainScreen().bounds
            
            self.screenNode.contentHolder.view.addSubview(nvc.view)
            nvc.didMoveToParentViewController(self)
            self.displayItem = item
            
            vc.screenNode.setNeedsLayout()
            nvc.setNeedsStatusBarAppearanceUpdate()
            nvc.view.setNeedsLayout()
            
            rvc.displayStatusBar = !vc.prefersStatusBarHidden()
            
            vc.isActive = true
        }
    }
}