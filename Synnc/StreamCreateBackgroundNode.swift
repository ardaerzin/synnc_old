//
//  StreamCreateBackgroundNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/3/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager

class StreamCreateBackgroundNode : ParallaxBackgroundNode {
    
    var streamTitle : ASEditableTextNode!
    var startStreamButton : ButtonNode!
    var locationToggle : ButtonNode!
    //    var locationToggle : ButtonNode!
    
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        self.streamTitle.resignFirstResponder()
    }
    
    override init!() {
        super.init()
        
        self.view.delaysContentTouches = false
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        streamTitle = ASEditableTextNode()
        streamTitle.returnKeyType = UIReturnKeyType.Done
        streamTitle.attributedPlaceholderText = NSAttributedString(string: "Enter Stream Name", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 230/255, green: 228/255, blue: 228/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        streamTitle.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSParagraphStyleAttributeName : paragraphAtrributes, NSKernAttributeName : 0.3]
        
        startStreamButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        startStreamButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 30))
        startStreamButton.setAttributedTitle(NSAttributedString(string: "START STREAMING", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 10)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASButtonStateNormal)
        
        locationToggle = TitleColorButton(normalTitleString: "SHOW LOCATION", selectedTitleString: "HIDE LOCATION", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSKernAttributeName : 0.3], normalColor: .whiteColor(), selectedColor: .whiteColor())
        //        locationToggle = Title
        //        locationToggle.setAttributedTitle(NSAttributedString(string: "START STREAMING", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 10)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASButtonStateNormal)
        
        self.addSubnode(streamTitle)
        self.addSubnode(startStreamButton)
        self.addSubnode(locationToggle)
    }
    override func layout() {
        super.layout()
        
        let h = (streamTitle.calculatedSize.height + self.startStreamButton.calculatedSize.height + 41) / 2
        streamTitle.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 - h)
        startStreamButton.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 + h)
        
        locationToggle.position = CGPointMake((locationToggle.calculatedSize.width / 2) + 23, (calculatedSize.height) - 37 - locationToggle.calculatedSize.height / 2)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let x = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [x, streamTitle, startStreamButton, locationToggle])
    }
    
    override func updateScrollPositions(position: CGFloat) {
        super.updateScrollPositions(position)
        
        let title = self.streamTitle
        let titleLimit = title.calculatedSize.height / 2 + 70
        
        if position <= -(titleLimit - title.position.y) / 0.5 {
            POPLayerSetTranslationY(title.layer, -position*0.25)
        } else {
            POPLayerSetTranslationY(title.layer, ((titleLimit - title.position.y) / 0.5) * 0.25)
        }
        
        let button = self.startStreamButton
        let buttonLimit = button.calculatedSize.height / 2 + 90
        
        if position <= -(buttonLimit - button.position.y) / 0.6 {
            POPLayerSetTranslationY(button.layer, -position*0.3)
        } else {
            POPLayerSetTranslationY(button.layer, ((buttonLimit - button.position.y) / 0.6) * 0.3)
        }

    }
}