//
//  MyPlaylistsNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class MyPlaylistsNode : ASDisplayNode {
    
    var collectionNode : ASCollectionNode!
    var emptyStateNode : MyPlaylistsEmptyStateNode!
    
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = MyPlaylistsEmptyStateNode()
                }
                if emptyState {
                    self.addSubnode(emptyStateNode)
                } else {
                    emptyStateNode.removeFromSupernode()
                    emptyStateNode = nil
                }
                self.setNeedsLayout()
            }
        }
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
        override init() {
        super.init()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.backgroundColor = UIColor.whiteColor()
        collectionNode.alignSelf = .Stretch
        collectionNode.view.contentInset = UIEdgeInsetsMake(135, 0, 50, 0)
        collectionNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(collectionNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.collectionNode])
        let o = ASOverlayLayoutSpec(child: a, overlay: self.emptyStateNode)
        return o
    }
}