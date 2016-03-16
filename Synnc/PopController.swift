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

protocol PopControllerDelegate {
    func hidePopController()
}

class PopController : ASViewController {
    var delegate : PopControllerDelegate?
    var screenNode : PopoverNode!
    var displayed : Bool = false
    var constrainedSize : ASSizeRange!
    
    init(){
        let node = PopoverNode(delegate: nil)
        super.init(node: node)
        node.delegate = self
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
    
    func hidePopover(sender: AnyObject!){
        self.screenNode.displayAnimation.completionBlock = {
            [weak self]
            anim, finished in
            self?.willMoveToParentViewController(nil)
            self?.screenNode.removeFromSupernode()
            self?.removeFromParentViewController()
            self?.screenNode.pop_removeAnimationForKey("displayAnimation")
        }
        
        self.screenNode.displayAnimation.toValue = 0
        self.displayed = false
    }
    
    override func nodeConstrainedSize() -> ASSizeRange {
        return self.constrainedSize
    }
}

extension PopController : PopoverNodeDelegate {
    func hideWithTouch() {
        self.delegate?.hidePopController()
    }
}