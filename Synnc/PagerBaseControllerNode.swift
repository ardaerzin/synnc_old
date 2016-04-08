//
//  PagerBaseControllerNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/22/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PagerBaseControllerNode : ASDisplayNode {
    var headerNode : PagerHeaderNode!
    var pager : PagerNode!
    
    init(header: PagerHeaderNode? = nil, pager: PagerNode? = nil) {
        super.init()
        
        var pagerNode : PagerNode
        if let p = pager {
            pagerNode = p
        } else {
            let layout = ASPagerFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .Horizontal
            
            pagerNode = PagerNode(collectionViewLayout: layout)
        }
        self.pager = pagerNode
        self.addSubnode(self.pager)
        
        var headerNode : PagerHeaderNode
        if let h = header {
            headerNode = h
        } else {
            headerNode = PagerHeaderNode()
        }
        self.headerNode = headerNode
        self.addSubnode(headerNode)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    override func layout() {
        super.layout()
        headerNode.position.y = headerNode.calculatedSize.height / 2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStaticLayoutSpec(children: [headerNode, pager])
        return x
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}