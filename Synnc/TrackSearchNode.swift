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
import SpinKit
import WCLUserManager
import DeviceKit

class SourceLoginButtonNode : SourceButton {
    
    override init(source: SynncExternalSource) {
        super.init(source: source)
        
        if let type = WCLUserLoginType(rawValue: source.rawValue.lowercaseString) {
            
            if let ext = Synnc.sharedInstance.user.userExtension(type) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginStatusChanged:", name: "\(type.rawValue)LoginStatusChanged", object: ext)
                self.selected = ext.loginStatus
            }
        }
    }
    func loginStatusChanged(notification: NSNotification){
        if let userExtension = notification.object as? WCLUserExtension {
            self.selected = userExtension.loginStatus
        }
    }
}

class SourceButton : ButtonNode {
    var normalImage : UIImage!
    var selectedImage : UIImage!
    var source : SynncExternalSource!
    
    init(source : SynncExternalSource) {
        
        super.init()
        self.source = source
        print(source.rawValue)
        let normalImage = UIImage(named: source.rawValue.lowercaseString + "_inactive")!
        let selectedImage = UIImage(named: source.rawValue.lowercaseString + "_active")!
        
        setImage(normalImage, forState: ASControlState.Normal)
        setImage(selectedImage, forState: ASControlState.Highlighted)
        
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        
        self.imageNode.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func changedSelected() {
        super.changedSelected()
        
        let img = self.selected ? self.selectedImage : self.normalImage
        self.setImage(img, forState: ASControlState.Normal)
    }
}

class SourceSelectionNode : ASDisplayNode {
    
    var titleNode : ASTextNode!
    var sourceButtons : [ButtonNode] = []
    
    init(sources: [String]) {
        super.init()
        
        for source in sources {
            let src = SynncExternalSource(rawValue: source.capitalizedString)
            if let x = src {
                let button = SourceButton(source: x)
                self.sourceButtons.append(button)
                
                self.addSubnode(button)
            }
        }
        
        titleNode = ASTextNode()
        titleNode.spacingAfter = 20
        titleNode.attributedString = NSAttributedString(string: "Select a music provider", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSKernAttributeName : -0.09])
        
        self.addSubnode(titleNode)
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Center, alignItems: .Center, children: self.sourceButtons)
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [ self.titleNode, a])
    }
}

class TrackSearchNode : ASDisplayNode {
    
    var sourceSelectionNode : SourceSelectionNode!
    
    var coverNode : ASDisplayNode!
    var sourceOptionsButton : ButtonNode!
    var inputNode : ASEditableTextNode!
    var closeButton : ButtonNode!
    
    var artistsCollection : ASCollectionNode!
    var tracksTable : ASTableNode!
    
    var seperator1 : ASDisplayNode!
    var seperator2 : ASDisplayNode!
    
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
        self.sourceOptionsButton.addTarget(self, action: Selector("toggleSourceSelector:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
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
        self.tracksTable.alignSelf = .Stretch
        self.tracksTable.view.leadingScreensForBatching = 1
        self.tracksTable.flexGrow = true
        
        
        self.addSubnode(self.seperator1)
        self.addSubnode(self.artistsCollection)
        self.addSubnode(self.seperator2)
        self.addSubnode(self.tracksTable)
        
        self.addSubnode(sourceSelectionNode)
        self.addSubnode(coverNode)
        
        self.addSubnode(self.sourceOptionsButton)
        self.addSubnode(self.inputNode)
        self.addSubnode(self.closeButton)
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
        
        let y = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [seperator1, artistsSpec, seperator2])
        let x = ASOverlayLayoutSpec(child: y, overlay: self.sourceSelectionNode)

        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [searchStack, x, tracksTable])
        return vStack
    }
    
    func toggleSourceSelector(sender : ButtonNode){
        sourceSelectionDisplayStatus = !sourceSelectionDisplayStatus
    }
    var sourceSelectionDisplayStatus : Bool = false {
        didSet {
            if sourceSelectionDisplayStatus != oldValue {
                self.sourceSelectionAnimation.toValue = sourceSelectionDisplayStatus ? 1 : 0
            }
        }
    }
    var sourceSelectionAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("sourceSelectionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackSearchNode).sourceSelectionAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackSearchNode).sourceSelectionAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var sourceSelectionAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("sourceSelectionAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("sourceSelectionAnimation")
                }
                x.springBounciness = 0
                x.property = self.sourceSelectionAnimatableProperty
                self.pop_addAnimation(x, forKey: "sourceSelectionAnimation")
                return x
            }
        }
    }
    var sourceSelectionAnimationProgress : CGFloat = 0 {
        didSet {
            let tranlation = POPTransition(sourceSelectionAnimationProgress, startValue: 0, endValue: sourceSelectionNode.calculatedSize.height)
            print(sourceSelectionNode.calculatedSize.height)
            POPLayerSetTranslationY(sourceSelectionNode.layer, tranlation)
        }
    }
}

extension TrackSearchNode {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.inputNode.resignFirstResponder()
    }
}