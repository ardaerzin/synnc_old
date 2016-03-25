//
//  PageControlNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/22/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop

class PageControlNode : ASDisplayNode {
    
    internal class PageControlItemNode : ASDisplayNode {
        
        var animation : POPBasicAnimation! {
            get {
                if let anim = self.pop_animationForKey("bgColor") as? POPBasicAnimation{
                    return anim
                } else {
                    let x = POPBasicAnimation(propertyNamed: kPOPViewBackgroundColor)
                    self.pop_addAnimation(x, forKey: "bgColor")
                    return x
                }
            }
        }
        var isActive : Bool = false {
            didSet {
                self.animation.toValue = isActive ? selectedColor : normalColor
            }
        }
        
        var selectedColor : UIColor!
        var normalColor : UIColor!
        init(tintColor : UIColor, selectedColor: UIColor) {
            super.init()
            
            self.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(6,6))
            self.backgroundColor = .orangeColor()
            self.cornerRadius = 6/2
            
            self.selectedColor = selectedColor
            self.normalColor = tintColor
            
            self.backgroundColor = self.normalColor
        }
    }
    
    var items : [PageControlItemNode] = []
    var pageIndicatorTintColor : UIColor!
    var currentPageIndicatorTintColor : UIColor!
    var currentPage : Int = 0
    
    var numberOfPages : Int! {
        didSet {
            
            //remove old elements
            for item in items {
                item.removeFromSupernode()
            }
            items = []
            
            for ind in 0..<numberOfPages {
                let item = PageControlItemNode(tintColor: pageIndicatorTintColor, selectedColor: currentPageIndicatorTintColor)
                self.addSubnode(item)
                items.append(item)
                
                if ind == self.currentPage {
                    item.isActive = true
                }
            }
            
            self.setNeedsLayout()
            
        }
    }
    override init() {
        super.init()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var children : [ASLayoutable] = []
        for item in items {
            children.append(ASStaticLayoutSpec(children: [item]))
        }
        
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: children)
    }
    
    func updateCurrentPageDisplay() {
        for (ind,item) in items.enumerate() {
            item.isActive = ind == self.currentPage
        }
    }
}