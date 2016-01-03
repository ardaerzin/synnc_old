//
//  ParallaxNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit

protocol ParallaxNodeDelegate {
    func imageForBackground() -> AnyObject?
}

class ParallaxNode : ASDisplayNode {
    
    var delegate : ParallaxNodeDelegate!
    var topDistance : CGFloat = 200
    var mainScrollNode : ParallaxContentScroller!
    var headerNode : SmallHeaderNode!
    
    init(backgroundNode : ParallaxBackgroundNode, contentNode : ASDisplayNode) {
        super.init()
    
        self.mainScrollNode = ParallaxContentScroller(backgroundNode: backgroundNode, contentNode: contentNode)
        self.mainScrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.headerNode = SmallHeaderNode()
        self.headerNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 35))
        
        self.addSubnode(self.mainScrollNode)
        self.addSubnode(self.headerNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let imageSpec = ASStaticLayoutSpec(children: [mainScrollNode, headerNode])
        return imageSpec
    }
    
    override func fetchData() {
        super.fetchData()
        
        if let imgData = self.delegate?.imageForBackground() {
            if let url = imgData as? NSURL {
                mainScrollNode.backgroundNode.imageNode.URL = url
                mainScrollNode.backgroundNode.imageNode.contentMode = .ScaleAspectFill
            } else if let img = imgData as? UIImage {
                mainScrollNode.backgroundNode.imageNode.URL = nil
                mainScrollNode.backgroundNode.imageNode.image = img
                mainScrollNode.backgroundNode.imageNode.contentMode = .ScaleAspectFill
            } else {
                mainScrollNode.backgroundNode.imageNode.URL = nil
                mainScrollNode.backgroundNode.imageNode.image = UIImage(named: "camera-large")
                mainScrollNode.backgroundNode.imageNode.contentMode = .Center
            }
        } else {
            mainScrollNode.backgroundNode.imageNode.image = UIImage(named: "camera-large")
            mainScrollNode.backgroundNode.imageNode.contentMode = .Center
        }
    }

}