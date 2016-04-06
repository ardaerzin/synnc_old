//
//  PlaylistBaseNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/25/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PlaylistHeaderNode : PagerHeaderNode {
    
    var gradientLayer : CAGradientLayer!
    
    init(){
        super.init(backgroundColor: nil)
    }
}

class PlaylistStreamButtonHolder : ASDisplayNode {
    var gradientLayer : CAGradientLayer!
    var streamButton : ButtonNode!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        streamButton = ButtonNode()
        streamButton.borderColor = UIColor.SynncColor().CGColor
        streamButton.borderWidth = 3
        streamButton.cornerRadius = 15
        streamButton.contentEdgeInsets = UIEdgeInsetsMake(8, 53, 12, 53)
        
        let title = NSAttributedString(string: "STREAM", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.SynncColor()])
        streamButton.setAttributedTitle(title, forState: .Normal)
        self.addSubnode(streamButton)
        
        let layer = CAGradientLayer(layer: self.layer)
        layer.colors = [UIColor.whiteColor().colorWithAlphaComponent(0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(1).CGColor]
        layer.startPoint = CGPointMake(0, 0)
        layer.endPoint = CGPointMake(0, 0.25)
        self.gradientLayer = layer
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
        gradientLayer.frame = self.view.bounds
        self.layer.mask = gradientLayer
    }
    
    override func layout() {
        super.layout()
        
        streamButton.position.x = self.calculatedSize.width / 2
        streamButton.position.y = self.calculatedSize.height / 2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [streamButton])
    }
}

class PlaylistBaseNode : PagerBaseControllerNode {
    
    var streamButtonHolder : PlaylistStreamButtonHolder!
    
    init() {
        let header = PlaylistHeaderNode()
        super.init(header: header, pager: nil)
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        streamButtonHolder = PlaylistStreamButtonHolder()
        self.addSubnode(streamButtonHolder)
        streamButtonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 85))
    }
    
    override func layout() {
        super.layout()
        
        self.streamButtonHolder.position.y = self.calculatedSize.height - (self.streamButtonHolder.calculatedSize.height / 2)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [x, streamButtonHolder])
    }
}

