//
//  ChatItemNode.swift
//  Synnc
//
//  Created by Arda Erzin on 2/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import WCLUtilities
import WCLUserManager
import SwiftyJSON
import AsyncDisplayKit
import WCLUIKit
import Shimmer
import WCLPopupManager

class MyChatItemNode : ChatItemNode {
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASStaticLayoutSpec(children: [self.imageNode])
        imageSpec.spacingAfter = 10
        imageSpec.spacingBefore = 0
        
        self.textHolder.flexBasis = ASRelativeDimension(type: .Points, value: max(0,constrainedSize.max.width - 40 - 36 - 10 - 10 - 20 - 6))
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .End, alignItems: .Start, children: [ textHolder, imageSpec])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 0, bottom: bottomMarg, right: 0), child: x)
    }
}

class ChatTextBubble : ASDisplayNode {
    
    var sendingShimmer : FBShimmeringView!
    var textNode : ASTextNode!
    
    
    override init() {
        super.init()
        
        textNode = ASTextNode()
        self.sendingShimmer = FBShimmeringView()
//        self.addSubnode(textNode)
        
    }
    
    override func didLoad() {
        super.didLoad()
        self.sendingShimmer.contentView = self.textNode.view
        self.sendingShimmer.shimmeringPauseDuration = 0.1
        self.sendingShimmer.shimmeringSpeed = 20
        
        self.view.addSubview(self.sendingShimmer)
    }
    
    override func layout() {
        super.layout()
        
        self.sendingShimmer.frame = CGRect(origin: CGPointMake(5, 5), size: self.textNode.calculatedSize)
        
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
        var roundedCorners : UIRectCorner
        if let _ = self.supernode?.supernode as? MyChatItemNode {
            roundedCorners = [.BottomLeft, .BottomRight, .TopLeft]
            self.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.25)
        } else {
            roundedCorners = [.BottomLeft, .BottomRight, .TopRight]
            self.backgroundColor = UIColor.SynncColor().colorWithAlphaComponent(0.25)
        }
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = CGRect(origin: CGPointZero, size: self.calculatedSize)
        rectShape.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2)
        rectShape.path = UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: self.calculatedSize), byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: 5, height: 5)).CGPath
        
        rectShape.backgroundColor = UIColor.clearColor().CGColor
        self.layer.mask = rectShape
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(7, 7, 7, 7), child: textNode)
    }
}
class ChatTextHolder : ASDisplayNode {
    
    var bubble : ChatTextBubble!
    
    var usernameNode : UserNameNode!
    var textNode : ASTextNode! {
        get {
            return self.bubble.textNode
        }
    }
    override init() {
        super.init()
  
        bubble = ChatTextBubble()
        usernameNode = UserNameNode()

        self.addSubnode(usernameNode)
        self.addSubnode(bubble)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var alignment : ASStackLayoutAlignItems
        if let _ = self.supernode as? MyChatItemNode {
            alignment = .End
        } else {
            alignment = .Start
        }
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 2, justifyContent: .Start, alignItems: alignment, children: [usernameNode, bubble])
    }
}

class ChatItemNode : ASCellNode {
    
    var imageNode : UserImageNode!
    var textHolder : ChatTextHolder!
    
    //Data
    var username : String!
    var messageString : String!
    var messageUserAvatar : NSURL!
    var timeString : String!
    
    var bottomMarg : CGFloat = 5
    
    override init(){
        super.init()
        
        imageNode = UserImageNode()
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30, 30))
        
        self.textHolder = ChatTextHolder()
        self.textHolder.alignSelf = .Stretch
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.addSubnode(imageNode)
        self.addSubnode(textHolder)
        
        self.imageNode.userInteractionEnabled = true
        self.textHolder.usernameNode.userInteractionEnabled = true
        
//        self.imageNode.addTarget(self, action: #selector(ChatItemNode.didTapUserInfo(_:)) , forControlEvents: .TouchUpInside)
//        self.textHolder.usernameNode.addTarget(self, action: #selector(ChatItemNode.didTapUserInfo(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASStaticLayoutSpec(children: [self.imageNode])
        imageSpec.spacingBefore = 10
        
        self.textHolder.flexBasis = ASRelativeDimension(type: .Points, value: max(0,constrainedSize.max.width - 40 - 36 - 10 - 10 - 20 - 6))
        
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Start, alignItems: .Start, children: [imageSpec, textHolder])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 0, bottom: bottomMarg, right: 0), child: x)
    }
    override func fetchData() {
        super.fetchData()
        
        if messageUserAvatar != self.imageNode.URL {
            self.imageNode.URL = messageUserAvatar
        }
        if let msg = self.messageString {
            self.textHolder.textNode.attributedString = NSAttributedString(string: msg, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)])
        }
        self.textHolder.usernameNode.attributedString = NSAttributedString(string: self.username, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor.SynncColor()])
    }
    func configure(item: ChatItem){
        
        self.textHolder.usernameNode.userId = item.user._id
        self.imageNode.userId = item.user._id
        
        self.messageString = item.message.stringByRemovingPercentEncoding
        self.messageUserAvatar = item.user.avatarURL(WCLUserLoginType(rawValue: item.user.provider)!, frame: CGRectMake(0, 0, 40, 40), scale: UIScreen.mainScreen().scale)
        
        self.username = item.user.username
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.timeString = formatter.stringFromDate(NSDate())
        
    
        self.textHolder.bubble.sendingShimmer.shimmering = item.user == Synnc.sharedInstance.user ? !item.status : false
        
        self.fetchData()
    }
}