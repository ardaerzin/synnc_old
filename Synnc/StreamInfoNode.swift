//
//  StreamInfoNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/29/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Shimmer

class StreamInfoHolder : ASDisplayNode, TrackedView {
    var infoNode : StreamInfoNode!
    var headerSpacer : ASDisplayNode!
    var title: String! = "Stream Info"
    
    override init() {
        super.init()
        infoNode = StreamInfoNode()
        infoNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(infoNode)
        
        headerSpacer = ASDisplayNode()
        headerSpacer.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        headerSpacer.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 60))
        self.addSubnode(headerSpacer)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        //        if let x = self.supernode as? PagerBaseControllerNode
        //        print("SUPER NODE", self.supernode)
        return ASStaticLayoutSpec(children: [infoNode, headerSpacer])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        //        self.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
    }
}

class StreamInfoNode : ASDisplayNode {
}