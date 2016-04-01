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
        
        imageNode = ASNetworkImageNode()
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        
        self.addSubnode(imageNode)
    }
    
    override func fetchData() {
        super.fetchData()
        
        if let url = imageURL {
            imageNode.URL = url
        }
    }
    
    
    func configureForUser(user : WCLUser) {
        self.imageURL = user.avatarURL(WCLUserLoginType(rawValue: user.provider)!, frame: CGRectMake(0, 0, 40, 40), scale: UIScreen.mainScreen().scale)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: ASStaticLayoutSpec(children: [imageNode]))
//            ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [imageNode])
    }
}