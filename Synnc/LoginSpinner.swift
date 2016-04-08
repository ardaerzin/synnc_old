//
//  LoginSpinner.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager

enum LoginSpinnerState : Int {
    case None = -1
    case ServerConnect = 0
    case LoggingIn = 1
}

class SpinnerNode : ASDisplayNode {
    
    var animatedLogo : AnimatedLogoNode!
    var msgNode : ASTextNode!
    
    var state : LoginSpinnerState! {
        didSet {
            updateForState()
        }
    }
    
    func updateForState() {
        guard let s = self.state else {
            return
        }
        switch s {
        case .ServerConnect :
            let str = NSMutableAttributedString(string: "Connecting to Synnc Servers", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
            msgNode.attributedString = str
            break
        case .LoggingIn :
            msgNode.attributedString = NSAttributedString(string: "Logging you in..", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor.blackColor()])
            break
        default:
            break
        }
        
        self.setNeedsLayout()
    }
    
    deinit {
    }
     
    override init() {
        super.init()
        
        animatedLogo = AnimatedLogoNode(barCount: 5)
        animatedLogo.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSize(width: 30,height: 30))
        msgNode = ASTextNode()
        
        self.addSubnode(msgNode)
        self.addSubnode(animatedLogo)
    }
    
    override func didLoad() {
        super.didLoad()
        animatedLogo.startAnimation()
    }
    
    override func layout() {
        super.layout()
       
        if let n = self.supernode {
        
            let x = self.calculatedSize.width / 2
            let y = n.calculatedSize.width / 2
            let a = y - x
            
            self.animatedLogo.position.y = self.msgNode.position.y
            self.animatedLogo.position.x = self.calculatedSize.width + a - (self.animatedLogo.calculatedSize.width / 2)
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [self.msgNode])
        
        let a = ASStaticLayoutSpec(children: [animatedLogo])
        return ASOverlayLayoutSpec(child: x, overlay: a)
    }
}