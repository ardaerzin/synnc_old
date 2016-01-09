//
//  ChatNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
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

protocol ChatNodeDelegate {
    func hideKeyboard()
}
class ChatTableHolder : ASDisplayNode {
    var chatCollection : WCLTableNode!
    
    override init!() {
        super.init()
        
        chatCollection = WCLTableNode(style: .Plain)
        chatCollection.alignSelf = .Stretch
        chatCollection.flexGrow = true
        
        self.addSubnode(chatCollection)
    }
    override func didLoad() {
        super.didLoad()
        
        self.chatCollection.view.separatorStyle = UITableViewCellSeparatorStyle.None
        self.chatCollection.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.chatCollection.view.tableFooterView = UIView(frame: CGRectZero)
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.redColor()
//        self.chatCollection.view.tableHeaderView = UIView(frame: UIScreen.mainScreen().bounds)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [chatCollection])
    }
}
class ChatNode : ASDisplayNode {
    
//    var initialTouchTopWindowPosition : CGFloat = 0
//    var transitionProgress : CGFloat! = 0 {
//        didSet {
//            print(self.view.bounds.height)
//            let transition = POPTransition(transitionProgress, startValue: -self.view.bounds.height, endValue: 0)
//            POPLayerSetTranslationY(self.view.layer, transition)
//        }
//    }
//    var animatableProperty : POPAnimatableProperty!  {
//        get {
//            let x = POPAnimatableProperty.propertyWithName("inc.stamp.pk.property.window.progress", initializer: {
//                
//                prop in
//                
//                prop.readBlock = {
//                    obj, values in
//                    values[0] = (obj as! ChatNode).transitionProgress
//                }
//                prop.writeBlock = {
//                    obj, values in
//                    (obj as! ChatNode).transitionProgress = values[0]
//                }
//                prop.threshold = 0.01
//            }) as! POPAnimatableProperty
//            
//            return x
//        }
//    }
//    var animation : POPSpringAnimation!  {
//        get {
//            if let x = self.pop_animationForKey("inc.stamp.pk.window.progress") as? POPSpringAnimation {
//                return x
//            } else {
//                let x = POPSpringAnimation()
//                x.property = self.animatableProperty
//                self.pop_addAnimation(x, forKey: "inc.stamp.pk.window.progress")
//                return x
//            }
//        }
//    }
    
    
    var headerNode : ChatHeaderNode!
    var collectionHolder : ChatTableHolder!
    var chatCollection : WCLTableNode! {
        get {
            return self.collectionHolder.chatCollection
        }
    }
    var delegate : ChatNodeDelegate?
    
    override init!() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        headerNode = ChatHeaderNode()
        headerNode.alignSelf = .Stretch
        
        collectionHolder = ChatTableHolder()
        collectionHolder.backgroundColor = UIColor.redColor()
        collectionHolder.alignSelf = .Stretch
        collectionHolder.flexGrow = true
        
        self.addSubnode(collectionHolder)
        self.addSubnode(headerNode)
        
        self.clipsToBounds = true
    }
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
//        self.delegate?.hideKeyboard()
        super.touchesBegan(touches, withEvent: event)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        var spacer = ASLayoutSpec()
        spacer.flexBasis = ASRelativeDimension(type: .Points, value: 44)
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [headerNode, collectionHolder, spacer])
    }
}

class ChatHeaderNode : StreamTitleNode {
    
    var closeButton : ButtonNode!
    
    override init!() {
        super.init()
        self.sourcesNode.alpha = 0
        
        self.backgroundColor = UIColor.whiteColor()
        
        closeButton = ButtonNode()
        closeButton.setImage(UIImage(named : "close"), forState: ASButtonStateNormal)
        closeButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(32, 32))
        closeButton.imageNode.preferredFrameSize = CGSizeMake(12, 12)
        
        self.addSubnode(closeButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let buttonSpec = ASStaticLayoutSpec(children: [self.closeButton])
        buttonSpec.spacingAfter = 20
        
        let imageSpec = ASStaticLayoutSpec(children: [self.userImage])
        let titleSpec = ASStackLayoutSpec(direction: .Vertical, spacing: 3, justifyContent: .Start, alignItems: .Start, children: [self.streamTitle, self.usernameNode])
        titleSpec.flexGrow = true
        imageSpec.spacingBefore = 25
        
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 12, justifyContent: .Center, alignItems: .Center, children: [imageSpec, titleSpec, buttonSpec])
        hStack.alignSelf = .Stretch
        
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [hStack, borderNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0), child: vStack)
    }
}