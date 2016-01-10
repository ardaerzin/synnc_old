//
//  TitleColorButton.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit

class TitleColorButton : ButtonNode {
    var normalTitle : NSAttributedString!
    var selectedTitle : NSAttributedString!
    init(normalTitleString : String, selectedTitleString : String, attributes : [String : AnyObject], normalColor : UIColor, selectedColor : UIColor){
        super.init()
        
        var normalAttributes = attributes
        normalAttributes[NSForegroundColorAttributeName] = normalColor
        var selectedAttributes = attributes
        selectedAttributes[NSForegroundColorAttributeName] = selectedColor
        
        self.normalTitle = NSAttributedString(string: normalTitleString, attributes: normalAttributes)
        self.selectedTitle = NSAttributedString(string: selectedTitleString, attributes: selectedAttributes)
        
        self.setAttributedTitle(normalTitle, forState: ASControlState.Normal)
//        self.setAttributedTitle(selectedTitle, forState: ASControlState.Highlighted)
    }
    
    override func changedSelected() {
        super.changedSelected()
        let title = self.selected ? self.selectedTitle : self.normalTitle
        self.setAttributedTitle(title, forState: ASControlState.Normal)
    }
}