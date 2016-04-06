//
//  OnboardingPage.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnboardingImageHolder : ASDisplayNode {
    var imageNode : ASImageNode!
    
    override init() {
        super.init()
        
        imageNode = ASImageNode()
        imageNode.contentMode = .ScaleAspectFit
        
        self.addSubnode(imageNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        imageNode.alignSelf = .Stretch
//        imageNode.flexGrow = true
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children : [imageNode])])
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 10, 10, 10), child: stack)
    }
}

class OnboardingPageItem : ASCellNode {
    
    var titleNode : ASTextNode!
    var messageNode : ASTextNode!
    var imageHolder : OnboardingImageHolder!
    
    var messageAttributes : [String : AnyObject] {
        get {
            let paragraphAtrributes = NSMutableParagraphStyle()
            paragraphAtrributes.alignment = .Center
            paragraphAtrributes.lineHeightMultiple = 2
            
            let color = UIColor(red: 94/255, green: 93/255, blue: 93/255, alpha: 1)
            return [NSFontAttributeName : UIFont(name: "Ubuntu", size : 14)!, NSForegroundColorAttributeName : color, NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : paragraphAtrributes]
        }
    }
    var titleAttributes : [String : AnyObject] {
        get {
            let paragraphAtrributes = NSMutableParagraphStyle()
            paragraphAtrributes.alignment = .Center
            
            let color = UIColor.SynncColor()
            
            return [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 18)!, NSForegroundColorAttributeName : color, NSKernAttributeName : 1, NSParagraphStyleAttributeName : paragraphAtrributes]
        }
    }
    var item : OnboardingItem!
    
    override func fetchData() {
        super.fetchData()
        
        titleNode.attributedString = NSAttributedString(string: item.title, attributes: titleAttributes)
        messageNode.attributedString = NSAttributedString(string: item.mainText, attributes: messageAttributes)
        
        let img = UIImage(named: item.imageName)
        
        let imgLimitWidth = (imageHolder.calculatedSize.width - 20) * 0.65
        let imgLimitHeight = (imageHolder.calculatedSize.height - 20) * 0.65

        if let s = img?.size where s.width >= imgLimitWidth || s.height >= imgLimitHeight {
            imageHolder.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(imgLimitWidth, imgLimitHeight))
        } else {
            imageHolder.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(img!.size)
        }
        imageHolder.imageNode.image = img
        imageHolder.setNeedsLayout()
        
        self.setNeedsLayout()
    }
    
    init(item : OnboardingItem) {
        super.init()
        
        self.item = item
        titleNode = ASTextNode()
        titleNode.layerBacked = true
        
        messageNode = ASTextNode()
        messageNode.layerBacked = true
        
        imageHolder = OnboardingImageHolder()
        
        self.addSubnode(imageHolder)
        self.addSubnode(titleNode)
        self.addSubnode(messageNode)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let h = constrainedSize.max.width - 60
        imageHolder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(h, h))
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        let spacer3 = ASLayoutSpec()
        spacer3.flexGrow = true
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [ASStaticLayoutSpec(children: [imageHolder]), titleNode, spacer, messageNode, spacer2, spacer3])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 30, 0, 30), child: stack)
    }
}