//
//  MeNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/27/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit
import WCLUserManager
import Shimmer

class MeNode : ParallaxNode {
    
    var fullnameNode : ASTextNode!
    var usernameNode : MyTextNode!
    var usernameShimmer : FBShimmeringView!
    
    var editing : Bool = false {
        didSet {
            if editing != oldValue {
                
                self.usernameNode.userInteractionEnabled = editing
                self.usernameShimmer.shimmering = editing
                self.mainScrollNode.backgroundNode.editing = editing
            }
        }
    }
    
    var imageNode : ASNetworkImageNode! {
        get {
            return self.mainScrollNode.backgroundNode.imageNode
        }
    }
    
    lazy var settingsButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "SETTINGS", selectedTitleString: "SETTINGS", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    lazy var inboxButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "INBOX", selectedTitleString: "INBOX", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    lazy var editButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "EDIT", selectedTitleString: "SAVE", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    
    var buttons : [ButtonNode] {
        get {
            return [settingsButton, inboxButton, editButton]
        }
    }
    
    override func fetchData() {
        super.fetchData()
    }
    init(user : WCLUser) {
        
        let content = MeContentNode()
        
//        content.view.backgroundColor = UIColor.redColor()
        content.view.scrollEnabled = false
        
        let bgNode = ParallaxBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: content)
        
        self.headerNode.buttons = self.buttons
        
        fullnameNode = ASTextNode()
        
        
        
        usernameNode = MyTextNode()
        usernameNode.returnKeyType = UIReturnKeyType.Done
        usernameNode.userInteractionEnabled = false
        usernameNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)]
        
        self.usernameShimmer = FBShimmeringView()
        self.usernameShimmer.contentView = self.usernameNode.view
        
        self.addSubnode(fullnameNode)
        self.view.addSubview(self.usernameShimmer)
//        self.addSubnode(usernameNode)
    }
    
    func updateForUser(user : WCLUser) {
        if let name = user.name {
            fullnameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
//            usernameNode.attributedText = NSAttributedString(string: "@username", attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
        }
        
        if let uname = user.username {
            usernameNode.attributedText = NSAttributedString(string: uname, attributes: (usernameNode.typingAttributes as [String : AnyObject]!))
        }
    }
    
    override func layout() {
        super.layout()
        
        fullnameNode.position.x = (fullnameNode.calculatedSize.width / 2) + 20
        fullnameNode.position.y = (fullnameNode.calculatedSize.height / 2) + 50
        
        usernameShimmer.frame = CGRect(origin: CGPointMake(20, (fullnameNode.position.y + (fullnameNode.calculatedSize.height / 2)) + 10), size: self.usernameNode.calculatedSize)
//        usernameNode.position.x = (usernameNode.calculatedSize.width / 2) + 20
//        usernameNode.position.y = (fullnameNode.position.y + (fullnameNode.calculatedSize.height / 2)) + 10 + (usernameNode.calculatedSize.height / 2)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        usernameNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSize(width: ASRelativeDimension(type: .Points, value: 0), height: ASRelativeDimension(type: .Points, value: 21)), ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: 21)))
        return ASStaticLayoutSpec(children: [x, fullnameNode, usernameNode])
    }
}