//
//  SettingsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/28/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox

class SettingsController : PopContentController {
    
    init(user : MainUser){
        let node = SettingsNode()
        super.init(node: node)
        
        node.closeButton.addTarget(self, action: Selector("hideController:"), forControlEvents: .TouchUpInside)
        
        self.screenNode = node
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let node = self.screenNode as! SettingsNode
        
        node.contentNode.disconnectSection.disconnectButton.addTarget(self, action: Selector("disconnectAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.contentNode.aboutSection.aboutUsButton.addTarget(self, action: Selector("aboutUsAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.contentNode.aboutSection.termsAndConditionsButton.addTarget(self, action: Selector("termsAndConditionsAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.contentNode.aboutSection.librariesButton.addTarget(self, action: Selector("librariesAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
//        node.contentNode.notificationsSection.followsNotificationCheckbox.addTarget(self, action: Selector("toggleFollowsNotification:"), forControlEvents: .TouchUpInside)
//        node.contentNode.notificationsSection.streamsNotificationCheckbox.addTarget(self, action: Selector("toggleStreamsNotification:"), forControlEvents: .TouchUpInside)
//        node.contentNode.notificationsSection.newUserNotificationCheckbox.addTarget(self, action: Selector("toggleNewUserNotification:"), forControlEvents: .TouchUpInside)
//        node.contentNode.notificationsSection.myStreamNotificationCheckbox.addTarget(self, action: Selector("toggleMyStreamNotification:"), forControlEvents: .TouchUpInside)
        
        node.contentNode.sourcesSection.soundcloudButton.addTarget(self, action: Selector("toggleSoundcloudLogin:"), forControlEvents: .TouchUpInside)
        node.contentNode.sourcesSection.spotifyButton.addTarget(self, action: Selector("toggleSpotifyLogin:"), forControlEvents: .TouchUpInside)
//        node.contentNode.sourcesSection.youtubeButton.addTarget(self, action: Selector("toggleYoutubeLogin:"), forControlEvents: .TouchUpInside)
//        node.contentNode.sourcesSection.googleplayButton.addTarget(self, action: Selector("toggleGoogleplayLogin:"), forControlEvents: .TouchUpInside)
//        node.contentNode.sourcesSection.groovesharkButton.addTarget(self, action: Selector("toggleGroovesharkLogin:"), forControlEvents: .TouchUpInside)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SettingsController {
    func disconnectAction(sender : ButtonNode) {
        
    }
    func aboutUsAction(sender : ButtonNode) {
        
    }
    func termsAndConditionsAction(sender : ButtonNode) {
        
    }
    func librariesAction(sender : ButtonNode) {
        
    }
}
extension SettingsController {
    func toggleFollowsNotification(sender : BFPaperCheckbox) {
        
    }
    func toggleStreamsNotification(sender : BFPaperCheckbox) {
        
    }
    func toggleNewUserNotification(sender : BFPaperCheckbox) {
        
    }
    func toggleMyStreamNotification(sender : BFPaperCheckbox) {
        
    }
}
extension SettingsController {
    func toggleSoundcloudLogin(sender : SourceButton) {
        if !sender.selected {
            if let u = Synnc.sharedInstance.user.soundcloud {
                let rect = CGRectInset(UIScreen.mainScreen().bounds, 25, 100)
                u.setLoginViewController(SynncSCLoginController(size: rect.size))
            }
            Synnc.sharedInstance.user.socialLogin(.Soundcloud)
        } else {
            Synnc.sharedInstance.user.socialLogout(.Soundcloud)
        }
        
    }
    func toggleSpotifyLogin(sender : SourceButton) {
        if !sender.selected {
            Synnc.sharedInstance.user.socialLogin(.Spotify)
        } else {
            Synnc.sharedInstance.user.socialLogout(.Spotify)
        }
    }
    func toggleYoutubeLogin(sender : SourceButton) {
        
    }
    func toggleGoogleplayLogin(sender : SourceButton) {
        
    }
    func toggleGroovesharkLogin(sender : SourceButton) {
        
    }
}