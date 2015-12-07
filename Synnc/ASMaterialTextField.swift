//
//  ASMaterialTextField.swift
//  Synnc
//
//  Created by Arda Erzin on 12/2/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit
import AsyncDisplayKit.ASDisplayNode_Subclasses

class ASMaterialTextField : ASEditableTextNode {

    var placeholderLabel : ASTextNode!
    
    override init!() {
        super.init()
    
        placeholderLabel = ASTextNode()
//        placeholderLabel.maximumLineCount = 1
        placeholderLabel.backgroundColor = UIColor.redColor()
        placeholderLabel.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 0.5))
        
        self.addSubnode(placeholderLabel)
    }
    
    func setPlaceholder(placeholderStr : NSAttributedString){
        self.placeholderLabel.attributedString = placeholderStr
    }
    override func calculateLayoutThatFits(constrainedSize: ASSizeRange) -> ASLayout! {
        return nil
    }
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
//        return ASStaticLayoutSpec(children: [self.placeholderLabel])
//    }
}