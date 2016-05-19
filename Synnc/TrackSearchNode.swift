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

class IndicatorHolder : ASDisplayNode {
    var indicator : UIActivityIndicatorView!
    
    override func didLoad() {
        super.didLoad()
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(0,0,30,30))
        indicator.backgroundColor = UIColor.clearColor()
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        indicator.startAnimating()
        
        self.view.addSubview(indicator)
    }
    
    override func layout() {
        super.layout()
        
        indicator.center = CGPointMake(self.calculatedSize.width/2, self.calculatedSize.height/2)
    }
}

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
    var actionButton : ButtonNode!
    
    override init() {
        super.init()
        
        self.stateMsgNode = ASTextNode()
        self.addSubnode(self.stateMsgNode)
        
        self.alpha = 0
//        self.userInteractionEnabled = false
        
        actionButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        actionButton.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 15)
        actionButton.hidden = true
        
        self.addSubnode(self.actionButton)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)

    }
    
    func setMessage(msg: String) {
        self.stateMsgNode.attributedString = NSAttributedString(string: msg, attributes: self.textAttributes)
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let hor = ASStackLayoutSpec(direction: .Vertical, spacing: 20, justifyContent: .Center, alignItems: .Center, children: [stateMsgNode, actionButton])
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: hor)
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
    
    var indicator : UIActivityIndicatorView!
    var clearButton : ButtonNode!
    
    var moreTracksIndicatorHolder : IndicatorHolder!
    var moreArtistsIndicatorHolder : IndicatorHolder!
    
    var moreTracksIndicatorState : Bool = false {
        didSet {
            self.moreTracksStateAnimation.toValue = moreTracksIndicatorState ? 1 : 0
        }
    }
    var moreTracksStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("moreTracksStateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackSearchNode).moreTracksStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackSearchNode).moreTracksStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var moreTracksStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("moreTracksStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("moreTracksStateAnimation")
                }
                x.springBounciness = 0
                x.property = self.moreTracksStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "moreTracksStateAnimation")
                return x
            }
        }
    }
    var moreTracksStateAnimationProgress : CGFloat = 0 {
        didSet {
            let x = POPTransition(moreTracksStateAnimationProgress, startValue: 0, endValue: -self.moreTracksIndicatorHolder.calculatedSize.height)
            POPLayerSetTranslationY(self.moreTracksIndicatorHolder.layer, x)
        }
    }
    
    
    var moreArtistsIndicatorState : Bool = false {
        didSet {
            self.moreArtistsStateAnimation.toValue = moreArtistsIndicatorState ? 1 : 0
        }
    }
    var moreArtistsStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("moreArtistsStateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackSearchNode).moreArtistsStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackSearchNode).moreArtistsStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var moreArtistsStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("moreArtistsStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("moreArtistsStateAnimation")
                }
                x.springBounciness = 0
                x.property = self.moreArtistsStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "moreArtistsStateAnimation")
                return x
            }
        }
    }
    var moreArtistsStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            let x = POPTransition(moreArtistsStateAnimationProgress, startValue: 0, endValue: -self.moreArtistsIndicatorHolder.calculatedSize.width)
            POPLayerSetTranslationX(self.moreArtistsIndicatorHolder.layer, x)
            
        }
    }



    
    
    
    var tfEmpty : Bool = true {
        didSet {
            if tfEmpty {
                clearButtonAlpha = 0
            } else {
                clearButtonAlpha = 1
            }
        }
    }
    var clearButtonAlpha : CGFloat = 0 {
        didSet {
            if !searchingState {
                self.clearButtonAnimation.toValue = clearButtonAlpha
            }
        }
    }
    
    
    var artistSearchState : Bool = false {
        didSet {
            if !artistSearchState && !trackSearchState {
                self.searchingState = false
            } else {
                self.searchingState = true
            }
        }
    }
    var trackSearchState : Bool = false {
        didSet {
            if !artistSearchState && !trackSearchState {
                self.searchingState = false
            } else {
                self.searchingState = true
            }
        }
    }
    
    var searchingState = false {
        didSet {
            if searchingState {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
            searchStateAnimation.toValue = searchingState ? 1 : 0
        }
    }
    
    var searchStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("searchStateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackSearchNode).searchStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackSearchNode).searchStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var searchStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("searchStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("searchStateAnimation")
                }
                x.springSpeed = 1
                x.springBounciness = 0
                x.property = self.searchStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "searchStateAnimation")
                return x
            }
        }
    }
    var searchStateAnimationProgress : CGFloat = 0 {
        didSet {
            self.indicator.alpha = searchStateAnimationProgress
            self.clearButton.alpha = (1-searchStateAnimationProgress) * clearButtonAlpha
        }
    }
    
    
    var clearButtonAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("clearButtonAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackSearchNode).clearButtonAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackSearchNode).clearButtonAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var clearButtonAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("clearButtonAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("clearButtonAnimation")
                }
                x.springSpeed = 1
                x.springBounciness = 0
                x.property = self.clearButtonAnimatableProperty
                self.pop_addAnimation(x, forKey: "clearButtonAnimation")
                return x
            }
        }
    }
    var clearButtonAnimationProgress : CGFloat = 0 {
        didSet {
            self.clearButton.alpha = clearButtonAnimationProgress
        }
    }
    
    override init() {
        super.init()
        self.clipsToBounds = true
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.sourceSelectionNode = SourceSelectionNode(sources: ["Soundcloud", "Spotify", "AppleMusic"])
        
        self.coverNode = ASDisplayNode()
        self.coverNode.layerBacked = true
        self.coverNode.backgroundColor = .whiteColor()
            
        
        self.sourceOptionsButton = ButtonNode()
        self.sourceOptionsButton.setImage(UIImage(named: "soundcloud_active"), forState: ASControlState.Normal)
        self.sourceOptionsButton.imageNode.preferredFrameSize = CGSizeMake(20, 20)
        self.sourceOptionsButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 40, height: 40))
        self.sourceOptionsButton.imageNode.contentMode = .Center
        
        
        self.closeButton = ButtonNode()
        let title = NSAttributedString(string: "Done", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.4])
        self.closeButton.setAttributedTitle(title, forState: .Normal)
        self.closeButton.imageNode.contentMode = .Center
        self.closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 5, 10, 5)
        
        self.inputNode = ASEditableTextNode()
        self.inputNode.attributedPlaceholderText = NSAttributedString(string: "Search Here", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 16)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSKernAttributeName : -0.09])
        
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
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        self.artistsCollection = ASCollectionNode(collectionViewLayout: layout)
        self.artistsCollection.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 125))
        self.artistsCollection.view.showsHorizontalScrollIndicator = false
        self.artistsCollection.view.leadingScreensForBatching = 1
        self.artistsCollection.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
