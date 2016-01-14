//
//  HeaderNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/9/15.
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

class TitleHolderNode : ASDisplayNode {
    var constrainedSize : CGSize!
    var titleItem : ASDisplayNode! {
        willSet {
            if let item = titleItem {
                item.removeFromSupernode()
            }
        }
        didSet {
            if titleItem != nil {
                self.addSubnode(titleItem)
            }
        }
    }
    override func layout() {
        super.layout()
        if let title = self.titleItem {
            title.position.x = (self.calculatedSize.width / 2)
        }
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if titleItem == nil {
            return ASLayoutSpec()
        } else {
            if let w = self.constrainedSize {
                titleItem.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: w.width-100), ASRelativeDimension(type: .Points, value: 33))
            }
            let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [ASStaticLayoutSpec(children: [titleItem])])
            return x
        }
    }
}
class IconHolderNode : ASDisplayNode {
    var iconItem : ASDisplayNode! {
        willSet {
            if let item = iconItem {
                item.removeFromSupernode()
            }
        }
        didSet {
            if iconItem != nil {
                self.addSubnode(iconItem)
            }
        }
    }
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if iconItem == nil {
            return ASLayoutSpec()
        } else {
            return ASStaticLayoutSpec(children: [iconItem])
        }
    }
}

class HeaderNode : ASDisplayNode {
    
    var titleHolderNode : TitleHolderNode!
    var nowPlayingIcon : AnimatedLogoNode!
    var subSectionArea : SubsectionSelectorNode!
    var actionButton : ButtonNode!
    var iconHolderNode : IconHolderNode!
    var separator : ASDisplayNode!
    
    var selectedItem : TabItem! {
        didSet {
            if selectedItem.identifier != oldValue.identifier {
            }
        }
    }
    override init() {
        super.init()
        self.alignSelf = .Stretch
        
        self.titleHolderNode = TitleHolderNode()
        self.iconHolderNode = IconHolderNode()
        
        self.nowPlayingIcon = AnimatedLogoNode(barCount: 5)
        nowPlayingIcon.preferredFrameSize = CGSizeMake(40, 34)
        
        self.subSectionArea = SubsectionSelectorNode()
        
        self.separator = ASDisplayNode()
        self.separator.backgroundColor = UIColor.lightGrayColor()
        self.separator.flexBasis = ASRelativeDimension(type: .Points, value: 1 / UIScreen.mainScreen().scale)
        self.separator.alignSelf = .Stretch
        
        self.addSubnode(self.titleHolderNode)
        self.addSubnode(self.iconHolderNode)
        
        self.addSubnode(nowPlayingIcon)
        self.addSubnode(subSectionArea)
        self.addSubnode(separator)
        
        self.backgroundColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didSetActiveStream:"), name: "DidSetActiveStream", object: nil)
    }
    
    func didSetActiveStream(notification : NSNotification!) {
        if let _ = notification.object as? Stream {
            self.nowPlayingIcon.startAnimation()
        } else {
            self.nowPlayingIcon.stopAnimation()
        }
    }

    override func layout() {
        super.layout()
        self.iconHolderNode.position.x = (self.iconHolderNode.calculatedSize.width / 2) + 10
        self.iconHolderNode.position.y = self.titleHolderNode.position.y
        self.nowPlayingIcon.position.x = self.calculatedSize.width - (self.nowPlayingIcon.calculatedSize.width / 2)
        
        if self.iconHolderNode.iconItem == nil {
            self.titleHolderNode.position.x = (self.calculatedSize.width / 2 - 25)
        } else {
            self.titleHolderNode.position.x = (self.calculatedSize.width / 2)
        }
    }
    
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
//        self.nowPlayingIcon.startAnimation()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let statusSpacer = ASLayoutSpec()
        statusSpacer.flexBasis = ASRelativeDimension(type: .Points, value: 20)
        
        self.titleHolderNode.constrainedSize = constrainedSize.max
        let titleSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [ASStaticLayoutSpec(children: [iconHolderNode, self.titleHolderNode, nowPlayingIcon])])
        titleSpec.spacingBefore = 17
        titleSpec.flexBasis = ASRelativeDimension(type: .Points, value: 66)
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [statusSpacer, titleSpec, subSectionArea, separator])
        
        return x
    }
}

extension HeaderNode {
    func updateForItem(item : TabItem){
        self.subSectionArea.updateIndicator(item)
        self.subSectionArea.updateButtons(item)
        self.iconHolderNode.iconItem = item.iconItem
        self.titleHolderNode.titleItem = item.titleItem
    }
}