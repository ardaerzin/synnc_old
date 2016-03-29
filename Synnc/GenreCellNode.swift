//
//  GenreCellNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/4/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import pop

class GenreCellNode : ASCellNode {
    
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            
            let r = POPTransition(cellStateAnimationProgress, startValue: 176, endValue: 97)
            let g = POPTransition(cellStateAnimationProgress, startValue: 219, endValue: 97)
            let b = POPTransition(cellStateAnimationProgress, startValue: 223, endValue: 97)
            self.titleAttributes[NSForegroundColorAttributeName] = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
//
            self.genreTitleNode.attributedString = NSAttributedString(string: self.genreTitleNode.attributedString!.string, attributes: self.titleAttributes)
            
            let s = POPTransition(cellStateAnimationProgress, startValue: 1, endValue: 1.2)
            POPLayerSetScaleXY(genreTitleNode.layer, CGPointMake(s,s))
//            self.backgroundColor = UIColor.SynncColor().colorWithAlphaComponent(cellStateAnimationProgress)
        }
    }
    var cellStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("trackCellStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! GenreCellNode).cellStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! GenreCellNode).cellStateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        cellStateAnimationProgress = self.selected ? 1 : 0
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
    override var selected : Bool {
        didSet {
            self.cellStateAnimation.toValue = selected ? 1 : 0
        }
    }
    var genreTitleNode : ASTextNode!
    lazy var titleAttributes : [String : AnyObject] = {
       
        let paragraphAttributes = NSMutableParagraphStyle()
        paragraphAttributes.alignment = .Center

        
        return [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green : 219/255, blue: 223/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : paragraphAttributes]
    }()
    
    override init() {
        super.init()
        genreTitleNode = ASTextNode()
        self.addSubnode(genreTitleNode)
    }
    
    func configure(genre: Genre) {
//        let paragraphAttributes = NSMutableParagraphStyle()
//        paragraphAttributes.alignment = .Center
//
//        self.titleAttributes[NSParagraphStyleAttributeName] = paragraphAttributes
//        self.titleAttributes[NSForegroundColorAttributeName] = UIColor.SynncColor()
        
        genreTitleNode.attributedString = NSAttributedString(string: genre.name, attributes: self.titleAttributes)
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        genreTitleNode.flexBasis = ASRelativeDimension(type: .Percent, value: 1)
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [genreTitleNode])
        a.alignSelf = .Stretch
        let b = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [a])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25), child: b)
    }
}