//            .clearColor()
            
        self.seperator2 = ASDisplayNode()
        self.seperator2.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 1))
        self.seperator2.layerBacked = true
        self.seperator2.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.11)
        self.seperator2.spacingBefore = 1
        self.seperator2.flexBasis = ASRelativeDimension(type: .Points, value: 1)
        self.seperator2.alignSelf = .Stretch
        
        self.tracksTable = ASTableNode(style: UITableViewStyle.Plain)
        self.tracksTable.view.backgroundColor = .whiteColor()
//        self.tracksTable.alignSelf = .Stretch
        self.tracksTable.view.leadingScreensForBatching = 2
//        self.tracksTable.flexGrow = true
        
        
        trackEmptyStateNode = TrackEmptyStateNode()
        artistEmptyStateNode = EmptyStateNode()
        
        clearButton = ButtonNode()
//        clearButton.setAttributedTitle(NSAttributedString(string: "clear", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Light", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)]), forState: .Normal)
        
        clearButton.setImage(UIImage(named: "close-small"), forState: .Normal)
        clearButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        clearButton.alpha = 0
        
        moreTracksIndicatorHolder = IndicatorHolder()
//        moreTracksIndicatorHolder.backgroundColor = UIColor.SynncColor().colorWithAlphaComponent(0.5)
        moreArtistsIndicatorHolder = IndicatorHolder()
