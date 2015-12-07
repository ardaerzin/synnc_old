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
    
    var screenNode : ASDisplayNode!
    var loginController : LoginViewController!
    var displayStatusBar : Bool = true
    
    override func prefersStatusBarHidden() -> Bool {
        return displayStatusBar
    }
    
    init(){
        let node = ASDisplayNode()
        node.backgroundColor = UIColor.whiteColor()
        
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
        let x = LoginViewController()
        x.willMoveToParentViewController(self)
        self.addChildViewController(x)
        x.didMoveToParentViewController(self)
        print(self.preferredContentSize)
        x.view.frame = UIScreen.mainScreen().bounds
        self.screenNode.addSubnode(x.screenNode)
        self.loginController = x
    }
    
}