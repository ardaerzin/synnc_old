//
//  PlaylistEmptyNode.swift
//  Synnc
//
//  Created by Arda Erzin on 2/1/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager

extension PlaylistEmptyNode {
    func newPlaylistAction(sender: ButtonNode) {
        sender.alpha = 0
    }
}

class PlaylistEmptyNode : ASDisplayNode {
    
    var mainTextNode : ASTextNode!
    var subTextNode : ASTextNode!
    
    override init() {
        super.init()
        
        mainTextNode = ASTextNode()
        
        subTextNode = ASTextNode()
        subTextNode.spacingBefore = 20
        
        self.addSubnode(mainTextNode)
        self.addSubnode(subTextNode)
    }
    
    func setText(message : String, withAction: Bool){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineHeightMultiple = 1.25
        
        mainTextNode.attributedString = NSAttributedString(string: message, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1, NSParagraphStyleAttributeName : paragraphStyle])
        
        
        if withAction {
            let a = NSAttributedString(string: "Start searching for ", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1])
            let b = NSAttributedString(string: "tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.1])
            let c = NSMutableAttributedString(attributedString: a)
            let d = NSMutableAttributedString(attributedString: b)
            c.appendAttributedString(d)
            
            subTextNode.attributedString = c
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let headerSpacer = ASLayoutSpec()
        headerSpacer.flexBasis = ASRelativeDimension(type: .Points, value: 0)
        
        let spacerBefore = ASLayoutSpec()
        spacerBefore.flexBasis = ASRelativeDimension(type: .Percent, value: 0)
        
        mainTextNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.5)
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [headerSpacer, spacerBefore, ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [mainTextNode]), subTextNode])
    }
}