//
//  MeController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/11/15.
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

class MeController : TabItemController {
    override var identifier : String! {
        return "MeController"
    }
    override var imageName : String! {
        return "user"
    }
    override init(){
        let node = MeNode(user: Synnc.sharedInstance.user)
        super.init(node: node)
        node.underTabbar = true
        node.delegate = self
        self.statusBarDisplayed = false
        node.headerNode.closeButton.alpha = 0
        node.headerNode.closeButton.enabled = false
        node.mainScrollNode.view.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 1500)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userProfileInfoChanged:"), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        print(Synnc.sharedInstance.user)
        
        node.editButton.addTarget(self, action: Selector("toggleEditMode:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.inboxButton.addTarget(self, action: Selector("toggleInbox:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.settingsButton.addTarget(self, action: Selector("toggleSettings:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenNode.backgroundColor = UIColor.whiteColor()
    }
    
    var _inboxController : InboxController!
    var inboxController : InboxController! {
        get {
            if _inboxController == nil {
                _inboxController = InboxController()
            }
            return _inboxController
        }
    }
    var _settingsController : SettingsController!
    var settingsController : SettingsController! {
        get {
            if _settingsController == nil {
                _settingsController = SettingsController(user: Synnc.sharedInstance.user)
            }
            return _settingsController
        }
    }
    var _popContentController : PopController!
    var popContentController : PopController! {
        get {
            if _popContentController == nil {
                _popContentController = PopController()
            }
            return _popContentController
        }
    }
    var selectedPopoverButton : ButtonNode!
    
}

extension MeController {
    func toggleEditMode(sender : ButtonNode) {
        if let popover = self.selectedPopoverButton {
            popover.selected = !popover.selected
            self.hidePopover()
        }
    }
    func toggleSettings(sender : ButtonNode) {
        sender.selected = !sender.selected
        togglePopover(sender, contentController: self.settingsController)
    }
    func toggleInbox(sender : ButtonNode){
        sender.selected = !sender.selected
        togglePopover(sender, contentController: self.inboxController)
    }
    
    func togglePopover(sender : ButtonNode, contentController : PopContentController){
        if sender.selected {
            if let selected = selectedPopoverButton where selected != sender {
                selected.selected = false
            }
            self.selectedPopoverButton = sender
        }
        self.popContentController.screenNode.arrowPosition = sender.position
        
        if sender.selected {
            
            if !self.popContentController.displayed {
                self.addChildViewController(self.popContentController)
                if self.popContentController.view.frame == CGRectZero {
                    self.popContentController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 50 - 30)
                }
                self.popContentController.screenNode.displayAnimation.completionBlock = {
                    anim, finished in
                    self.popContentController.screenNode.pop_removeAnimationForKey("displayAnimation")
                }
                self.screenNode.addSubnode(self.popContentController.screenNode)
                self.popContentController.didMoveToParentViewController(self)
                self.popContentController.screenNode.displayAnimation.toValue = 1
                self.popContentController.displayed = true
            }
            
            self.popContentController.setContent(contentController)
            
        } else {
            hidePopover()
        }
    }
    
    func hidePopover(){
        self.popContentController.screenNode.displayAnimation.completionBlock = {
            anim, finished in
            self.popContentController.willMoveToParentViewController(nil)
            self.popContentController.screenNode.removeFromSupernode()
            self.popContentController.removeFromParentViewController()
            self.popContentController.screenNode.pop_removeAnimationForKey("displayAnimation")
        }
        self.popContentController.screenNode.displayAnimation.toValue = 0
        self.popContentController.displayed = false
    }
}

extension MeController : ParallaxNodeDelegate {
    func imageForBackground() -> AnyObject? {
        if let provider = Synnc.sharedInstance.user.provider, let type = WCLUserLoginType(rawValue: provider), let url = Synnc.sharedInstance.user.avatarURL(type, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width), scale: UIScreen.mainScreen().scale) {
            print(url.absoluteString)
            return url
        }
        return nil
    }
    func gradientImageName() -> String? {
        return "imageGradient"
    }
    func headerButtons() -> [ButtonNode] {
        return []
    }
}

extension MeController {
    func userProfileInfoChanged(notification: NSNotification) {
            if let menode = self.screenNode as? MeNode {
                menode.updateForUser(Synnc.sharedInstance.user)
            }
        
    }
}