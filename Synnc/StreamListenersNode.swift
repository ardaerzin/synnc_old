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
    
    var noListenersText : ASTextNode!
    var noListenersAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1), NSKernAttributeName : -0.1]
    
    var emptyState : Bool = true {
        didSet {
            if emptyState != oldValue {
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
    override init() {
        super.init()
        
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "People Connected:", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1), NSKernAttributeName : -0.1])
        
        noListenersText = ASTextNode()
        noListenersText.attributedString = NSAttributedString(string: "Share your stream and get listeners", attributes: self.noListenersAttributes)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        listenersCollection = ASCollectionNode(collectionViewLayout: layout)
        listenersCollection.alignSelf = .Stretch
        listenersCollection.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        
        
        self.addSubnode(titleNode)
        self.addSubnode(listenersCollection)
        self.addSubnode(noListenersText)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlaySpec = ASOverlayLayoutSpec(child: self.listenersCollection, overlay: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: noListenersText))
        overlaySpec.alignSelf = .Stretch
        overlaySpec.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Start, alignItems: .Start, children: [self.titleNode, overlaySpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25), child: vStack)
    }
    
    func update(stream: Stream) {
        if stream == StreamManager.sharedInstance.userStream {
            noListenersText.attributedString = NSAttributedString(string: "Share your stream and get listeners", attributes: self.noListenersAttributes)
        } else {
            noListenersText.attributedString = NSAttributedString(string: "This stream does not have any listeners", attributes: self.noListenersAttributes)
        }
    }
}