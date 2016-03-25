//
//  AboutNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class AboutButton : ButtonNode {
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50,50))
        imageNode.contentMode = .Center
        let img = ASStaticLayoutSpec(children: [imageNode])
        return ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [img, self.titleNode])
    }
}

class AboutNode : CardNodeBase {
    
    var infoButton : AboutButton!
    var termsAndConditionsButton : AboutButton!
    var librariesButton : AboutButton!
    var buttons : [AboutButton] {
        get {
            return [infoButton, termsAndConditionsButton, librariesButton]
        }
    }
    
    override init() {
        super.init()
        
        infoButton = AboutButton()
        infoButton.setImage(UIImage(named: "info")!, forState: .Normal)
        let infoTitle = NSAttributedString(string: "About Us", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.5)])
        infoButton.setAttributedTitle(infoTitle, forState: .Normal)
        self.addSubnode(infoButton)
        
        termsAndConditionsButton = AboutButton()
        let termsTitle = NSAttributedString(string: "Terms", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.5)])
        termsAndConditionsButton.setAttributedTitle(termsTitle, forState: .Normal)
        termsAndConditionsButton.setImage(UIImage(named: "termsAndCon")!, forState: .Normal)
        self.addSubnode(termsAndConditionsButton)
        
        librariesButton = AboutButton()
        let libsTitle = NSAttributedString(string: "Libraries", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 0.5)])
        librariesButton.setAttributedTitle(libsTitle, forState: .Normal)
        librariesButton.setImage(UIImage(named: "libraries")!, forState: .Normal)
        self.addSubnode(librariesButton)
    }
    
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var items : [ASLayoutable] = []
        let x = ASLayoutSpec()
        x.flexGrow = true
        items.append(x)
        
        for item in buttons {
            items.append(item)
            let x = ASLayoutSpec()
            x.flexGrow = true
            items.append(x)
        }
        
        let stack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: items)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(20, 0, 20, 0), child: stack)
    }
}