//
//  SynncLocationAuthVC.swift
//  Synnc
//
//  Created by Arda Erzin on 1/2/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLLocationManager
import AsyncDisplayKit

class SynncLocationAuthVC : WCLLocationManagerAuthVC {
    var node : ASDisplayNode!
    var callback : ((status : Bool) -> Void)?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        let node = LocationAuthNode()
        self.node = node
        self.view.addSubnode(node)
        
        node.yesButton.addTarget(self, action: Selector("getLocationAccess:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.noButton.addTarget(self, action: Selector("dismissLocationAccess:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
    }
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: self.node)
    }
    override func didHide() {
        super.didHide()
        AnalyticsManager.sharedInstance.newScreen(oldScreen)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.node {
            let x = n.measureWithSizeRange(ASSizeRangeMake(CGSizeZero, self.view.frame.size))
            if x.size != self.size {
                self.size = x.size
                self.configureView()
            }
        }
    }
    override func locationManagerAuthStatusChanged(notification: NSNotification) -> Int {
        let status = super.locationManagerAuthStatusChanged(notification)
        
        let success = status == 1 ? true : false
        self.callback?(status: success)
        
        return status
    }
    
    func getLocationAccess(sender : ButtonNode) {
        AnalyticsEvent.new(category: "LocationPopup", action: "buttonTap", label: "request", value: nil)
        WCLLocationManager.sharedInstance().requestAuth(false)
    }
    func dismissLocationAccess(sender : ButtonNode) {
        AnalyticsEvent.new(category: "LocationPopup", action: "buttonTap", label: "dismiss", value: nil)
        self.closeView(true)
    }
}

class LocationAuthNode : ASDisplayNode, TrackedView {
    
    var title: String! = "LocationAuthPopup"
    var messageNode : ASTextNode!
    var imageNode : ASImageNode!
    var infoNode : ASTextNode!
    
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    
        override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        messageNode = ASTextNode()
        messageNode.alignSelf = .Stretch
        messageNode.attributedString = NSAttributedString(string: "Synnc Your Location", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        infoNode = ASTextNode()
        infoNode.alignSelf = .Stretch
        infoNode.attributedString = NSAttributedString(string: "Only your city information will be shared to find other nearby users", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        imageNode = ASImageNode()
        imageNode.image = UIImage(named: "location-icon")
        
        yesButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        yesButton.setAttributedTitle(NSAttributedString(string: "Yes Please", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        noButton = ButtonNode()
        noButton.setAttributedTitle(NSAttributedString(string: "Nope", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        self.addSubnode(imageNode)
        self.addSubnode(messageNode)
        self.addSubnode(infoNode)
        self.addSubnode(yesButton)
        self.addSubnode(noButton)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer1 = ASLayoutSpec()
        spacer1.flexGrow = true
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let x = constrainedSize.max.width / 3
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(x, x))
        
        yesButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width / 2), ASRelativeDimension(type: .Points, value: 50))
        noButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width / 2), ASRelativeDimension(type: .Points, value: 50))
        
        let imageSpec = ASStaticLayoutSpec(children: [imageNode])
        imageSpec.spacingAfter = 20
        imageSpec.spacingBefore = 40
        
        let buttonSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [noButton]), ASStaticLayoutSpec(children: [yesButton])])
        
        let messageSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: messageNode)
        messageSpec.alignSelf = .Stretch
        let infoSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: infoNode)
        infoSpec.alignSelf = .Stretch
        infoSpec.spacingBefore = 20
        infoSpec.spacingAfter = 50
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ imageSpec, messageSpec, infoSpec, buttonSpec])
    }
}