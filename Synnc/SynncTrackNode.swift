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
import WCLUtilities
import Async

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
            
            let targetRed = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: 255) / 255
            let targetGreen = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: 255) / 255
            let targetBlue = POPTransition(buttonStatusAnimationProgress, startValue: 215, endValue: 255) / 255
                
            line1.backgroundColor = UIColor(red: targetRed, green: targetGreen, blue: targetBlue, alpha: 1)
            line2.backgroundColor = UIColor(red: targetRed, green: targetGreen, blue: targetBlue, alpha: 1)
            
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

class ImageHolder : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    var dummy : ASDisplayNode!
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        imageNode.layerBacked = true
        
        dummy = ASDisplayNode()
        dummy.layerBacked = true
        self.addSubnode(dummy)
        self.addSubnode(imageNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [dummy])
        return ASOverlayLayoutSpec(child: a, overlay: imageNode)
    }
}

class SynncTrackContentNode : ASDisplayNode {
    var imageNode : ASNetworkImageNode! {
        get {
            return self.imageHolder.imageNode
        }
    }
    var iconNode : TrackStatusButton! {
        get {
            return self.infoNode.iconNode
        }
    }
    var imageHolder : ImageHolder!
    var infoNode : TrackInfoNode!
    
    init(withIcon: Bool, withSource : Bool) {
        super.init()
        
        imageHolder = ImageHolder()
        imageHolder.flexGrow = false
        imageHolder.flexShrink = false
        imageHolder.flexBasis = ASRelativeDimensionMake(.Points, 70)
        imageHolder.alignSelf = .Stretch
        
        infoNode = TrackInfoNode(withIcon: withIcon, withSource: withSource)
        
        self.addSubnode(imageHolder)
        self.addSubnode(infoNode)
    }
    
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        infoNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (70 + 2.5))
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 2.5, justifyContent: .Start, alignItems: .Center, children: [imageHolder, infoNode])
    }
}

class SynncTrackNode : ASCellNode {
    
    var imageNode : ASNetworkImageNode! {
        get {
            return self.contentNode.imageNode
        }
    }
    var iconNode : TrackStatusButton! {
        get {
            return self.contentNode.iconNode
        }
    }
    var infoNode : TrackInfoNode! {
        get {
            return self.contentNode.infoNode
        }
    }
    
    var contentNode : SynncTrackContentNode!
    
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
                
                self.iconNode?.state = state
                if self.interfaceState != ASInterfaceState.InHierarchy {
                    self.cellStateAnimationProgress = state == .Add ? 0 : 1
                } else {
                    self.cellStateAnimation.toValue = state == .Add ? 0 : 1
                }
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
        self.pop_removeAllAnimations()
        
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            let redT = POPTransition(cellStateAnimationProgress, startValue: 255, endValue: 236) / 255
            let greenT = POPTransition(cellStateAnimationProgress, startValue: 255, endValue: 89) / 255
            let blueT = POPTransition(cellStateAnimationProgress, startValue: 255, endValue: 26) / 255

            Async.main {
                self.contentNode.infoNode.backgroundColor = UIColor(red: redT, green: greenT, blue: blueT, alpha: 1)
            }
            
            self.contentNode.infoNode.cellStateAnimationProgress = cellStateAnimationProgress
        }
    }
    
    init(withIcon : Bool, withSource : Bool) {
        super.init()
        
        contentNode = SynncTrackContentNode(withIcon: withIcon, withSource: withSource)
        
        self.addSubnode(contentNode)
        
        self.backgroundColor = .whiteColor()
        self.selectionStyle = .None
    }
    
    func configureForTrack(track : SynncTrack) {
        var artistStr : String = ""
        for artist in track.artists {
            if artistStr == "" {
                artistStr = artist.name
            } else {
                artistStr += (" / " + artist.name)
            }
        }
        self.infoNode.artistNameNode.attributedString = NSMutableAttributedString(string: artistStr, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)])
        
        if let x = track.name {
            infoNode.trackNameNode.attributedString = NSMutableAttributedString(string: x, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)])
        }
        
        if let str = track.artwork_url, let artworkUrl = NSURL(string: str) {
            self.imageNode.URL = artworkUrl
        }
        
        if let x = track.source {
            self.infoNode.sourceNode?.image = UIImage(named: x.lowercaseString+"_active")
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(3, 10, 3, 10), child: contentNode)
    }
}

