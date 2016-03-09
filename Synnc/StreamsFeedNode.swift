//
//  StreamsFeedNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop

class StreamsFeedNode : ASCellNode {
    
    var streamCollection : ASCollectionNode!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.redColor()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        streamCollection = ASCollectionNode(collectionViewLayout: layout)
        streamCollection.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        streamCollection.view.contentInset = UIEdgeInsetsMake(145, 0, 50, 0)
        
        self.addSubnode(streamCollection)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [self.streamCollection])
    }
}