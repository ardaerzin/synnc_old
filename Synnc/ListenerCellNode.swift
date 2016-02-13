//
//  ListenerCellNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLUserManager

class ListenerCellNode : ASCellNode {
    var imageNode : ASNetworkImageNode!
    
    var imageURL : NSURL!
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode(webImage: ())
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        
        self.addSubnode(imageNode)
    }
    
    override func fetchData() {
        super.fetchData()
        
        if let url = imageURL {
            imageNode.URL = url
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: ASStaticLayoutSpec(children: [imageNode]))
//            ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [imageNode])
    }
}