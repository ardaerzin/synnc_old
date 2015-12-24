//
//  TabNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/9/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class TabbarButton : ButtonNode {
    var normalImage : UIImage!
    var selectedImage : UIImage!
    var item : TabItem!
    
    init(item : TabItem) {
        
        super.init()
        
        self.item = item
        
        let normalImage = UIImage(named: item.imageName)!
        let selectedImage = UIImage(named: item.imageName+"_selected")!
        
        setImage(normalImage, forState: ASButtonStateNormal)
        setImage(selectedImage, forState: ASButtonStateHighlighted)
        
        self.normalImage = normalImage
        self.selectedImage = selectedImage
    }
    
    override func changedSelected() {
        super.changedSelected()
        
        let img = self.selected ? self.selectedImage : self.normalImage
        self.setImage(img, forState: ASButtonStateNormal)
    }
}

protocol TabbarDelegate {
    func willSetTabItem(item : TabItem)
    func didSetTabItem(item : TabItem)
}
class TabNode : ASDisplayNode {
    
    var delegate : TabbarDelegate?
    var blurView : UIVisualEffectView!
    var tabbarButtons : [TabbarButton] = []
    var tabbarNodes : [ASLayoutable] = []
    var tabbarItems : [TabItem] = []

    var initiallyLoaded : Bool = false    
    init(tabbarItems : [TabItem]) {
        super.init()
        self.alignSelf = .Stretch
        self.tabbarItems = tabbarItems
        
        for (index,item) in tabbarItems.enumerate() {
            
            let button = TabbarButton(item: item)
            self.tabbarButtons.append(button)
            button.preferredFrameSize = CGSizeMake(50, 50)
            button.addTarget(self, action: Selector("sex:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
            self.addSubnode(button)
            
            let x = (UIScreen.mainScreen().bounds.width - CGFloat(tabbarItems.count * 50)) / CGFloat(tabbarItems.count + 1)
            let spacer = ASLayoutSpec()
            spacer.flexBasis = ASRelativeDimension(type: .Points, value: x)
            let s = ASStaticLayoutSpec(children: [button])
            
            tabbarNodes.append(spacer)
            tabbarNodes.append(s)
            
            if index == tabbarItems.count - 1 {
                let spacer = ASLayoutSpec()
                spacer.flexBasis = ASRelativeDimension(type: .Points, value: x)
                tabbarNodes.append(spacer)
            }
        }
    }
    var selectedTabItem : TabItem? {
        get {
            return self.selectedButton?.item
        }
    }
    var selectedButton : TabbarButton! {
        willSet {
            if newValue != selectedButton  {
                selectedButton?.selected = false
                newValue?.selected = true
                self.delegate?.willSetTabItem(newValue!.item)
            }
        }
    }
    func sex(sender : TabbarButton) {
        self.selectedButton = sender
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: tabbarNodes)
        x.alignSelf = .Stretch
        
        return x
    }
    
    override func layout() {
        super.layout()
        self.blurView.frame = self.bounds
    }
    override func layoutDidFinish() {
        super.layoutDidFinish()
        if !initiallyLoaded {
            initiallyLoaded = true
            self.selectedButton = self.tabbarButtons.first!
        }
    }
    override func didLoad() {
        if self.blurView == nil {
            self.blurView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
            self.view.addSubview(self.blurView)
            self.view.sendSubviewToBack(self.blurView)
        }
    }
}