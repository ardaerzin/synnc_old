//
//  NotReachablePopup.swift
//  Synnc
//
//  Created by Arda Erzin on 4/11/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop

class NotReachablePopup : WCLPopupViewController {
    
    var screenNode : NotReachablePopupNode!
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Center), withShadow: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        self.draggable = true
        self.dismissable = false
        
        let node = NotReachablePopupNode()
        node.yesButton.addTarget(self, action: #selector(NotReachablePopup.tryAgain(_:)), forControlEvents: .TouchUpInside)
        self.screenNode = node
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            let x = n.measureWithSizeRange(ASSizeRangeMake(CGSizeZero, self.view.frame.size))
            if x.size != self.size {
                self.size = x.size
                screenNode.view.frame = CGRect(origin: CGPointZero, size: self.size)
                self.configureView()
            }
        }
    }
    
    
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: screenNode)
    }
    override func didHide() {
        super.didHide()
        if oldScreen != nil {
            AnalyticsManager.sharedInstance.newScreen(oldScreen)
        }
    }
    
    func tryAgain(sender: AnyObject) {
        Synnc.sharedInstance.tryConnect()
        self.closeView(true)
    }
}

class NotReachablePopupNode : ASDisplayNode, TrackedView {
    
    var title: String! = "NotCompatiblePopup"
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
        messageNode.attributedString = NSAttributedString(string: "Out of Synnc", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        infoNode = ASTextNode()
        infoNode.alignSelf = .Stretch
        infoNode.attributedString = NSAttributedString(string: "It looks like you are unable to reach to our servers. Please check your connection.", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        imageNode = ASImageNode()
        imageNode.image = Synnc.appIcon
        
        yesButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        yesButton.setAttributedTitle(NSAttributedString(string: "Reconnect", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        self.addSubnode(imageNode)
        self.addSubnode(messageNode)
        self.addSubnode(infoNode)
        self.addSubnode(yesButton)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer1 = ASLayoutSpec()
        spacer1.flexGrow = true
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let x = constrainedSize.max.width / 3
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(x, x))
        
        yesButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width / 2), ASRelativeDimension(type: .Points, value: 50))
        
        let imageSpec = ASStaticLayoutSpec(children: [imageNode])
        imageSpec.spacingAfter = 20
        imageSpec.spacingBefore = 40
        
        let buttonSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [yesButton])])
        buttonSpec.spacingAfter = 20
        
        let messageSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: messageNode)
        messageSpec.alignSelf = .Stretch
        let infoSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20), child: infoNode)
        infoSpec.alignSelf = .Stretch
        infoSpec.spacingBefore = 20
        infoSpec.spacingAfter = 50
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ imageSpec, messageSpec, infoSpec, buttonSpec])
    }
}