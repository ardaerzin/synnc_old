//
//  StreamContentNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager
import WCLUserManager

class StreamContentNode : ASScrollNode {
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("sourceSelectionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamContentNode).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamContentNode).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("displayAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("displayAnimation")
                }
                x.springBounciness = 0
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "displayAnimation")
                return x
            }
        }
    }
    var positionY : CGFloat!
    var displayAnimationProgress : CGFloat = 0 {
        didSet {
            self.alpha = displayAnimationProgress
        }
    }
    
    
    var headerNode : StreamTitleNode!
    var connectedUsersNode : StreamListenersNode!
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        self.view.contentSize = CGSizeMake(self.calculatedSize.width, headerNode.calculatedSize.height)
    }
    override init!() {
        super.init()
        
        headerNode = StreamTitleNode()
        headerNode.alignSelf = .Stretch
        headerNode.spacingBefore = 20
        
        connectedUsersNode = StreamListenersNode()
        connectedUsersNode.alignSelf = .Stretch
        
        self.addSubnode(headerNode)
        self.addSubnode(connectedUsersNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 7, justifyContent: .Start, alignItems: .Start, children: [headerNode, connectedUsersNode])
    }
}

class StreamTitleNode : ASDisplayNode {
    var userImage : ASNetworkImageNode!
    var streamTitle : ASTextNode!
    var usernameNode : ASTextNode!
    var sourcesNode : StreamSourcesNode!
    
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size : 14)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1), NSKernAttributeName : -0.1]
    var usernameAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 10)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.1]
    
    var borderNode : ASDisplayNode!
    
    override init!() {
        super.init()
        
        userImage = ASNetworkImageNode(webImage: ())
        userImage.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(25, 25))
        
        streamTitle = ASTextNode()
        streamTitle.attributedString = NSAttributedString(string: "Stream Title", attributes: self.titleAttributes)
        
        usernameNode = ASTextNode()
        usernameNode.attributedString = NSAttributedString(string: "@ardaerzin", attributes: self.usernameAttributes)
        
        sourcesNode = StreamSourcesNode()
        
        borderNode = ASDisplayNode()
        borderNode.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        borderNode.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        borderNode.alignSelf = .Stretch
        
        self.addSubnode(userImage)
        self.addSubnode(streamTitle)
        self.addSubnode(usernameNode)
        self.addSubnode(sourcesNode)
        self.addSubnode(borderNode)
    }
    
    func configure(stream: Stream) {
        streamTitle.attributedString = NSAttributedString(string: stream.name.stringByRemovingPercentEncoding!, attributes: self.titleAttributes)
        usernameNode.attributedString = NSAttributedString(string: stream.user.name, attributes: self.usernameAttributes)
        
        if let type = WCLUserLoginType(rawValue: stream.user.provider), let url = stream.user.avatarURL(type, frame: CGRect(x: 0, y: 0, width: 25, height: 25), scale: UIScreen.mainScreen().scale) {
            userImage.URL = url
        }
        
        var buttons : [SourceButton] = []
        for sourceStr in stream.playlist.allSources() {
            buttons.append(SourceButton(source: SynncExternalSource(rawValue: sourceStr)!))
        }
        self.sourcesNode.nodes = buttons
        self.sourcesNode.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let imageSpec = ASStaticLayoutSpec(children: [self.userImage])
        let titleSpec = ASStackLayoutSpec(direction: .Vertical, spacing: 3, justifyContent: .Start, alignItems: .Start, children: [self.streamTitle, self.usernameNode])
        titleSpec.flexGrow = true
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 12, justifyContent: .Center, alignItems: .Center, children: [imageSpec, titleSpec, sourcesNode])
        hStack.alignSelf = .Stretch
        
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [hStack, borderNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25), child: vStack)
    }
}

class StreamSourcesNode : ASDisplayNode {
    
    var nodes : [SourceButton] = [] {
        didSet {
            for n in nodes {
                self.addSubnode(n)
            }
        }
    }
    
    override init!() {
        super.init()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        var specs : [ASLayoutable] = []
        for n in nodes {
            n.selected = true
            n.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(27, 27))
            specs.append(ASStaticLayoutSpec(children: [n]))
        }
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 7, justifyContent: .End, alignItems: .End, children: specs)
    }
    
}

class StreamListenersNode : ASDisplayNode {
    
    var listenersCollection : ASCollectionNode!
    var titleNode : ASTextNode!
    var data : [AnyObject] = []
    var noListenersText : ASTextNode!
    
    var emptyState : Bool = true {
        didSet {
            if emptyState != oldValue {
                print("didSet empty state:", emptyState)
                emptyStateAnimation.toValue = emptyState ? 1 : 0
            }
        }
    }
    var emptyStateAnimation : POPBasicAnimation {
        get {
            if let anim = self.noListenersText.pop_animationForKey("emptyStateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                x.duration = 0.3
                self.noListenersText.pop_addAnimation(x, forKey: "emptyStateAnimation")
                return x
            }
        }
    }
    override init!() {
        super.init()
    
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "People Connected:", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1), NSKernAttributeName : -0.1])
        
        noListenersText = ASTextNode()
        noListenersText.attributedString = NSAttributedString(string: "Share your stream and get listeners", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1), NSKernAttributeName : -0.1])
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        listenersCollection = ASCollectionNode(collectionViewLayout: layout)
        listenersCollection.alignSelf = .Stretch
        listenersCollection.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        
        
        self.addSubnode(titleNode)
        self.addSubnode(listenersCollection)
        self.addSubnode(noListenersText)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let overlaySpec = ASOverlayLayoutSpec(child: self.listenersCollection, overlay: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: noListenersText))
        overlaySpec.alignSelf = .Stretch
        overlaySpec.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Start, alignItems: .Start, children: [self.titleNode, overlaySpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25), child: vStack)
    }
    
    func update(stream: Stream) {
        self.data = stream.users
    }
}