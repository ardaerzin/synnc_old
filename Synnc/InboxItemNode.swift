//
//  InboxItemNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/28/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit
import pop

class NotifcationReadIndicator : ASDisplayNode {
    var indicator : ASDisplayNode!
    
    override init!() {
        super.init()
        
        self.indicator = ASDisplayNode()
        self.indicator.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(10, 10))
        self.indicator.cornerRadius = 5
        self.indicator.backgroundColor = UIColor.SynncColor()
        
        self.addSubnode(self.indicator)
    }
    
    override func layout() {
        super.layout()
        self.indicator.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        return ASStaticLayoutSpec(children: [self.indicator])
    }
}

class InboxItemNode : ASCellNode {
    
    var msgNode : ASTextNode!
    var timeStampNode : ASTextNode!
    var readIndicator : NotifcationReadIndicator!
    
    override var selected : Bool {
        didSet {
            if selected != oldValue {
                self.state = selected ? .Remove : .Add
            }
        }
    }
    var state : TrackCellState = .Add {
        didSet {
            if state != oldValue {
//                self.iconNode.state = state
                self.cellStateAnimation.toValue = state == .Add ? 0 : 1
            }
        }
    }
    
    var cellStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("trackCellStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! InboxItemNode).cellStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! InboxItemNode).cellStateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var cellStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("cellStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("cellStateAnimation")
                }
                x.springBounciness = 1
                x.property = self.cellStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "cellStateAnimation")
                return x
            }
        }
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
//            let translation = POPTransition(cellStateAnimationProgress, startValue: -self.selectedSeperatorNode.bounds.width / 2, endValue: 0)
//            POPLayerSetScaleX(self.selectedSeperatorNode.layer, cellStateAnimationProgress)
//            POPLayerSetTranslationX(self.selectedSeperatorNode.layer, translation)
        }
    }
    
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    override init!() {
        super.init()

        self.msgNode = ASTextNode()
        msgNode.spacingBefore = 13
        msgNode.spacingAfter = 3
        
        self.timeStampNode = ASTextNode()
        self.timeStampNode.attributedString = NSAttributedString(string: "5mins ago", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)])
        self.timeStampNode.spacingAfter = 10
        
        self.readIndicator = NotifcationReadIndicator()
        self.readIndicator.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50, 50))
        
        self.addSubnode(msgNode)
        self.addSubnode(timeStampNode)
        self.addSubnode(readIndicator)
    }
    func configureForNotification(notification : SynncNotification) {
        var mutableStr : NSMutableAttributedString = NSMutableAttributedString(string: notification.msg, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)])
            (mutableStr.string as! NSString)
        let range = (mutableStr.string as NSString).rangeOfString("((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})", options: .RegularExpressionSearch)
        if range.length > 0 {
            mutableStr.addAttributes([NSForegroundColorAttributeName : UIColor.SynncColor()], range: range)
        }
        
        self.msgNode.attributedString = mutableStr
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [msgNode, timeStampNode])
        a.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (31 + 50))
        a.spacingBefore = 31
        
//        a.spacingAfter = 10
        
        let b = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [a, ASStaticLayoutSpec(children: [readIndicator])])
        return b
    }
}