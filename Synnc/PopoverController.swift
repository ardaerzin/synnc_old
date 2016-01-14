//
//  PopoverController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/28/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class PopController : ASViewController {
    var screenNode : PopoverNode!
    var displayed : Bool = false
    
    init(){
        let node = PopoverNode()
        super.init(node: node)
        self.screenNode = node
    }
    override init(node: ASDisplayNode) {
       super.init(node: node)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContent(controller : PopContentController){
        if let current = self.childViewControllers.first {
            
            current.willMoveToParentViewController(nil)
            self.screenNode.setContent(nil)
            current.removeFromParentViewController()
        }
        
        self.addChildViewController(controller)
        controller.view.frame = self.view.bounds
        self.screenNode.setContent(controller.screenNode)
        controller.didMoveToParentViewController(self)
    }
}

class PopContentController : ASViewController {
    var screenNode : ASDisplayNode!
}