//        moreArtistsIndicatorHolder.backgroundColor = UIColor.SynncColor().colorWithAlphaComponent(0.5)
        
        self.addSubnode(self.seperator1)
        self.addSubnode(self.artistsCollection)
        self.addSubnode(self.seperator2)
        self.addSubnode(self.tracksTable)
        self.addSubnode(self.moreArtistsIndicatorHolder)
        self.addSubnode(self.moreTracksIndicatorHolder)
        
        self.addSubnode(sourceSelectionNode)
        self.addSubnode(coverNode)
        
        self.addSubnode(self.sourceOptionsButton)
        self.addSubnode(self.inputNode)
        self.addSubnode(self.closeButton)
        self.addSubnode(self.clearButton)
        
        self.addSubnode(trackEmptyStateNode)
        self.addSubnode(artistEmptyStateNode)
        
        self.inputNode.scrollEnabled = false
        
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.tracksTable.view.tableFooterView = UIView(frame: CGRectMake(0,0,100,44))
        self.tracksTable.view.tableHeaderView = UIView(frame: CGRectZero)
        
//            UIView(frame: CGRectZero)
        
        self.tracksTable.view.allowsMultipleSelection = true
        self.tracksTable.view.separatorInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 0)
        self.tracksTable.view.separatorStyle = .None
        self.tracksTable.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.artistsCollection.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
    
        self.indicator = UIActivityIndicatorView(frame: CGRectMake(0,0,20,20))
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
//        self.indicator.backgroundColor = .purpleColor()
//        self.indicator.alpha = 1
//        self.indicator.startAnimating()
        
        self.view.addSubview(self.indicator)
    }
    
    override func layout() {
        super.layout()
        
        sourceSelectionNode.position.y = self.artistsCollection.position.y - sourceSelectionNode.calculatedSize.height
        
        coverNode.layer.frame = CGRectMake(0, 0, self.calculatedSize.width, self.seperator1.position.y - (self.seperator1.calculatedSize.height / 2))
    
        self.indicator.center = CGPointMake((self.inputNode.position.x + self.inputNode.calculatedSize.width / 2) - 20, self.inputNode.position.y)
        
        self.clearButton.position = CGPointMake((self.inputNode.position.x + self.inputNode.calculatedSize.width / 2) - (self.clearButton.calculatedSize.width / 2 + 5), self.inputNode.position.y)
        
        self.moreTracksIndicatorHolder.position.y = self.calculatedSize.height + (self.moreTracksIndicatorHolder.calculatedSize.height/2)
        moreArtistsIndicatorHolder.position.x = self.calculatedSize.width + moreArtistsIndicatorHolder.calculatedSize.width / 2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self.inputNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (40*2) - 10 - 10), ASRelativeDimension(type: .Points, value: 35))
        
        let searchStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [sourceOptionsButton]), ASStaticLayoutSpec(children: [inputNode, clearButton]), ASStaticLayoutSpec(children: [closeButton])])
        searchStack.spacingBefore = 15
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let artistsSpec = ASStaticLayoutSpec(children: [artistsCollection])
        artistsSpec.spacingBefore = 15
        
        moreArtistsIndicatorHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 30), ASRelativeDimension(type: .Percent, value: 1))
        let c = ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: artistsSpec, overlay: ASStaticLayoutSpec(children: [moreArtistsIndicatorHolder])), overlay: artistEmptyStateNode)
        
        moreTracksIndicatorHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 44))
        let d = ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: tracksTable, overlay: ASStaticLayoutSpec(children: [moreTracksIndicatorHolder])), overlay: trackEmptyStateNode)
//            ASOverlayLayoutSpec(child: tracksTable, overlay: trackEmptyStateNode)
//            ASOverlayLayoutSpec(child: ASOverlayLayoutSpec(child: tracksTable, overlay: ASStaticLayoutSpec(children: [moreTracksIndicatorHolder])), overlay: trackEmptyStateNode)
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