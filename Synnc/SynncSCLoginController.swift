//
//  SynncSCLoginController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUserManager
import AsyncDisplayKit
import pop

class SynncSCLoginController : SoundcloudLoginViewController {
    
    var loadingNode : SoundcloudLoginLoaderNode!
    
    deinit {
        print("deinit soundcloud view")
    }
    override func loadView() {
        super.loadView()
        
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
        
        loadingNode = SoundcloudLoginLoaderNode()
        
        self.view.addSubnode(loadingNode)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.loadingNode.frame = self.view.bounds
        
        self.loadingNode.measureWithSizeRange(ASSizeRangeMake(self.view.frame.size, self.view.frame.size))
    }
    
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsManager.sharedInstance.newScreen("Soundcloud Login")
    }
    override func didHide() {
        super.didHide()
        if oldScreen != nil {
            AnalyticsManager.sharedInstance.newScreen(oldScreen)
        }
    }
    
    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        
        let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        anim.completionBlock = {
            anim, finished in
            self.loadingNode.logoNode.stopAnimation()
        }
        self.loadingNode.pop_addAnimation(anim, forKey: "alpha")
        anim.toValue = 0
    }
}

class SoundcloudLoginLoaderNode : ASDisplayNode {
    
    var textNode : ASTextNode!
    var logoNode : AnimatedLogoNode!
    
    override init() {
        super.init()
        
        logoNode = AnimatedLogoNode(barCount: 5)
        logoNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40,40))
        
        textNode = ASTextNode()
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        textNode.attributedString = NSAttributedString(string: "Loading Soundcloud.com", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : 0.1, NSParagraphStyleAttributeName : p])
        
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(textNode)
        self.addSubnode(logoNode)
    }
    
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        self.logoNode.startAnimation()
    }
    
    override func layout() {
        super.layout()
        
        self.textNode.position.y = (self.calculatedSize.height / 3)
        self.logoNode.position.x = self.calculatedSize.width - self.logoNode.calculatedSize.width / 2
        self.logoNode.position.y = self.textNode.position.y
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 40), child: textNode)
//        textNode.flexBasis = ASRelativeDimensionMake(.Points, constrainedSize.max.width - 80)
        
        
        return ASStaticLayoutSpec(children: [a, logoNode])
//            ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [a, ASStaticLayoutSpec(children: [logoNode])])
    }
}