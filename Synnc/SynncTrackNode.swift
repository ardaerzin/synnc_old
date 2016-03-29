//
//  SynncTrackNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/26/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop

enum TrackCellState {
    case Add
    case Remove
}
class TrackStatusButton : ASDisplayNode {
    var line1 : ASDisplayNode!
    var line2 : ASDisplayNode!
    var state : TrackCellState = .Add {
        didSet {
            if state != oldValue {
                self.buttonStatusAnimation.toValue = state == .Remove ? 1 : 0
            }
        }
    }
    var buttonStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("serverStatusAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! TrackStatusButton).buttonStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! TrackStatusButton).buttonStatusAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var buttonStatusAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("buttonStatusAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("buttonStatusAnimation")
                }
                x.springBounciness = 1
                x.property = self.buttonStatusAnimatableProperty
                self.pop_addAnimation(x, forKey: "buttonStatusAnimation")
                return x
            }
        }
    }
    var buttonStatusAnimationProgress : CGFloat = 0 {
        didSet {
            let line1Rotation = POPTransition(buttonStatusAnimationProgress, startValue: 0, endValue: CGFloat((M_PI_2)/2))
            let line2Rotation = POPTransition(buttonStatusAnimationProgress, startValue: 0, endValue: CGFloat((M_PI_2)/2))
            
            POPLayerSetRotation(line1.layer, line1Rotation)
            POPLayerSetRotation(line2.layer, line2Rotation)
            
            if let rgbTarget = UIColor.SynncColor().rgb() {
                let targetRed = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: CGFloat(rgbTarget.red)) / 255
                let targetGreen = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: CGFloat(rgbTarget.green)) / 255
                let targetBlue = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: CGFloat(rgbTarget.blue)) / 255
                
                line1.backgroundColor = UIColor(red: targetRed, green: targetGreen, blue: targetBlue, alpha: 1)
                line2.backgroundColor = UIColor(red: targetRed, green: targetGreen, blue: targetBlue, alpha: 1)
            }
        }
    }
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = buttonStatusAnimationProgress
        self.buttonStatusAnimationProgress = a
    }
    override init() {
        super.init()
        
        line1 = ASDisplayNode()
        line1.layerBacked = true
        line1.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 2.5))
        line1.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        
        line2 = ASDisplayNode()
        line2.layerBacked = true
        line2.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 2.5), ASRelativeDimension(type: .Percent, value: 1))
        line2.backgroundColor = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        
        self.addSubnode(line1)
        self.addSubnode(line2)
    }
    override func layout() {
        super.layout()
        
        line1.position.x = self.calculatedSize.width / 2
        line1.position.y = self.calculatedSize.height / 2
        
        line2.position.x = self.calculatedSize.width / 2
        line2.position.y = self.calculatedSize.height / 2
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [line1, line2])
    }
}

class SynncTrackNode : ASCellNode {
    
    var trackNameNode : ASTextNode!
    var artistNameNode : ASTextNode!
    var iconNode : TrackStatusButton!
    var sourceNode : ASImageNode!
    
    var selectedSeperatorNode : ASDisplayNode!
    var seperatorNode : ASDisplayNode!
    
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
                self.iconNode.state = state
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
                    values[0] = (obj as! SynncTrackNode).cellStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SynncTrackNode).cellStateAnimationProgress = values[0]
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
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            let translation = POPTransition(cellStateAnimationProgress, startValue: -self.selectedSeperatorNode.bounds.width / 2, endValue: 0)
            
            POPLayerSetScaleX(self.selectedSeperatorNode.layer, cellStateAnimationProgress)
            POPLayerSetTranslationX(self.selectedSeperatorNode.layer, translation)
        }
    }
    
    override init() {
        super.init()
        
        self.artistNameNode = ASTextNode()
        self.artistNameNode.layerBacked = true
        self.artistNameNode.maximumNumberOfLines = 1
        
        self.trackNameNode = ASTextNode()
        self.trackNameNode.layerBacked = true
        self.trackNameNode.spacingBefore = 18
        
        self.iconNode = TrackStatusButton()
        
        self.selectedSeperatorNode = ASDisplayNode()
        self.selectedSeperatorNode.backgroundColor = UIColor.SynncColor()
        
        self.addSubnode(self.trackNameNode)
        self.addSubnode(self.artistNameNode)
        self.addSubnode(self.iconNode)
        //        self.addSubnode(self.sourceNode)
        
        self.addSubnode(self.selectedSeperatorNode)
        self.selectionStyle = .None
    }
    func configureForTrack(track : SynncTrack) {
        var artistStr : String?
        for artist in track.artists {
            if artistStr == nil {
                artistStr = artist.name
            } else {
                artistStr! += (" / " + artist.name)
            }
        }
        self.artistNameNode.attributedString = NSAttributedString(string: artistStr!, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)])
        
        if let x = track.name {
            trackNameNode.attributedString = NSAttributedString(string: x, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)])
        }
    }
    
    override func layout() {
        super.layout()
        self.selectedSeperatorNode.frame = CGRectMake(42.5, self.calculatedSize.height - 1, self.calculatedSize.width - 42.5, 1)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        artistNameNode.spacingBefore = 5
        artistNameNode.spacingAfter = 18
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [trackNameNode, artistNameNode])
        a.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (22 + 20 + 14 + 10))
        
        iconNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 14), ASRelativeDimension(type: .Points, value: 14))
        let iconSpec = ASStaticLayoutSpec(children: [self.iconNode])
        iconSpec.spacingBefore = 22
        a.spacingBefore = 20
        a.spacingAfter = 10
        
        let b = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [iconSpec, a])
        return b
    }
}