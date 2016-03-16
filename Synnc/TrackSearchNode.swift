//
//  TrackSearchNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/14/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager

class TrackEmptyStateNode : EmptyStateNode {
    override func layout() {
        super.layout()
        
        self.stateMsgNode.position.x = self.calculatedSize.width / 2
        self.stateMsgNode.position.y = 100
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [self.stateMsgNode])
    }
}

class EmptyStateNode : ASDisplayNode {
    
    var state : Bool = false {
        didSet {
            self.alpha = state ? 1 : 0
        }
    }
    var stateMsgNode : ASTextNode!
    var textAttributes : [String : AnyObject] {
        get {
            let p = NSMutableParagraphStyle()
            p.alignment = .Center
            
            return [NSFontAttributeName : UIFont(name: "Ubuntu", size: 16)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSParagraphStyleAttributeName : p]
        }
    }
    
    override init() {
        super.init()
        
        self.stateMsgNode = ASTextNode()
        self.addSubnode(self.stateMsgNode)
        
        self.alpha = 0
        self.userInteractionEnabled = false
        
        self.backgroundColor = .whiteColor()
    }
    
    func setMessage(msg: String) {
        self.stateMsgNode.attributedString = NSAttributedString(string: msg, attributes: self.textAttributes)
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: self.stateMsgNode)
    }
    
}

class TrackSearchNode : ASDisplayNode, TrackedView {
    
    var title : String! = "TrackSearch"
    var sourceSelectionNode : SourceSelectionNode!
    
    var coverNode : ASDisplayNode!
    var sourceOptionsButton : ButtonNode!
    var inputNode : ASEditableTextNode!
    var closeButton : ButtonNode!
    
    var artistsCollection : ASCollectionNode!
    var tracksTable : ASTableNode!
    
    var seperator1 : ASDisplayNode!
    var seperator2 : ASDisplayNode!
    
    var trackEmptyStateNode : TrackEmptyStateNode!
    var artistEmptyStateNode : EmptyStateNode!
    
    override init() {
        super.init()
        self.clipsToBounds = true
        
        self.backgroundColor = .whiteColor()
        
        self.sourceSelectionNode = SourceSelectionNode(sources: ["Soundcloud", "Spotify"])
        
        self.coverNode = ASDisplayNode()
        self.coverNode.layerBacked = true
        self.coverNode.backgroundColor = UIColor.whiteColor()
        
        self.sourceOptionsButton = ButtonNode()
        self.sourceOptionsButton.setImage(UIImage(named: "soundcloud_active"), forState: ASControlState.Normal)
        self.sourceOptionsButton.imageNode.preferredFrameSize = CGSizeMake(20, 20)
        self.sourceOptionsButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 40, height: 40))
        self.sourceOptionsButton.imageNode.contentMode = .Center
        
        
        self.closeButton = ButtonNode()
//        self.closeButton.imageNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.blackColor().colorWithAlphaComponent(0.6))
        self.closeButton.setImage(UIImage(named: "close")?.imageWithRenderingMode(.AlwaysTemplate), forState: ASControlState.Normal)
        self.closeButton.imageNode.preferredFrameSize = CGSizeMake(15, 15)
        self.closeButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 40, height: 40))
        self.closeButton.imageNode.contentMode = .Center
        
        self.inputNode = ASEditableTextNode()
        self.inputNode.attributedPlaceholderText = NSAttributedString(string: "Search Here", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSKernAttributeName : -0.09])
        
        self.inputNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)]
        
        self.inputNode.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
        self.inputNode.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.04)
        
        self.seperator1 = ASDisplayNode()
        self.seperator1.layerBacked = true
        self.seperator1.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 1))
        self.seperator1.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.11)
        self.seperator1.spacingBefore = 12
        self.seperator1.flexBasis = ASRelativeDimension(type: .Points, value: 1)
        self.seperator1.alignSelf = .Stretch
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        self.artistsCollection = ASCollectionNode(collectionViewLayout: layout)
        self.artistsCollection.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 125))
        self.artistsCollection.view.showsHorizontalScrollIndicator = false
        self.artistsCollection.view.leadingScreensForBatching = 1
        
        self.seperator2 = ASDisplayNode()
        self.seperator2.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 1))
        self.seperator2.layerBacked = true
        self.seperator2.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.11)
        self.seperator2.spacingBefore = 1
        self.seperator2.flexBasis = ASRelativeDimension(type: .Points, value: 1)
        self.seperator2.alignSelf = .Stretch
        
        self.tracksTable = ASTableNode(style: UITableViewStyle.Plain)
        self.tracksTable.backgroundColor = UIColor.redColor()
//        self.tracksTable.alignSelf = .Stretch
        self.tracksTable.view.leadingScreensForBatching = 1
//        self.tracksTable.flexGrow = true
        
        
        trackEmptyStateNode = TrackEmptyStateNode()
        artistEmptyStateNode = EmptyStateNode()
        
        
        self.addSubnode(self.seperator1)
        self.addSubnode(self.artistsCollection)
        self.addSubnode(self.seperator2)
        self.addSubnode(self.tracksTable)
        
        self.addSubnode(sourceSelectionNode)
        self.addSubnode(coverNode)
        
        self.addSubnode(self.sourceOptionsButton)
        self.addSubnode(self.inputNode)
        self.addSubnode(self.closeButton)
        
        self.addSubnode(trackEmptyStateNode)
        self.addSubnode(artistEmptyStateNode)
    }
    
    override func didLoad() {
        super.didLoad()
        self.tracksTable.view.tableFooterView = UIView(frame: CGRectZero)
        self.tracksTable.view.tableHeaderView = UIView(frame: CGRectZero)
        self.tracksTable.view.allowsMultipleSelection = true
        self.tracksTable.view.separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        
        self.tracksTable.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.artistsCollection.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    }
    
    override func layout() {
        super.layout()
        
        sourceSelectionNode.position.y = self.artistsCollection.position.y - sourceSelectionNode.calculatedSize.height
        
        coverNode.layer.frame = CGRectMake(0, 0, self.calculatedSize.width, self.seperator1.position.y - (self.seperator1.calculatedSize.height / 2))
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.inputNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (40*2) - 10 - 10), ASRelativeDimension(type: .Points, value: 30))
        
        let searchStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [sourceOptionsButton]), ASStaticLayoutSpec(children: [inputNode]), ASStaticLayoutSpec(children: [closeButton])])
        searchStack.spacingBefore = 15
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let artistsSpec = ASStaticLayoutSpec(children: [artistsCollection])
        artistsSpec.spacingBefore = 15
        
        let c = ASOverlayLayoutSpec(child: artistsSpec, overlay: artistEmptyStateNode)
        let d = ASOverlayLayoutSpec(child: tracksTable, overlay: trackEmptyStateNode)
        d.alignSelf = .Stretch
        d.flexGrow = true
        
        let y = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [seperator1, c, seperator2])
        let x = ASOverlayLayoutSpec(child: y, overlay: self.sourceSelectionNode)

        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [searchStack, x, d])
        return vStack
    }
}

extension TrackSearchNode {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.inputNode.resignFirstResponder()
    }
}