//
//  StreamVCNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit
import Cloudinary

class StreamHeaderNode : PagerHeaderNode {
    
    var gradientLayer : CAGradientLayer!
    var streamTitleNode : ASTextNode!
    var shareButton : ButtonNode!
    var toggleButton : ToggleButton!
    
    init(){
        super.init(backgroundColor: nil)
        streamTitleNode = ASTextNode()
        self.addSubnode(streamTitleNode)
        
        shareButton = ButtonNode()
        shareButton.setImage(UIImage(named: "share-icon"), forState: .Normal)
        self.addSubnode(shareButton)
        
        toggleButton = ToggleButton()
        toggleButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        self.addSubnode(toggleButton)
    }
    
    
    override func layout() {
        super.layout()
        streamTitleNode.position.x = titleHolder.position.x
        streamTitleNode.position.y = titleHolder.position.y + 10
        
        shareButton.position.x = self.calculatedSize.width - (shareButton.calculatedSize.width / 2) - 20
        shareButton.position.y = self.calculatedSize.height / 2
        
        pageControl.position.y = streamTitleNode.position.y + (streamTitleNode.calculatedSize.height / 2) + 20
        
        self.toggleButton.position = self.leftButtonHolder.position
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [pageControl, leftButtonHolder, rightButtonHolder, titleHolder, streamTitleNode, shareButton, toggleButton])
    }
}

class StreamImageHeader : ASDisplayNode {
    
    var imageId : String!
    var imageNode : ASNetworkImageNode!
    var tintNode : ASDisplayNode!
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        self.addSubnode(imageNode)
        
        tintNode = ASDisplayNode()
        tintNode.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.addSubnode(tintNode)
        
        self.backgroundColor = .clearColor()
        
        self.clipsToBounds = true
    }
    
    override func fetchData() {
        
        if imageId == nil {
            return
        }
        
        let transformation = CLTransformation()
        
        transformation.width = self.imageNode.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.imageNode.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        if let x = _cloudinary.url(imageId, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            print("image url:", url)
            self.imageNode.URL = url
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1) , ASRelativeDimension(type: .Percent, value: 1))
        
        tintNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1) , ASRelativeDimension(type: .Percent, value: 1))
        
        return ASStaticLayoutSpec(children: [imageNode, tintNode])
    }
    
    func updateScrollPosition(position : CGFloat) {
        
        let shit = max(0, -position)
        let progress = POPProgress(shit, startValue: 0, endValue: self.calculatedSize.height - 100)
        
        let transition = POPTransition(progress, startValue: (self.calculatedSize.height / 2) - 50, endValue: 0)
        
        let x = -position - (self.calculatedSize.height - 100)
        let scale = max(1, (self.calculatedSize.height + x) / self.calculatedSize.height)
        
        POPLayerSetTranslationY(self.layer, shit)
        POPLayerSetTranslationY(imageNode.layer, transition)
        POPLayerSetTranslationY(tintNode.layer, transition)
        
        POPLayerSetScaleXY(imageNode.layer, CGPointMake(scale, scale))
        POPLayerSetScaleXY(tintNode.layer, CGPointMake(scale, scale))
        
        if progress > 1 {
            self.clipsToBounds = false
        } else {
            self.clipsToBounds = true
        }
        
    }
}

class StreamVCNode : PagerBaseControllerNode {
    
    var state : StreamControllerState! = .Inactive {
        didSet {
            stateAnimation.toValue = state.rawValue
            nowPlayingArea.state = state
        }
    }
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamVCNode).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamVCNode).stateAnimationProgress = values[0]
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
    var stateAnimationProgress : CGFloat = 0 {
        didSet {
            
//            let transition = POPTransition(stateAnimationProgress, startValue: 0, endValue: -nowPlayingArea.calculatedSize.height)
//            POPLayerSetTranslationY(nowPlayingArea.layer, transition)
//            let a = POPTransition(serverCheckStatusAnimationProgress, startValue: 1, endValue: 0)
//            self.buttonHolder.alpha = a
            //            self.legal.alpha = a
            
//            self.spinnerNode.alpha = 1-a
        }
    }
    
    
    var nowPlayingArea : NowPlayingNode!
    var imageHeader : StreamImageHeader!
    var imageNode : ASNetworkImageNode! {
        get {
            return imageHeader.imageNode
        }
    }
    var scrollPosition : CGFloat! {
        didSet {
            imageHeader.updateScrollPosition(scrollPosition)
        }
    }
    
    init() {
        
        let header = StreamHeaderNode()
        super.init(header: header, pager: nil)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        imageHeader = StreamImageHeader()
        self.addSubnode(imageHeader)
        
        nowPlayingArea = NowPlayingNode()
        self.addSubnode(nowPlayingArea)
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.bringSubviewToFront(self.headerNode.view)
        self.view.bringSubviewToFront(self.nowPlayingArea.view)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if scrollPosition == nil {
            scrollPosition = 0
        }
    }
    
    override func layout() {
        super.layout()
        imageHeader.position.y = (imageHeader.calculatedSize.width / 2) - imageHeader.calculatedSize.width + 100
        
        nowPlayingArea.position.y = self.calculatedSize.height - (nowPlayingArea.calculatedSize.height / 2)
    }
    
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let x = super.layoutSpecThatFits(constrainedSize)
        
        self.imageHeader.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, constrainedSize.max.width))
        
        nowPlayingArea.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, 70))
        
        return ASStaticLayoutSpec(children: [x, imageHeader, nowPlayingArea])
    }
}