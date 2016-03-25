//
//  HeaderTitleNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/22/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit

class PagerHeaderTitleNode: ASDisplayNode {
    var items : [ASDisplayNode?] = [] {
        didSet {
            for item in items {
                if let i = item {
                    self.addSubnode(i)
                }
            }
        }
    }
    var switchPosition : CGFloat {
        get {
            return CGFloat(1 / items.count)
        }
    }
    override init() {
        super.init()
    }
    
    override func layout() {
        super.layout()
        
        for item in items {
            item?.position.x = self.calculatedSize.width / 2
            item?.position.y = self.calculatedSize.height / 2
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var i : [ASLayoutable] = []
        for item in items {
            if let x = item {
                i.append(x)
            }
        }
        return ASStaticLayoutSpec(children: i)
    }
    
    func update(scrollPosition position: CGFloat) {
        var prevPos : CGFloat = 0
        
        if position > 1 || position < 0 {
            return
        }
        
        for (ind,item) in items.enumerate() {
            let a = CGFloat((1 / CGFloat(items.count)) * CGFloat(ind+1))
            if position >= prevPos && position <=  a {
                item?.alpha = 1
            } else {
                item?.alpha = 0
            }
            prevPos = a
        }
    }
}