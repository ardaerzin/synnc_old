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

class StreamsFeedNode : ASDisplayNode, TrackedView {
    
    
    var title : String! = "Streams Feed"
//    var streamCollection : ASCollectionNode! {
//        get {
//            return self.feedHolder.collectionNode
//        }
//    }
    
//    var feedHolder : StreamFeedHolder!
//    var otherNode : ASDisplayNode!
    
    var tableNode : ASTableNode!
    
    var emptyStateNode : StreamsFeedEmptyStateNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = StreamsFeedEmptyStateNode()
                    emptyStateNode.alpha = 1
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

        tableNode = ASTableNode()
        tableNode.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        tableNode.alignSelf = .Stretch
        tableNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        tableNode.view.separatorStyle = .None
        self.addSubnode(tableNode)
        
//        feedHolder = StreamFeedHolder()
//        feedHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
    }
    
    override func didLoad() {
        super.didLoad()
        
        tableNode.view.tableFooterView = UIView(frame: CGRectZero)
        tableNode.view.tableHeaderView = UIView(frame: CGRectMake(0,0,1,70))
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.tableNode])
        let o = ASOverlayLayoutSpec(child: a, overlay: self.emptyStateNode)
        return o
    }
}