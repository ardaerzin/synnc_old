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

class RootViewController : ASViewController {
    
    var screenNode : TabControllerNode!
    var loginController : LoginViewController!
    var displayStatusBar : Bool = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    var displayItem : TabItem! {
        didSet {
            self.screenNode.item = displayItem
            self.screenNode.updateForItem(displayItem)
            
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
    init(){
        
        let controllers : [TabItemController] = [
            HomeController(),
            SearchController(),
            MyStreamController(),
            PlaylistsController(),
            MeController()
        ]
        
        let node = TabControllerNode(items: controllers)
        super.init(node: node)
        self.screenNode = node
        self.screenNode.scrollNode.contentDelegate = self
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
        
        /// Login Related
        let x = LoginViewController()
        x.willMoveToParentViewController(self)
        self.addChildViewController(x)
        x.didMoveToParentViewController(self)
        x.view.frame = UIScreen.mainScreen().bounds
        self.screenNode.addSubnode(x.screenNode)
        self.loginController = x

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
//                x.completionBlock = {
//                    anim, finished in
//                    
//                    if let a = anim as? POPBasicAnimation where finished {
//                        if (a.toValue as! CGFloat) == 1 {
//                            self.headerUpdateBlock?()
//                            self.headerChangeAnimation.toValue = 0
//                        } else {
//                            self.pop_removeAnimationForKey("tabChangeAnimation")
//                        }
//                    }
//                }
                x.duration = 0.2
                x.property = self.tabChangeAnimatableProperty
                self.pop_addAnimation(x, forKey: "tabChangeAnimation")
                return x
            }
        }
    }
    var tabChangeAnimationProgress : CGFloat = 0 {
        didSet {
            self.screenNode.scrollNode.alpha = 1-tabChangeAnimationProgress
            self.screenNode.navigationNode.alpha = 1-tabChangeAnimationProgress
//            POPLayerSetTranslationX(self.titleHolderNode.layer, titlePositionAnimationProgress)
        }
    }
}
extension RootViewController {
    func dismissLoginController() {
        self.loginController.willMoveToParentViewController(nil)
        self.loginController.removeFromParentViewController()
        self.loginController = nil
    }
}

// MARK: - TabbarDelegate
extension RootViewController : TabbarDelegate {
    func willSetTabItem(item: TabItem) {
       
        let oldItem = self.displayItem
        self.tabChangeAnimation.completionBlock = {
            anim, finished in
            
            if let oi = oldItem {
                for x in oi.subsections {
                    x.willMoveToParentViewController(nil)
                    x.screenNode.removeFromSupernode()
                    x.removeFromParentViewController()
                }
                
                print(oi)
                if let x = oi as? TabItemController {
                    x.willMoveToParentViewController(nil)
                    x.screenNode.removeFromSupernode()
                    x.removeFromParentViewController()
                }
            }
            
            if let x = item as? TabItemController {
                x.willMoveToParentViewController(self)
                self.addChildViewController(x)
                let a = x.screenNode
                x.view.frame.size = self.view.bounds.size
                
                self.screenNode.navigationNode.addSubnode(x.screenNode)
                
                x.didMoveToParentViewController(self)
                
            }
            
            self.tabChangeAnimation.toValue = 0
        }
        
        let vc = item as! TabItemController
        print("CHILDREN:", vc.childViewControllers)
        
        self.tabChangeAnimation.toValue = 1
        self.displayItem = item
        
//        if let oldItem = self.displayItem {
//            for x in oldItem.subsections {
//                x.willMoveToParentViewController(nil)
//                x.screenNode.removeFromSupernode()
//                x.removeFromParentViewController()
//            }
//            
//            if let x = oldItem as? TabItemController {
//                x.willMoveToParentViewController(nil)
//                x.screenNode.removeFromSupernode()
//                x.removeFromParentViewController()
//            }
//        }
//        self.displayItem = item
    }
    func didSetTabItem(item: TabItem) {
        
    }
}

extension RootViewController : TabbarContentLoaderDelegate {
    
    
    func loadSubsections(item: TabItem, inScroller scroller : TabbarContentScroller) {
        
//        if let x = item as? TabItemController {
//            x.willMoveToParentViewController(self)
//            self.addChildViewController(x)
//            let a = x.screenNode
//            x.view.frame.size = self.view.bounds.size
//            
//            self.screenNode.navigationNode.addSubnode(x.screenNode)
//            
//            x.didMoveToParentViewController(self)
//            
//        }
        
        
        for (index,ss) in item.subsections.enumerate() {
            
            if let vc = ss as? TabSubsectionController {
                vc.willMoveToParentViewController(self)
                self.addChildViewController(vc)
                
                let a = vc.screenNode
                vc.view.frame.size = self.view.bounds.size
                
                scroller.addSubnode(a)
                scroller.pages.append(a)
                
                vc.didMoveToParentViewController(self)
            }
        }
        scroller.currentIndex = item.selectedIndex
    }
}