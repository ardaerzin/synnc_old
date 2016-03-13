//
//  FirstLoginPopupVC.swift
//  Synnc
//
//  Created by Arda Erzin on 1/9/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLUserManager
import SwiftyJSON

class FirstLoginPopupVC : WCLPopupViewController {
    var node : FirstLoginPopupNode!
    var callback : ((status : Bool) -> Void)?
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Center), withShadow: true)
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        let n = FirstLoginPopupNode()
        self.node = n
        self.view.addSubnode(node)
        
        n.yesButton.addTarget(self, action: Selector("profileAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        n.noButton.addTarget(self, action: Selector("dismissLocationAccess:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.node.fetchData()
    }
    func profileAction(sender : ButtonNode) {
        AnalyticsEvent.new(category: "InitialPopup", action: "buttonTap", label: "profile", value: nil)
    }
    func dismissLocationAccess(sender : ButtonNode) {
        AnalyticsEvent.new(category: "InitialPopup", action: "buttonTap", label: "dismiss", value: nil)
        self.closeView(true)
    }
    override func closeView(animated: Bool) {
        super.closeView(animated)
        
        Synnc.sharedInstance.socket!.emit("user:update", [ "id" : Synnc.sharedInstance.user._id, "generatedUsername" : false])
        
    }
    
}

class FirstLoginPopupNode : ASDisplayNode, TrackedView {
    
    var title : String! = "FirstLoginPopup"
    var messageNode : ASTextNode!
    var imageNode : ASNetworkImageNode!
    var infoNode : ASTextNode!
    
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    
    var user : WCLUser!
    
    override func fetchData() {
        super.fetchData()
        
        if let u = Synnc.sharedInstance.user, let url = u.avatarURL(WCLUserLoginType(rawValue: u.provider)!, frame: CGRect(origin: CGPointZero, size: self.imageNode.calculatedSize), scale: UIScreen.mainScreen().scale) {
            self.imageNode.URL = url
            let paragraphAtrributes = NSMutableParagraphStyle()
            paragraphAtrributes.alignment = .Center
            if let name = u.username {
                messageNode.attributedString = NSAttributedString(string: "@"+name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 20)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
            }
        }
    }
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        messageNode = ASTextNode()
        messageNode.alignSelf = .Stretch
        
        infoNode = ASTextNode()
        infoNode.alignSelf = .Stretch
        infoNode.attributedString = NSAttributedString(string: "Welcome To Synnc. If you don't like your username or photo, you can edit them from the profile section.", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        imageNode = ASNetworkImageNode()
        
        yesButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        yesButton.setAttributedTitle(NSAttributedString(string: "Go To Profile", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        noButton = ButtonNode()
        noButton.setAttributedTitle(NSAttributedString(string: "Skip", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
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