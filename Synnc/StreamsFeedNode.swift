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

class StreamFeedHolder : ASDisplayNode {
    var collectionNode : ASCollectionNode!
    
    override init(){
        super.init()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        collectionNode.view.contentInset = UIEdgeInsetsMake(145, 0, 50, 0)
        
        collectionNode.view.contentInset = UIEdgeInsetsMake(145, 0, 50, 0)
        
        self.addSubnode(collectionNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [collectionNode])
    }
}

class StreamsFeedNode : ASDisplayNode, TrackedView {
    
    
    var emptyState : Bool = true {
        didSet {
            if emptyState != oldValue {
                self.transitionLayoutWithAnimation(false, shouldMeasureAsync: false, measurementCompletion: nil)
            }
        }
    }
    var title : String! = "Streams Feed"
    var streamCollection : ASCollectionNode! {
        get {
            return self.feedHolder.collectionNode
        }
    }
    
    var feedHolder : StreamFeedHolder!
    var otherNode : ASDisplayNode!
    var _emptyStateNode : StreamsFeedEmptyStateNode!
    var emptyStateNode : StreamsFeedEmptyStateNode!
        {
        get {
            if _emptyStateNode == nil {
                _emptyStateNode = StreamsFeedEmptyStateNode()
                _emptyStateNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
                _emptyStateNode.alpha = 1
                
                self.addSubnode(_emptyStateNode)
            }
            return _emptyStateNode
        }
    }
    
    override init() {
        super.init()
        
        feedHolder = StreamFeedHolder()
        feedHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let visibleNode : ASLayoutable = emptyState ? emptyStateNode : feedHolder
        return ASStaticLayoutSpec(children: [visibleNode])
    }
}