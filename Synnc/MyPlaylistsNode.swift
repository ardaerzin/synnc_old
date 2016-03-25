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
import WCLUserManager

class MyPlaylistsNode : ASDisplayNode, TrackedView {
    
    var title : String! = "MyPlaylists"
    var tableNode : ASTableNode!
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
    
    override init() {
        super.init()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
//        collectionNode = ASCollectionNode(collectionViewLayout: layout)
////        collectionNode.backgroundColor = UIColor.whiteColor()
//        collectionNode.alignSelf = .Stretch
//        collectionNode.view.contentInset = UIEdgeInsetsMake(60, 0, 50, 0)
//        collectionNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        
//        self.addSubnode(collectionNode)
        
        tableNode = ASTableNode()
        tableNode.alignSelf = .Stretch
        tableNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(tableNode)
    }
    
    override func calculatedLayoutDidChange() {
        super.calculatedLayoutDidChange()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.tableNode])
        let o = ASOverlayLayoutSpec(child: a, overlay: self.emptyStateNode)
        return o
    }
}