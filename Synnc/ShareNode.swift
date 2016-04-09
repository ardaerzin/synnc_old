//
//  ShareNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit
import pop

class ShareNode : ASDisplayNode {
    
    var titleNode : ASTextNode!
    let titleAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    let buttonAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    
    var facebookShareButton : ShareButton!
    var twitterShareButton : ShareButton!
    var smsShareButton : ShareButton!
    
    override init() {
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "Share this stream with your friends.", attributes: titleAttributes)
        titleNode.spacingBefore = 20
        
//        facebookShareButton = ShareButton()
//        facebookShareButton.imageNode.preferredFrameSize = CGSize(width: 20,height: 20)
        facebookShareButton.flexGrow = true
        facebookShareButton.setAttributedTitle(NSAttributedString(string: "Facebook", attributes: buttonAttributes), forState: ASControlState.Normal)
        facebookShareButton.setImage(UIImage(named: "facebook-logo"), forState: .Normal)
        
//        twitterShareButton = ShareButton()
//        twitterShareButton.imageNode.preferredFrameSize = CGSize(width: 20,height: 20)
        twitterShareButton.flexGrow = true
        twitterShareButton.setAttributedTitle(NSAttributedString(string: "Twitter", attributes: buttonAttributes), forState: ASControlState.Normal)
        twitterShareButton.setImage(UIImage(named: "twitter-logo"), forState: .Normal)
        
//        smsShareButton = ShareButton()
//        smsShareButton.imageNode.preferredFrameSize = CGSize(width: 20,height: 20)
        smsShareButton.flexGrow = true
        smsShareButton.setAttributedTitle(NSAttributedString(string: "SMS", attributes: buttonAttributes), forState: ASControlState.Normal)
        smsShareButton.setImage(UIImage(named: "mail"), forState: .Normal)
        
        
        self.addSubnode(titleNode)
        self.addSubnode(facebookShareButton)
        self.addSubnode(twitterShareButton)
        self.addSubnode(smsShareButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [facebookShareButton, twitterShareButton, smsShareButton])
        hStack.alignSelf = .Stretch
        hStack.spacingAfter = 20
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 20, justifyContent: .Center, alignItems: .Center, children: [titleNode, hStack])
        
        return x
    }
}