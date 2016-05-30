//
//  UserProfilePopup.swift
//  Synnc
//
//  Created by Arda Erzin on 4/2/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop
import WCLUserManager
import WCLNotificationManager

class UserProfilePopup : WCLPopupViewController {
    
    var screenNode : ProfileCardNode!
    var user : WCLUser?
    
    init(size: CGSize, user : WCLUser) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.user = user
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Center), withShadow: true)
        self.dismissable = true
        self.tapToDismiss = true
        self.screenNode.updateForUser(user)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        self.draggable = true
        self.dismissable = false
        
        let node = ProfileCardNode()
        node.usernameNode.userInteractionEnabled = false
        self.screenNode = node
        self.screenNode.followButton.addTarget(self, action: #selector(UserProfilePopup.followUser(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            let x = n.measureWithSizeRange(ASSizeRangeMake(CGSizeZero, CGSizeMake(275, UIScreen.mainScreen().bounds.height)))
            
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
        
        self.screenNode.imageNode.setNeedsLayout()
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: screenNode)
    }
    override func didHide() {
        super.didHide()
        if oldScreen != nil {
            AnalyticsManager.sharedInstance.newScreen(oldScreen)
        }
    }
    
    func followUser(sender: AnyObject) {
        SynncNotification(body: ("Follow feature is coming soon.", "coming soon"), image: "notification-warning").addToQueue()
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "user_follow", value: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
}