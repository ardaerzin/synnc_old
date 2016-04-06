//
//  StreamListenersNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop
import WCLUserManager

class StreamListenersNode : ASDisplayNode {
    
    var listenersCollection : ASCollectionNode!
    var titleNode : ASTextNode!
    var countNode : ASTextNode!
    lazy var countAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)]
    }()
    var separator : ASDisplayNode!
    
    var emptyStateNode : ListenersEmptyStateNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = ListenersEmptyStateNode()
                }
                if emptyState {
                    self.addSubnode(emptyStateNode)
                } else {
                    emptyStateNode.removeFromSupernode()
                    emptyStateNode = nil
                }
                self.setNeedsLayout()
            }
        }
    }
    
    override init() {
        super.init()
        
        separator = ASDisplayNode()
        separator.alignSelf = .Stretch
        separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        separator.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.2)
        self.addSubnode(separator)
        
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "JOINED USERS", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        self.addSubnode(titleNode)
        
        countNode = ASTextNode()
        countNode.spacingBefore = 6
        self.addSubnode(countNode)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        listenersCollection = ASCollectionNode(collectionViewLayout: layout)
        listenersCollection.alignSelf = .Stretch
        listenersCollection.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        listenersCollection.view.backgroundColor = .clearColor()
        
        self.addSubnode(listenersCollection)
        self.alignSelf = .Stretch
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let titleStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [titleNode, countNode])
        titleStack.alignSelf = .Stretch
        titleStack.spacingBefore = 25
        titleStack.spacingAfter = 15
        
        
        let o = ASOverlayLayoutSpec(child: listenersCollection, overlay: self.emptyStateNode)
        o.alignSelf = .Stretch
        o.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        o.spacingAfter = 24
        
        let infoStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleStack, o])
        let infoSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 20, 0, 20) , child: infoStack)
        infoSpec.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [separator, infoSpec])
    }
    
    func configure(stream: Stream) {
        countNode.attributedString = NSAttributedString(string: "\(stream.users.count)", attributes: self.countAttributes)
        self.emptyState = stream.users.isEmpty
     
        if stream == StreamManager.sharedInstance.userStream {
            emptyStateNode?.msgNode.attributedString = NSAttributedString(string: "No listeners", attributes: emptyStateNode?.msgAttributes)
        } else {
            
            emptyStateNode?.msgNode.attributedString = NSAttributedString(string: "No listeners", attributes: emptyStateNode?.msgAttributes)
        }

        
        self.setNeedsLayout()
    }
}