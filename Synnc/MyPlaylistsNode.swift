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
    
    var title : String! = "My Playlists"
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
        
        tableNode = ASTableNode()
        tableNode.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        tableNode.alignSelf = .Stretch
        tableNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        tableNode.view.separatorStyle = .None
        self.addSubnode(tableNode)
    }
    
    override func didLoad() {
        super.didLoad()
        
        tableNode.view.tableFooterView = UIView(frame: CGRectZero)
//        tableNode.view.tableHeaderView = UIView(frame: CGRectZero)
    }
    
//    override func calculatedLayoutDidChange() {
//        super.calculatedLayoutDidChange()
//    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [self.tableNode])
        let o = ASOverlayLayoutSpec(child: a, overlay: self.emptyStateNode)
        return o
    }
}