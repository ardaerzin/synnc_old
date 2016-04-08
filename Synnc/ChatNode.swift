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
import WCLUserManager

protocol ChatNodeDelegate {
    func hideKeyboard()
}

extension ChatNotAvailableNode {
    func newPlaylistAction(sender: ButtonNode) {
        sender.alpha = 0
    }
}

class ChatNotAvailableNode : ASDisplayNode {
    
    var mainTextNode : ASTextNode!
    var subTextNode : ASTextNode!
    
    override init() {
        super.init()
        
        mainTextNode = ASTextNode()
        
        subTextNode = ASTextNode()
        subTextNode.spacingBefore = 20
        
        self.addSubnode(mainTextNode)
        self.addSubnode(subTextNode)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    override func fetchData() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineHeightMultiple = 1.25
        
        mainTextNode.attributedString = NSAttributedString(string: "You need to join this stream to see the chat", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1, NSParagraphStyleAttributeName : paragraphStyle])
        
        let b = NSAttributedString(string: "Join Now", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.1])
        subTextNode.attributedString = b
        
        self.setNeedsLayout()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerSpacer = ASLayoutSpec()
        headerSpacer.flexBasis = ASRelativeDimension(type: .Points, value: 130)
        
        let spacerBefore = ASLayoutSpec()
        spacerBefore.flexBasis = ASRelativeDimension(type: .Percent, value: 0.15)
        
        let spacerAfter = ASLayoutSpec()
        spacerAfter.flexGrow = true
        
        mainTextNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.5)
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [headerSpacer, spacerBefore, ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [mainTextNode]), subTextNode, spacerAfter])
    }
}

class ChatTableHolder : ASDisplayNode {
    var chatCollection : WCLTableNode!
    
        override init() {
        super.init()
        
        chatCollection = WCLTableNode(style: .Plain)
            let a = ASRangeTuningParameters(leadingBufferScreenfuls: 0, trailingBufferScreenfuls: 0.1)
            self.chatCollection.view.setTuningParameters(a, forRangeMode: .Full, rangeType: ASLayoutRangeType.FetchData)
        chatCollection.alignSelf = .Stretch
        chatCollection.flexGrow = true
        
        self.addSubnode(chatCollection)
    }
    override func didLoad() {
        super.didLoad()
        
        self.chatCollection.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
//        (self.chatCollection.view as ASTableView).scrollDirection
//        self.chatCollection.view.leadingScreensForBatching = -1
//        ASScrollDirection
        self.chatCollection.view.separatorStyle = UITableViewCellSeparatorStyle.None
        self.chatCollection.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.chatCollection.view.tableFooterView = UIView(frame: CGRectZero)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [chatCollection])
    }
}
class ChatNode : ASDisplayNode, TrackedView {
    
    var title : String! = "Chat View"
    var collectionHolder : ChatTableHolder!
    var chatCollection : WCLTableNode! {
        get {
            return self.collectionHolder.chatCollection
        }
    }
    var notAvailableStateNode : ChatNotAvailableNode!
    var notAvailableState : Bool = false {
        didSet {
            if notAvailableState != oldValue {
                if self.notAvailableStateNode == nil {
                    notAvailableStateNode = ChatNotAvailableNode()
                }
                if notAvailableState {
                    self.addSubnode(notAvailableStateNode)
                } else {
                    notAvailableStateNode.removeFromSupernode()
                    notAvailableStateNode = nil
                }
                self.setNeedsLayout()
            }
        }
    }
    var delegate : ChatNodeDelegate?
    
        override init() {
        super.init()
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        collectionHolder = ChatTableHolder()
        collectionHolder.backgroundColor = UIColor.redColor()
        collectionHolder.alignSelf = .Stretch
        collectionHolder.flexGrow = true
        
        self.addSubnode(collectionHolder)
        
        self.clipsToBounds = true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var spacer = ASLayoutSpec()
        spacer.alignSelf = .Stretch
        spacer.flexBasis = ASRelativeDimension(type: .Points, value: 100)
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [spacer, collectionHolder])
        
        let o = ASOverlayLayoutSpec(child: a, overlay: self.notAvailableStateNode)
        return o
    }
}