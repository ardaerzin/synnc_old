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
    func imageForBackground() -> (image: AnyObject?, viewMode: UIViewContentMode?)
    func gradientImageName() -> String?
}

class ParallaxNode : ASDisplayNode {
    
    var underTabbar : Bool = false {
        didSet {
            if underTabbar != oldValue {
                self.mainScrollNode.tabbarHeight = underTabbar ? 50 : 0
            }
        }
    }
    var delegate : ParallaxNodeDelegate!
    var topDistance : CGFloat = 250
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
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let imageSpec = ASStaticLayoutSpec(children: [mainScrollNode, headerNode])
        return imageSpec
    }
    
    override func fetchData() {
        super.fetchData()
        
        if let imgData = self.delegate?.imageForBackground() {
            
            var imageMode : UIViewContentMode = .Center
            if let m = imgData.viewMode {
                imageMode = m
            }
            
            if let url = imgData.image as? NSURL {
                mainScrollNode.backgroundNode.imageNode.URL = url
            } else if let img = imgData.image as? UIImage {
                mainScrollNode.backgroundNode.imageNode.URL = nil
                mainScrollNode.backgroundNode.imageNode.image = img
            } else {
                mainScrollNode.backgroundNode.imageNode.URL = nil
                mainScrollNode.backgroundNode.imageNode.image = UIImage(named: "camera-large")
            }
            
            mainScrollNode.backgroundNode.imageNode.contentMode = imageMode
        } else {
            mainScrollNode.backgroundNode.imageNode.image = UIImage(named: "camera-large")
            mainScrollNode.backgroundNode.imageNode.contentMode = .Center
        }
        
        if let gradientName = self.delegate?.gradientImageName() {
            mainScrollNode.backgroundNode.imageGradientNode.image = UIImage(named: gradientName)
        } else {
            mainScrollNode.backgroundNode.imageGradientNode.image = UIImage(named: "imageGradient")
        }
    }
    
    func didScroll(position: CGFloat){
        
    }
    
    func backgroundSizeRange(forConstrainedSize constrainedSize : ASSizeRange) -> ASRelativeSizeRange? {
        return nil
    }
}