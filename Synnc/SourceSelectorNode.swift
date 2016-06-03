//
//  SourceSelectorNode.swift
//  Synnc
//
//  Created by Arda Erzin on 2/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLNotificationManager

protocol SourceSelectorDelegate {
    func sourceSelector(didUpdateSource source: SynncExternalSource)
    func sourceSelector(canSelectSource source: SynncExternalSource) -> Bool
}

class SourceButton : ButtonNode {
    var normalImage : UIImage!
    var selectedImage : UIImage!
    var source : SynncExternalSource!
    
    init(source : SynncExternalSource) {
        
        super.init()
        self.source = source
        let normalImage = UIImage(named: source.rawValue.lowercaseString + "_inactive")!
        let selectedImage = UIImage(named: source.rawValue.lowercaseString + "_active")!
        
        setImage(normalImage, forState: ASControlState.Normal)
        setImage(selectedImage, forState: ASControlState.Highlighted)
        
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        
        self.imageNode.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func changedSelected() {
        super.changedSelected()
        
        let img = self.selected ? self.selectedImage : self.normalImage
        self.setImage(img, forState: ASControlState.Normal)
    }
}

class SourceSelectionNode : ASDisplayNode {
    
    var delegate : SourceSelectorDelegate?
    var titleNode : ASTextNode!
    var sourceButtons : [SourceButton] = []
    var doneButton : ButtonNode!
    
    var displayStatus : Bool = false {
        didSet {
            if displayStatus != oldValue {
                self.sourceSelectionAnimation.toValue = displayStatus ? 1 : 0
            }
        }
    }

    var sourceSelectionAnimationProgress : CGFloat = 0 {
        didSet {
            let tranlation = POPTransition(sourceSelectionAnimationProgress, startValue: 0, endValue: self.calculatedSize.height)
            POPLayerSetTranslationY(self.layer, tranlation)
        }
    }
    
    init(sources: [String]) {
        super.init()
        
        for source in sources {
            let src = SynncExternalSource(rawValue: source.capitalizedString)
            if let x = src {
                let button = SourceButton(source: x)
                
                button.addTarget(self, action: #selector(SourceSelectionNode.didSelectSource(_:)), forControlEvents: .TouchUpInside)
                self.sourceButtons.append(button)
                
                self.addSubnode(button)
            }
        }
        
        titleNode = ASTextNode()
        titleNode.spacingAfter = 10
        titleNode.attributedString = NSAttributedString(string: "Select a music provider", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 16)!, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.6), NSKernAttributeName : -0.09])
        
        self.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        self.shadowOffset = CGSizeMake(0,1)
        self.shadowOpacity = 1
        self.shadowRadius = 2
        
        doneButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        doneButton.backgroundColor = UIColor.SynncColor()
        doneButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50,30))
        doneButton.setAttributedTitle(NSAttributedString(string: "Done", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : -0.09]), forState: .Normal)
        doneButton.alpha = 0
        doneButton.addTarget(self, action: #selector(SourceSelectionNode.closeSelector(_:)), forControlEvents: .TouchUpInside)
        self.addSubnode(titleNode)
        self.addSubnode(doneButton)
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func didSelectSource(sender: SourceButton) {
        
        AnalyticsEvent.new(category: "searchSourceSelect", action: "sourceSelect", label: sender.source.rawValue, value: nil)
        
        let canSelect = self.delegate?.sourceSelector(canSelectSource: sender.source)
        if canSelect == nil || !canSelect! {
            if sender.source == .Spotify {
                
                SynncNotification(body: ("You need to login to Spotify first.", "login"), image: "notification-access") {
                    notif in
                    
                    Synnc.sharedInstance.user.socialLogin(.Spotify)
                }.addToQueue()
            } else if sender.source == .AppleMusic {
                SynncNotification(body: ("You need to login to Apple Music first.", "login"), image: "notification-access") {
                    notif in
                    
                    Synnc.sharedInstance.user.socialLogin(.AppleMusic)
                }.addToQueue()
            }
            
            
            return
        }
        
        sender.selected = true
        
        for button in self.sourceButtons {
            if button != sender {
                button.selected = false
            }
        }
        
        self.delegate?.sourceSelector(didUpdateSource: sender.source)
        self.closeSelector(sender)
    }
    
    func closeSelector(sender: ButtonNode) {
        self.toggle()
        AnalyticsEvent.new(category: "ui_action", action: "buttonTap", label: "closeSourceSelector", value: nil)
    }
    
    func toggle(selectedSource: SynncExternalSource? = nil){
        if let ss = selectedSource {
            
            for button in self.sourceButtons {
                if button.source == ss {
                    button.selected = true
                }
            }
        }
        self.displayStatus = !self.displayStatus
    }
    
    override func layout() {
        super.layout()
        
        doneButton.position.y = self.calculatedSize.height - (doneButton.calculatedSize.height / 2) - 5
        doneButton.position.x = self.calculatedSize.width - (doneButton.calculatedSize.width / 2) - 10
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Center, alignItems: .Center, children: self.sourceButtons)
        
        self.titleNode.spacingBefore = 25
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 10, justifyContent: .Start, alignItems: .Center, children: [ self.titleNode, a])
        
        return ASOverlayLayoutSpec(child: stack, overlay: ASStaticLayoutSpec(children: [doneButton]))
    }
}

extension SourceSelectionNode {
    var sourceSelectionAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("sourceSelectionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SourceSelectionNode).sourceSelectionAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SourceSelectionNode).sourceSelectionAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var sourceSelectionAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("sourceSelectionAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("sourceSelectionAnimation")
                }
                x.springBounciness = 2
                x.property = self.sourceSelectionAnimatableProperty
                self.pop_addAnimation(x, forKey: "sourceSelectionAnimation")
                return x
            }
        }
    }
}