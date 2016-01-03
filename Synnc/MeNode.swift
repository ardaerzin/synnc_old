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

class MeNode : ParallaxNode {
    
    var mainTextNode : ASTextNode!
    var subTextNode : ASEditableTextNode!
    
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
        
        var content = MeContentNode()
        
//        content.view.backgroundColor = UIColor.redColor()
        content.view.scrollEnabled = false
        
        let bgNode = ParallaxBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: content)
        
        self.headerNode.buttons = self.buttons
        
        mainTextNode = ASTextNode()
        
        
        
        subTextNode = ASEditableTextNode()
        subTextNode.returnKeyType = UIReturnKeyType.Done
        subTextNode.userInteractionEnabled = false
        subTextNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)]
        
        
        self.addSubnode(mainTextNode)
        self.addSubnode(subTextNode)
    }
    
    func updateForUser(user : WCLUser) {
        if let name = user.name {
            mainTextNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
            subTextNode.attributedText = NSAttributedString(string: "@username", attributes: (subTextNode.typingAttributes as! [String : AnyObject]))
        }
    }
    
    override func layout() {
        super.layout()
        
        mainTextNode.position.x = (mainTextNode.calculatedSize.width / 2) + 20
        mainTextNode.position.y = (mainTextNode.calculatedSize.height / 2) + 50
        
        subTextNode.position.x = (subTextNode.calculatedSize.width / 2) + 20
        subTextNode.position.y = (mainTextNode.position.y + (mainTextNode.calculatedSize.height / 2)) + 10 + (subTextNode.calculatedSize.height / 2)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let x = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [x, mainTextNode, subTextNode])
    }
}