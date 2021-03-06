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

protocol PageControlDelegate {
    func pageControl(control : PageControlNode, scrollToInd ind : Int)
}

class PageControlNode : ASDisplayNode {
    
    var delegate : PageControlDelegate?
    
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
                
                if selectedColor == nil || normalColor == nil {
                    return
                }
                
                self.animation.toValue = isActive ? selectedColor : normalColor
            }
        }
        
        var selectedColor : UIColor! {
            didSet {
                if self.isActive {
                    self.backgroundColor = selectedColor
                }
            }
        }
        var normalColor : UIColor! {
            didSet {
                if !self.isActive {
                    self.backgroundColor = normalColor
                }
            }
        }
        
//        init(tintColor : UIColor?, selectedColor: UIColor?) {
        override init() {
            super.init()
            
            self.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(6,6))
            self.cornerRadius = 6/2
            
//            self.selectedColor = selectedColor
//            self.normalColor = tintColor
            
        }
    }
    
    var items : [PageControlItemNode] = []
    var pageIndicatorTintColor : UIColor! {
        didSet {
            for item in items {
                item.normalColor = pageIndicatorTintColor
            }
        }
    }
    var currentPageIndicatorTintColor : UIColor! {
        didSet {
            for item in items {
                item.selectedColor = currentPageIndicatorTintColor
            }
        }
    }
    var currentPage : Int = 0
    var styles : [[String : UIColor]?] = []
    var styleIndex : Int = -1
    
    var numberOfPages : Int! {
        didSet {
            
            //remove old elements
            for item in items {
                item.removeFromSupernode()
            }
            items = []
            
            for ind in 0..<numberOfPages {
//                tintColor: pageIndicatorTintColor, selectedColor: currentPageIndicatorTintColor
                let item = PageControlItemNode()
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
    
    override func didLoad() {
        super.didLoad()
        let tr = UITapGestureRecognizer(target: self, action: #selector(PageControlNode.didTap(_:)))
        self.view.addGestureRecognizer(tr)
    }
    
    func didTap(recognizer : UITapGestureRecognizer) {
        let touchPosition = recognizer.locationInView(self.view)
        let currentPosition = self.items[self.currentPage].position
    
        var i = self.currentPage
        if touchPosition.x < currentPosition.x {
            //left
            i -= 1
        } else if touchPosition.x > currentPosition.x {
            //right
            i += 1
        }
        
        if i >= 0 && i < self.items.count {
            self.delegate?.pageControl(self, scrollToInd: i)
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var children : [ASLayoutable] = []
        for item in items {
            children.append(ASStaticLayoutSpec(children: [item]))
        }
        
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: children)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 10, 5, 10), child: a)
    }
    
    func updateCurrentPageDisplay() {
        for (ind,item) in items.enumerate() {
            item.isActive = ind == self.currentPage
        }
    }
    
    
    func update(scrollPosition position: CGFloat) {
        var prevPos : CGFloat = 0
        
        if position > 1 || position < 0 {
            return
        }
        
        for (ind,_) in items.enumerate() {
            
            let a = CGFloat((1 / CGFloat(items.count)) * CGFloat(ind+1))
            if position >= prevPos && position <=  a {
                if ind != styleIndex {
                    self.pageIndicatorTintColor = self.styles[ind]!["pageControlColor"]
                    self.currentPageIndicatorTintColor = self.styles[ind]!["pageControlSelectedColor"]
                    styleIndex = ind
                }
            } 
            prevPos = a
        }
    }
}