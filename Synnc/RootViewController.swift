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

class RootViewController : ASViewController {
    
    var screenNode : TabControllerNode!
    var loginController : LoginViewController!
    var displayStatusBar : Bool = true {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    override func prefersStatusBarHidden() -> Bool {
        return !displayStatusBar
    }
    init(){
        let node = TabControllerNode()
        super.init(node: node)
        self.screenNode = node
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
        print(self.preferredContentSize)
        x.view.frame = UIScreen.mainScreen().bounds
        self.screenNode.addSubnode(x.screenNode)
        self.loginController = x

        // Node Related
        self.screenNode.tabbar.delegate = self
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
        self.screenNode.item = item
        
        self.screenNode.updateForItem(item)
//        self.screenNode.scrollNode.updateForItem(item)
//        self.screenNode.headerNode.updateForItem(item)
    }
    func didSetTabItem(item: TabItem) {
        
    }
}