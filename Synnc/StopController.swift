//
//  StopController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/16/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox

class StopController : ASViewController {
    
    var screenNode : ASDisplayNode!
    
    init(){
        let node = StopControllerNode()
        super.init(node: node)
        self.screenNode = node
        
//        node.noButton.addTarget(self, action: Selector("noAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
//        node.yesButton.addTarget(self, action: Selector("yesAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}