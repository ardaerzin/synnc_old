//
//  ProfileCardNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/23/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUserManager
import pop

class ProfileCardNode : CardNodeBase {
    var imageNode : ASNetworkImageNode!
    var usernameNode : ASEditableTextNode!
    var usernameBorder : ASDisplayNode!
    var followersNode : ASTextNode!
    var followingNode : ASTextNode!
    var ghostLabel : ASTextNode!
    
    var followAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.19)]
    var followNumberAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 160/255, green: 211/255, blue: 216/255, alpha: 1)]
    
    var usernameBorderAnimation : POPBasicAnimation {
        get {
            if let x = self.usernameBorder.pop_animationForKey("borderDisplayAnim") as? POPBasicAnimation {
                return x
            } else {
                let animation = POPBasicAnimation(propertyNamed: kPOPViewAlpha )
                animation.duration = 0.2
                self.usernameBorder.pop_addAnimation(animation, forKey: "borderDisplayAnim")
                return animation
            }
        }
    }
    func hideUsernameBorder(){
        usernameBorderAnimation.toValue = 0
    }
    func displayUsernameBorder(){
        usernameBorderAnimation.toValue = 1
    }
    
    override init(){
        super.init()
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        imageNode = ASNetworkImageNode()
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(100,100))
        imageNode.shadowColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1).CGColor
        imageNode.shadowOpacity = 1
        imageNode.shadowOffset = CGSizeMake(0, 3)
        imageNode.shadowRadius = 6
        
        self.addSubnode(imageNode)
        
        let a = UIView()
        a.frame = CGRectMake(0,0,100,50)
        a.backgroundColor = .orangeColor()
        
        usernameNode = ASEditableTextNode()
        usernameNode.spacingBefore = 40
        usernameNode.spacingAfter = 2
        usernameNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 140/255, green: 185/255, blue: 189/255, alpha: 1), NSParagraphStyleAttributeName : p]
        usernameNode.returnKeyType = UIReturnKeyType.Done
//        usernameNode.
//            view.inputAccessoryView =
        self.addSubnode(usernameNode)
        
        usernameBorder = ASDisplayNode()
        usernameBorder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeZero)
        usernameBorder.backgroundColor = .redColor()
        usernameBorder.alpha = 0
        self.addSubnode(usernameBorder)
        
        followingNode = ASTextNode()
        self.addSubnode(followingNode)
        
        followersNode = ASTextNode()
        followersNode.spacingAfter = 7
        self.addSubnode(followersNode)
        
        ghostLabel = ASTextNode()
        ghostLabel.alpha = 0
        self.addSubnode(ghostLabel)
    }
    
    func updateForUser(user : MainUser) {
        if let uname = user.username {
            usernameNode.attributedText = NSMutableAttributedString(string: uname, attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
            ghostLabel.attributedString = NSMutableAttributedString(string: uname, attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
        }
        
        if let provider = Synnc.sharedInstance.user.provider, let type = WCLUserLoginType(rawValue: provider), let url = Synnc.sharedInstance.user.avatarURL(type, frame: CGRectMake(0, 0, 100, 100), scale: UIScreen.mainScreen().scale) {
            
            imageNode.URL = url
        }
        
        let followersNumberStr = NSAttributedString(string: "35 ", attributes: followNumberAttributes)
        let followersStr = NSAttributedString(string: " followers", attributes: followAttributes)
        let followers = NSMutableAttributedString()
        followers.appendAttributedString(followersNumberStr)
        followers.appendAttributedString(followersStr)
        followersNode.attributedString = followers
        
        
        let followingsNumberStr = NSAttributedString(string: "27 ", attributes: followNumberAttributes)
        let followingsStr = NSAttributedString(string: " following", attributes: followAttributes)
        let followings = NSMutableAttributedString()
        followings.appendAttributedString(followingsNumberStr)
        followings.appendAttributedString(followingsStr)
        followingNode.attributedString = followings
        
        setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASStaticLayoutSpec(children: [imageNode])
        
        let y = ASStaticLayoutSpec(children: [usernameBorder])
        y.spacingAfter = 20
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [imageSpec, usernameNode, y, followersNode, followingNode])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(50, 30, 50, 30), child: x)
    }
}