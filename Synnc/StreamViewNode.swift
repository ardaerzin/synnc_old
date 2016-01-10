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

class StreamViewNode : ParallaxNode {
    var chatbar : ChatBarNode!
    var chatNode : ASDisplayNode!
    var contentNode : StreamContentNode = StreamContentNode()
    
    init(chatNode : ASDisplayNode, chatbar : ChatBarNode) {
        let bgNode = StreamBackgroundNode()
        contentNode.backgroundColor = UIColor.whiteColor()
        super.init(backgroundNode: bgNode, contentNode: self.contentNode)
        self.chatbar = chatbar
        self.chatNode = chatNode
        self.chatNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        self.addSubnode(self.chatNode)
        self.addSubnode(chatbar)
    }
    
    override func layout() {
        super.layout()
        self.chatNode.position.y = self.calculatedSize.height / 2 + self.chatNode.calculatedSize.height
        self.chatbar.position.y = self.calculatedSize.height + self.chatbar.calculatedSize.height/2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [x, chatNode, chatbar])
    }
    
    func updateForState(createController : StreamCreateController? = nil, stream : Stream? = nil){
        if let vc = createController {
            
            self.mainScrollNode.parallaxContentNode.removeFromSupernode()
            self.mainScrollNode.parallaxContentNode = vc.contentNode
            self.mainScrollNode.parallaxContentNode.zPosition = 0
            self.mainScrollNode.backgroundNode.zPosition = 1
            
            self.mainScrollNode.setNeedsLayout()
        } else if let st = stream {
            if let cInd = st.currentSongIndex as? Int {
                let track = st.playlist.songs[cInd]
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