class TrackInfoNode : ASDisplayNode {
    
    var trackNameNode : ASTextNode!
    var artistNameNode : ASTextNode!
    var iconNode : TrackStatusButton!
    var sourceNode : ASImageNode!
    
    var displayIcon : Bool = false
    var displaySource : Bool = false
    
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            let track_redT = POPTransition(cellStateAnimationProgress, startValue: 117, endValue: 255) / 255
            let track_greenT = POPTransition(cellStateAnimationProgress, startValue: 117, endValue: 255) / 255
            let track_blueT = POPTransition(cellStateAnimationProgress, startValue: 117, endValue: 255) / 255
            
            let x = NSMutableAttributedString(attributedString: self.trackNameNode.attributedString!)
            x.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: track_redT, green: track_greenT, blue: track_blueT, alpha: 1), range: NSMakeRange(0, self.trackNameNode.attributedString!.length))
            self.trackNameNode.attributedString = x
            
            let artist_redT = POPTransition(cellStateAnimationProgress, startValue: 194, endValue: 225) / 255
            let artist_greenT = POPTransition(cellStateAnimationProgress, startValue: 194, endValue: 225) / 255
            let artist_blueT = POPTransition(cellStateAnimationProgress, startValue: 194, endValue: 225) / 255
            
            let y = NSMutableAttributedString(attributedString: self.artistNameNode.attributedString!)
            y.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: artist_redT, green: artist_greenT, blue: artist_blueT, alpha: 1), range: NSMakeRange(0, self.artistNameNode.attributedString!.length))
            self.artistNameNode.attributedString = y
            
        }
    }
    
    init(withIcon: Bool, withSource : Bool) {
        super.init()
        
        self.artistNameNode = ASTextNode()
        self.artistNameNode.layerBacked = true
        self.artistNameNode.maximumNumberOfLines = 1
        
        self.trackNameNode = ASTextNode()
        self.trackNameNode.layerBacked = true
        self.trackNameNode.spacingBefore = 7
        
        self.addSubnode(self.trackNameNode)
        self.addSubnode(self.artistNameNode)
        
        displayIcon = withIcon
        displaySource = withSource
        
        if displayIcon {
            self.iconNode = TrackStatusButton()
            self.addSubnode(iconNode)
            iconNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 14), ASRelativeDimension(type: .Points, value: 14))
        }
        
        if displaySource {
            self.sourceNode = ASImageNode()
            self.sourceNode.layerBacked = true
            self.sourceNode.preferredFrameSize = CGSizeMake(12, 12)
            self.sourceNode.spacingBefore = 8
            self.addSubnode(self.sourceNode)
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var iconSpec : ASStaticLayoutSpec!
        if displayIcon {
            iconSpec = ASStaticLayoutSpec(children: [self.iconNode])
            iconSpec.spacingAfter = 14
            iconSpec.spacingBefore = 7
        }
        
        
        let width = constrainedSize.max.width - (10 + (displayIcon ? (14+14+7) : 0))
        
        let bottomLineItems = displaySource ? [artistNameNode, sourceNode] : [artistNameNode]
        let bottomLine = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: bottomLineItems)
        bottomLine.alignSelf = .Stretch
        bottomLine.spacingBefore = 3
        bottomLine.spacingAfter = 12
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [trackNameNode, bottomLine])
        a.flexBasis = ASRelativeDimension(type: .Points, value: width)
        
        let b = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: displayIcon ? [a, iconSpec] : [a])
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 10, 0, 0), child: b)
    }
}