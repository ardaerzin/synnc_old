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
import pop
import WCLUIKit

class WCLMaterialTextField : ASDisplayNode {

    enum WCLMaterialTextFieldPlaceholderState {
        case FullSize
        case Minimal
    }
    
    var attributedPlaceholderText : NSAttributedString! {
        didSet {
            placeholderLabel.attributedString = attributedPlaceholderText
        }
    }
    var isSecure : Bool = false {
        didSet {
            textNode.textView.secureTextEntry = isSecure
        }
    }
    var placeholderLabel : ASTextNode!
    var textNode : ASEditableTextNode!
    var borderLine : ASDisplayNode!
    
    var placeholderState : WCLMaterialTextFieldPlaceholderState! {
        didSet {
            if placeholderState == .FullSize {
                placeholderAnimation.toValue = 0
            } else {
                placeholderAnimation.toValue = 1
            }
        }
    }
    
    var placeholderAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! WCLMaterialTextField).placeholderProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! WCLMaterialTextField).placeholderProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var placeholderAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("scaleAnimation")
                }
                x.springBounciness = 0
                x.property = self.placeholderAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    var placeholderProgress : CGFloat = 0 {
        didSet {
  
            let s : CGFloat = 0.75
            let scale = POPTransition(placeholderProgress, startValue: 1, endValue: s)

            let translationX = POPTransition(placeholderProgress, startValue: 0, endValue: -self.placeholderLabel.calculatedSize.width * (1-s) / 2)
            let translationY = POPTransition(placeholderProgress, startValue: 0, endValue: -self.calculatedSize.height / 2 - (self.calculatedSize.height*s/2))
            
            POPLayerSetScaleXY(self.placeholderLabel.layer, CGPointMake(scale,scale))
            POPLayerSetTranslationXY(self.placeholderLabel.layer, CGPointMake(translationX, translationY))
        }
    }
    
    
    override init() {
        super.init()
        
        textNode = ASEditableTextNode()
        textNode.scrollEnabled = false
        textNode.alignSelf = .Stretch
        textNode.flexGrow = true
        
        textNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.48), NSKernAttributeName : 1]
        
        placeholderLabel = ASTextNode()
        placeholderLabel.maximumNumberOfLines = 1
        placeholderLabel.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 0.5))
        placeholderLabel.userInteractionEnabled = false
        
        textNode.delegate = self
        
        borderLine = ASDisplayNode()
        borderLine.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.48)
        borderLine.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        borderLine.alignSelf = .Stretch
        
        self.addSubnode(textNode)
        self.addSubnode(placeholderLabel)
        self.addSubnode(borderLine)
    }
    
    func setPlaceholder(placeholderStr : NSAttributedString){
        self.placeholderLabel.attributedString = placeholderStr
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [textNode, borderLine])
        let b = ASOverlayLayoutSpec(child: a, overlay: placeholderLabel)
        return b
    }
}

extension WCLMaterialTextField : ASEditableTextNodeDelegate {
    func editableTextNodeDidBeginEditing(editableTextNode: ASEditableTextNode) {
        
    }
    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
        
    }
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {
        if let str = editableTextNode.attributedText?.string where str != "" {
            self.placeholderState = .Minimal
            return
        }
        self.placeholderState = .FullSize
    }
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            return false
        }
        return true
    }
}