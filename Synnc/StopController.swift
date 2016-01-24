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

class StopController : PopContentController {
    
//    var stream : Stream?
    
    init(){
        let node = StopControllerNode()
        super.init(node: node)
        self.screenNode = node
        
        node.noButton.addTarget(self, action: Selector("noAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.yesButton.addTarget(self, action: Selector("yesAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StopController {
    func noAction(sender: ButtonNode) {
        if let p = self.parentViewController as? PopController {
            p.hideWithTouch()
        }
    }
    func yesAction(sender: ButtonNode) {
//        guard let s = self.stream else {
//            return
//        }
//        
        if let streamController = self.parentViewController?.parentViewController as? StreamViewController {
            if let p = self.parentViewController as? PopController {
                p.hideWithTouch()
            }
            streamController.endOfPlaylist(nil)
        }
        
//        StreamManager.sharedInstance.stopStream(s) {
//            status in
//            
//            print(self.parentViewController, self.parentViewController?.parentViewController)
//            print("done stopping", status)
//        }
//        if let p = self.parentViewController as? PopController {
//            p.hideWithTouch()
//        }
    }
}