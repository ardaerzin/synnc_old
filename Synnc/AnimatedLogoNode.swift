//
//  AnimatedLogoNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/8/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop

class BarNode : ASDisplayNode {
    
    var needsAnimate : Bool = false
    var scaleAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("scaleAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! BarNode).progress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! BarNode).progress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var animation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("scaleAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.springBounciness = 0
                x.property = self.scaleAnimatableProperty
                self.pop_addAnimation(x, forKey: "scaleAnimation")
                return x
            }
        }
    }
    var isAnimating : Bool = false
    var progress : CGFloat = 0 {
        didSet {
            let xScale = max(0,POPTransition(progress, startValue: isAnimating ? 0.2 : 0, endValue: 1))
            let z = self.bounds.width * (1-xScale)
            POPLayerSetTranslationX(self.layer, z/2)
            POPLayerSetScaleX(self.layer, xScale)
        }
    }
    var seed : CGFloat = 0 {
        didSet {
            self.animation.completionBlock = {
                anim, finished in
                self.calculateNextSeed(self.seed)
                if self.isAnimating && self.seed != 0 {
                    self.seed = self.nextSeed
                } else {
                    if self.seed != -1 {
                        self.seed = self.nextSeed
                    } else {
                        self.pop_removeAnimationForKey("scaleAnimation")
                    }
                }
            }
            self.animation.toValue = seed
        }
    }
    var nextSeed : CGFloat = 0
    func calculateNextSeed(currentSeed : CGFloat){
        self.nextSeed = isAnimating ? CGFloat(Float(arc4random()) / Float(UINT32_MAX)) : -1
    }
    override func didLoad() {
        super.didLoad()
        self.progress = 0
    }
}

class AnimatedLogoNode : ASButtonNode {
    
    var bars : [BarNode] = []
    var spacers : [ASLayoutSpec] = []
    var barCount : Int = 15
    
    init(barCount : Int) {
        super.init()
        self.barCount = barCount
        
        for i in 0..<barCount {
            let n = BarNode()
            n.backgroundColor = UIColor.SynncColor()
            n.alignSelf = .Stretch
            n.flexBasis = ASRelativeDimension(type: .Percent, value: (1.0 / CGFloat(barCount)) * 0.5)
            
            self.bars.append(n)
            self.addSubnode(n)
            
            if i != barCount - 1 {
                let s = ASLayoutSpec()
                s.flexBasis = ASRelativeDimension(type: .Percent, value: (1.0 / CGFloat(barCount)) * 0.5)
                s.alignSelf = .Stretch
                self.spacers.append(s)
                
            }
        }
    }
    
    var isAnimating : Bool = false
    
    func getAnimationSeed() -> [CGFloat] {
        var seed : [CGFloat] = []
        for _ in bars {
            seed.append(CGFloat(Float(arc4random()) / Float(UINT32_MAX)))
        }
        return seed
    }
    func startAnimation(){
        var x = self.getAnimationSeed()
        for (index,bar) in bars.enumerate() {
            bar.isAnimating = true
            bar.seed = x[index]
        }
    }
    func stopAnimation() {
        for bar in bars {
            bar.isAnimating = false
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var children : [ASLayoutable] = []
        for i in 0..<barCount {
            children.append(bars[i])
            if i != barCount - 1 {
                children.append(spacers[i])
            }
        }
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: children)
        x.alignSelf = .Stretch
        return x
    }
}