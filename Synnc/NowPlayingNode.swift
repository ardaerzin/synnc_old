//
//  NowPlayingNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/30/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class NowPlayingNode : ASDisplayNode {
 
    var volumeButton : ButtonNode!
    var trackNameNode : ASTextNode!
    var progressBar : ASDisplayNode!
    var trackProgress : CGFloat = -1
    
    
    var availableStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("availableStateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! NowPlayingNode).availableStateTransition
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! NowPlayingNode).availableStateTransition = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var availableStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("availableStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("availableStateAnimation")
                }
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.availableStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "availableStateAnimation")
                return x
            }
        }
    }
    var availableStateTransition : CGFloat = -1 {
        didSet {
            self.volumeButton.alpha = availableStateTransition
            self.submenuButton.alpha = availableStateTransition
            
            self.joinButton.alpha = 1-availableStateTransition
            
            let scale = POPTransition(availableStateTransition, startValue: 0.9, endValue: 1)
            POPLayerSetScaleXY(self.trackNameNode.layer, CGPointMake(scale, scale))
            POPLayerSetScaleXY(self.artistNameNode.layer, CGPointMake(scale, scale))
            
            let transition = POPTransition(availableStateTransition, startValue: -50, endValue: 0)
            POPLayerSetTranslationX(self.trackNameNode.layer, transition)
            POPLayerSetTranslationX(self.artistNameNode.layer, transition)
        }
    }
    var state : StreamControllerState = .Inactive {
        didSet {
            self.availableStateAnimation.toValue = state.rawValue
        }
    }
    
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! NowPlayingNode).stateTransition
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! NowPlayingNode).stateTransition = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.springSpeed = 10
                x.springBounciness = 0
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateTransition : CGFloat = 0 {
        didSet {
            transition = stateTransition + windowTransition
        }
    }
    var windowTransition : CGFloat = 0 {
        didSet {
            transition = stateTransition + windowTransition
        }
    }
    var transition : CGFloat = 0 {
        didSet {
            POPLayerSetTranslationY(self.layer, transition)
        }
    }
    
    lazy var trackAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 88/255, green: 88/255, blue: 88/255, alpha: 1), NSKernAttributeName : 0.5]
    }()
    
    var artistNameNode : ASTextNode!
    lazy var artistAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5]
    }()
    
    var border : ASDisplayNode!
    
    
//    var likeButton : ButtonNode!
    var submenuButton : ButtonNode!
    var joinButton : ButtonNode!
    
    override init(){
        super.init()
        
        border = ASDisplayNode()
        border.alignSelf = .Stretch
        border.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        border.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.2)
        self.addSubnode(border)
        
        volumeButton = ButtonNode()
        volumeButton.setImage(UIImage(named: "volume-on"), forState: .Selected)
        volumeButton.setImage(UIImage(named: "volume-off"), forState: .Normal)
        volumeButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50, 50))
        
        self.addSubnode(volumeButton)
        
        trackNameNode = ASTextNode()
        trackNameNode.maximumNumberOfLines = 2
        self.addSubnode(trackNameNode)
        
        artistNameNode = ASTextNode()
        self.addSubnode(artistNameNode)
        
        submenuButton = ButtonNode()
        submenuButton.setImage(UIImage(named: "submenu"), forState: .Selected)
        submenuButton.setImage(UIImage(named: "submenu"), forState: .Normal)
        submenuButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50, 50))
        self.addSubnode(submenuButton)
        
        progressBar = ASDisplayNode()
        progressBar.alignSelf = .Stretch
        progressBar.flexBasis = ASRelativeDimension(type: .Points, value: 3)
        progressBar.backgroundColor = UIColor.SynncColor()
        self.addSubnode(progressBar)
        
        joinButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        joinButton.setAttributedTitle(NSAttributedString(string: "JOIN", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: .Normal)
        joinButton.spacingAfter = 21
        
        joinButton.contentEdgeInsets = UIEdgeInsetsMake(12, 15, 12, 15)
        self.addSubnode(joinButton)
        
        self.shadowColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 0.5).CGColor
        self.shadowOpacity = 1
        self.shadowOffset = CGSizeMake(0, -1)
        self.shadowRadius = 2
        
        self.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1)
    }
    
    func configure(track : SynncTrack) {
        
        let volume = StreamManager.sharedInstance.playerManager.volume
        if volume > 0 {
            self.volumeButton.selected = true
        } else {
            self.volumeButton.selected = false
        }
        
        trackNameNode.attributedString = NSAttributedString(string: track.name, attributes: trackAttributes)
        artistNameNode.attributedString = NSAttributedString(string: track.artists.first!.name, attributes: artistAttributes)
        
//        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist.hasTrack(track) {
//            self.likeButton.selected = true
//        } else {
//            self.likeButton.selected = false
//        }
        
        self.setNeedsLayout()
    }
    
    func updateProgress(progress : CGFloat) {
        trackProgress = progress
        let x = POPTransition(progress, startValue: -progressBar.calculatedSize.width / 2, endValue: 0)
//        Async.main {
            POPLayerSetScaleX(progressBar.layer, progress)
            POPLayerSetTranslationX(progressBar.layer, x)
//        }
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        if trackProgress == -1 {
            self.updateProgress(0)
        }
        
        if availableStateTransition == -1 {
            availableStateTransition = 0
        }
    }
    
    override func layout() {
        super.layout()
        
        joinButton.position.y = self.calculatedSize.height / 2
        joinButton.position.x = self.calculatedSize.width - (joinButton.calculatedSize.width / 2) - 10
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let nameStack = ASStackLayoutSpec(direction: .Vertical, spacing: 1, justifyContent: .Start, alignItems: .Center, children: [trackNameNode, artistNameNode])
        nameStack.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 100)
        
        let stack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [volumeButton]), nameStack, ASStaticLayoutSpec(children: [submenuButton])])
        stack.flexGrow = true
        stack.alignSelf = .Stretch
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [border, stack, progressBar])
        x.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(constrainedSize.max)
        
        return ASStaticLayoutSpec(children: [joinButton, x])
    }
}