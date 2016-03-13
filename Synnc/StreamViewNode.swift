//
//  StreamViewNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/6/16.
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
import WCLUserManager

class StreamViewNode : ParallaxNode, TrackedView {
    
    var title: String! = "StreamView"
    var chatbar : ChatBarNode!
    var chatNode : ASDisplayNode!
    var contentNode : StreamContentNode!
    var state : StreamVCState = .Hidden {
        didSet {
            if state != oldValue {
                if state.rawValue >= StreamVCState.Syncing.rawValue && state.rawValue < StreamVCState.Finished.rawValue {
                    buttonUpdateAnimation.toValue = 1
                } else {
                    buttonUpdateAnimation.toValue = 0
                }
            }
        }
    }
    
    var buttonUpdateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamViewNode).buttonUpdateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamViewNode).buttonUpdateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var buttonUpdateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("buttonUpdateAnimation") as? POPBasicAnimation {
                return anim
            } else {
                let x = POPBasicAnimation()
                x.duration = 0.2
                x.property = self.buttonUpdateAnimatableProperty
                self.pop_addAnimation(x, forKey: "buttonUpdateAnimation")
                return x
            }
        }
    }
    var buttonUpdateAnimationProgress : CGFloat = 0 {
        didSet {
            self.shareStreamButton.alpha = buttonUpdateAnimationProgress
            self.stopStreamButton.alpha = buttonUpdateAnimationProgress
        }
    }
    
    lazy var shareStreamButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "SHARE", selectedTitleString: "SHARE", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
    }()
    lazy var stopStreamButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "STOP STREAM", selectedTitleString: "STOP STREAM", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
    }()
    
    var buttons : [ButtonNode] {
        get {
            return [stopStreamButton, shareStreamButton]
        }
    }
    
    init(chatNode : ASDisplayNode?, chatbar : ChatBarNode?, content : StreamContentNode) {
        let bgNode = StreamBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: content)
        self.contentNode = content
        self.chatbar = chatbar
        self.chatNode = chatNode
        self.chatNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.headerNode.buttons = buttons
        self.addSubnode(self.chatNode)
        self.addSubnode(self.chatbar)
        
        shareStreamButton.alpha = 0
        stopStreamButton.alpha = 0
    }
    
    override func layout() {
        super.layout()
        if let _ = self.chatNode {
            self.chatNode.position.y = self.calculatedSize.height / 2 + self.chatNode.calculatedSize.height
            self.chatbar.position.y = self.calculatedSize.height + self.chatbar.calculatedSize.height/2
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        if let _ = chatNode {
            return ASStaticLayoutSpec(children: [x, chatNode, chatbar])
        } else {
            return ASStaticLayoutSpec(children: [x])
        }
    }
    
    func updateForState(createController : StreamCreateController? = nil, stream : Stream? = nil){
        if let vc = createController {
            
            self.mainScrollNode.parallaxContentNode.removeFromSupernode()
            self.mainScrollNode.parallaxContentNode = vc.contentNode
            self.mainScrollNode.parallaxContentNode.zPosition = 0
            self.mainScrollNode.backgroundNode.zPosition = 1
            
            self.mainScrollNode.setNeedsLayout()
        } else if let st = stream {
            if let cInd = st.currentSongIndex {
                let track = st.playlist.songs[cInd as Int]
                if let bg = self.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                    bg.updateForTrack(track)
                }
            }
            self.mainScrollNode.parallaxContentNode.removeFromSupernode()
            self.contentNode.alpha = 0
            self.mainScrollNode.parallaxContentNode = self.contentNode
            self.contentNode.displayAnimation.completionBlock = {
                anim, finished in
                self.contentNode.pop_removeAnimationForKey("displayAnimation")
                self.mainScrollNode.view.scrollEnabled = true
            }
            self.contentNode.displayAnimation.toValue = 1
            if let bg = self.mainScrollNode.backgroundNode as? StreamBackgroundNode {
                bg.configure(st)
                bg.state = .ReadyToPlay
            }
            
            self.mainScrollNode.setNeedsLayout()
        }
    }
}