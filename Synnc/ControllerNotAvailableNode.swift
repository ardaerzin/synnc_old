//
//  ControllerNotAvailableNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/20/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class ControllerNotAvailableNode : ASDisplayNode {
    var mainTextNode : ASTextNode!
    var subTextNode : ASTextNode!
    var controllerName : String!
    
    override init() {
        super.init()
        
        mainTextNode = ASTextNode()
        
        subTextNode = ASTextNode()
        subTextNode.spacingBefore = 20
        
        self.addSubnode(mainTextNode)
        self.addSubnode(subTextNode)
    }
    override func fetchData() {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineHeightMultiple = 1.25
        
        mainTextNode.attributedString = NSAttributedString(string: "\"" + controllerName + "\" will be here soon...", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1, NSParagraphStyleAttributeName : paragraphStyle])
        
//        let a = NSAttributedString(string: "Create a ", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1])
//        let b = NSAttributedString(string: "new playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.1])
//        let c = NSMutableAttributedString(attributedString: a)
//        let d = NSMutableAttributedString(attributedString: b)
//        c.appendAttributedString(d)
//        subTextNode.attributedString = c
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