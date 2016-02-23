//
//  StreamInProgressPopup.swift
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
import WCLNotificationManager

class StreamInProgressPopup : WCLPopupViewController {
    var node : StreamInProgressPopupNode!
    var callback : ((status : Bool) -> Void)?
    var playlist : SynncPlaylist!
    
    init(size: CGSize, playlist : SynncPlaylist? = nil) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Center), withShadow: true)
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
        
        self.playlist = playlist
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        let n = StreamInProgressPopupNode()
        self.node = n
        self.view.addSubnode(node)
        
        n.yesButton.addTarget(self, action: Selector("endCurrentStream:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        n.noButton.addTarget(self, action: Selector("dismissNotificationAccess:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.node.fetchData()
    }
    
    func endCurrentStream(sender : ButtonNode!) {
        if let activeStr = StreamManager.sharedInstance.activeStream {
            StreamManager.sharedInstance.stopStream(activeStr, completion: {
                [weak self]
                status in
                
                if self == nil {
                    return
                }
                
                self?.closeView(true)
                
                Synnc.sharedInstance.streamNavigationController.clearUserStreamController()
                Synnc.sharedInstance.streamNavigationController.displayStreamCreateController(self?.playlist)
                self?.playlist = nil
            })
        }
    }
    
    func dismissNotificationAccess(sender : ButtonNode) {
        self.closeView(true)
    }
    override func closeView(animated: Bool) {
        super.closeView(animated)
    }
    
}

class StreamInProgressPopupNode : ASDisplayNode {
    
    var messageNode : ASTextNode!
    var imageNode : ASNetworkImageNode!
    var infoNode : ASTextNode!
    
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    
    var user : WCLUser!
    
    override func fetchData() {
        super.fetchData()
        
        self.imageNode.image = Synnc.appIcon
    }
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        messageNode = ASTextNode()
        messageNode.alignSelf = .Stretch
        messageNode.attributedString = NSAttributedString(string: "Stream in Progress", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 20)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        infoNode = ASTextNode()
        infoNode.alignSelf = .Stretch
        infoNode.attributedString = NSAttributedString(string: "You need to end your current stream before starting a new one", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes])
        
        imageNode = ASNetworkImageNode()
        
        yesButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        yesButton.setAttributedTitle(NSAttributedString(string: "End Current Stream", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        yesButton.minScale = 1
        
        noButton = ButtonNode()
        noButton.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        noButton.minScale = 1
        
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