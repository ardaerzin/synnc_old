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

class ProfileCardNode : CardNodeBase, TrackedView {
    
    var title: String! = "Profile View"
    var otherProfile : Bool = false
    var imageNode : ASNetworkImageNode!
    var usernameNode : ASEditableTextNode!
    var usernameBorder : ASDisplayNode!
    var followersNode : ASTextNode!
    var followingNode : ASTextNode!
    var followButton : ButtonNode!
    
    var ghostLabel : ASTextNode!
    
    var followAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 94/255, green: 93/255, blue: 93/255, alpha: 0.19)]
    var followNumberAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 16)!, NSForegroundColorAttributeName : UIColor.SynncColor()]
    
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
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(120,120))
        imageNode.shadowColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1).CGColor
        imageNode.shadowOpacity = 1
        imageNode.shadowOffset = CGSizeMake(0, 3)
        imageNode.shadowRadius = 6
        self.addSubnode(imageNode)
        
        usernameNode = ASEditableTextNode()
        usernameNode.spacingBefore = 40
        usernameNode.spacingAfter = 2
        usernameNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSParagraphStyleAttributeName : p]
        usernameNode.returnKeyType = UIReturnKeyType.Done
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
        
        followButton = ButtonNode(normalColor: UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1), selectedColor: .clearColor())
        followButton.borderColor = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1).CGColor
        followButton.borderWidth = 3
        followButton.cornerRadius = 15
        followButton.spacingBefore = 30
        followButton.contentEdgeInsets = UIEdgeInsetsMake(8, 30, 12, 30)
        
        let buttonNormalAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        let buttonSelectedAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)]
        
        let followTitle = NSAttributedString(string: "FOLLOW", attributes: buttonNormalAttributes)
        let unfollowTitle = NSAttributedString(string: "UNFOLLOW", attributes: buttonSelectedAttributes)
        
        followButton.setAttributedTitle(followTitle, forState: .Normal)
        followButton.setAttributedTitle(unfollowTitle, forState: .Selected)
        self.addSubnode(followButton)
        
        ghostLabel = ASTextNode()
        ghostLabel.alpha = 0
        self.addSubnode(ghostLabel)
    }
    
    func updateForUser(user : WCLUser) {
        if let uname = user.username {
            usernameNode.attributedText = NSMutableAttributedString(string: uname, attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
            ghostLabel.attributedString = NSMutableAttributedString(string: uname, attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
        }
        
        if let provider = user.provider, let type = WCLUserLoginType(rawValue: provider), let url = user.avatarURL(type, frame: CGRectMake(0, 0, 120, 120), scale: UIScreen.mainScreen().scale) {
            imageNode.URL = url
        }
        
        let followersNumberStr = NSAttributedString(string: "0 ", attributes: followNumberAttributes)
        let followersStr = NSAttributedString(string: " followers", attributes: followAttributes)
        let followers = NSMutableAttributedString()
        followers.appendAttributedString(followersNumberStr)
        followers.appendAttributedString(followersStr)
        followersNode.attributedString = followers
        
        
        let followingsNumberStr = NSAttributedString(string: "0 ", attributes: followNumberAttributes)
        let followingsStr = NSAttributedString(string: " following", attributes: followAttributes)
        let followings = NSMutableAttributedString()
        followings.appendAttributedString(followingsNumberStr)
        followings.appendAttributedString(followingsStr)
        followingNode.attributedString = followings
        
        otherProfile = user != Synnc.sharedInstance.user
        
        setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASStaticLayoutSpec(children: [imageNode])
        
        let y = ASStaticLayoutSpec(children: [usernameBorder])
        y.spacingAfter = 20
        
        var nodes : [ASLayoutable] = [imageSpec, usernameNode, y, followersNode, followingNode]
        if otherProfile {
            nodes.append(followButton)
        }
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: nodes)
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(30, 30, 50, 30), child: x)
//        return ASRatioLayoutSpec(ratio: 1/4, child: x)
    }
}