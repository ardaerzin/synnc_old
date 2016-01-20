//
//  SettingsNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/30/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox

class SettingsNode : ASDisplayNode {
    
    var headerNode : ASTextNode!
    var separator : ASDisplayNode!
    var closeButton : ButtonNode!
    var contentNode : SettingsContentNode!
    
    let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    
    override init() {
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.headerNode = ASTextNode()
        self.headerNode.attributedString = NSAttributedString(string: "Settings", attributes: self.attributes)
        self.headerNode.spacingBefore = 22
        self.headerNode.flexGrow = true
        
        self.closeButton = ButtonNode(normalColor: .clearColor(), selectedColor: .clearColor())
        self.closeButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        self.closeButton.setImage(UIImage(named: "close")?.resizeImage(usingWidth: 12), forState: ASControlState.Normal)
        self.closeButton.alpha = 0.6
        
        self.separator = ASDisplayNode()
        self.separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        self.separator.alignSelf = .Stretch
        self.separator.backgroundColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        
        self.contentNode = SettingsContentNode()
        self.contentNode.flexGrow = false
        self.contentNode.clipsToBounds = true
        self.contentNode.alignSelf = .Stretch
        
        self.addSubnode(self.headerNode)
        self.addSubnode(self.closeButton)
        self.addSubnode(self.separator)
        self.addSubnode(self.contentNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let buttonSpec = ASStaticLayoutSpec(children: [self.closeButton])
        buttonSpec.spacingAfter = 18
        
        let headerSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.headerNode, buttonSpec])
        headerSpec.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        headerSpec.alignSelf = .Stretch
        
        if constrainedSize.max.height.isFinite {
            contentNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - (50 + 1/UIScreen.mainScreen().scale) ))
        }
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [headerSpec, separator, ASStaticLayoutSpec(children: [contentNode])])
    }
}

class SettingsContentNode : ASScrollNode {
    
    var sourcesSection : SettingsSourcesNode!
    var securitySection : SecurityPrivacyNode!
    var notificationsSection : NotificationsNode!
    var aboutSection : AboutNode!
    var feedbackSection : FeedbackSectionNode!
    var disconnectSection : DisconnectSectionNode!
    var endLine : ASDisplayNode!
    
        override init() {
        super.init()
        
        self.sourcesSection = SettingsSourcesNode()
//        self.securitySection = SecurityPrivacyNode()
        self.notificationsSection = NotificationsNode()
        self.aboutSection = AboutNode()
        self.feedbackSection = FeedbackSectionNode()
        self.disconnectSection = DisconnectSectionNode()
        
        self.endLine = ASDisplayNode()
        self.endLine.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        self.endLine.backgroundColor = UIColor.lightGrayColor()
        self.endLine.alignSelf = .Stretch
        
        self.view.delaysContentTouches = false
        
        self.addSubnode(self.sourcesSection)
        self.addSubnode(self.notificationsSection)
        self.addSubnode(self.aboutSection)
        self.addSubnode(self.feedbackSection)
        self.addSubnode(self.disconnectSection)
        
        self.addSubnode(self.endLine)
    }
    
    override func layout() {
        super.layout()
        
        self.view.contentSize = CGSizeMake(calculatedSize.width, self.endLine.calculatedSize.height / 2 + self.endLine.position.y)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 32, justifyContent: .Start, alignItems: .Start, children: [sourcesSection, notificationsSection, aboutSection, feedbackSection, disconnectSection, endLine])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 22, 0, 22), child: vStack)
    }
    
}

extension BFPaperCheckbox {
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let rect = CGRectInset(self.bounds, -5, -5)
        return CGRectContainsPoint(rect, point)
    }
}

class SettingsSectionNode : ASDisplayNode {
    var checkboxSpacing : CGFloat = 15
    var checkboxSize : CGSize = CGSizeMake(18, 18)
    
    var title : ASTextNode!
    var titleAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    var subtitleAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1), NSKernAttributeName : -0.1]
}

class DisconnectSectionNode : SettingsSectionNode {
    
    var disconnectButton : ButtonNode!
    
        override init() {
        super.init()
        
        self.disconnectButton = ButtonNode()
        self.disconnectButton.setAttributedTitle(NSAttributedString(string: "Disconnect :(", attributes: self.subtitleAttributes), forState: ASControlState.Normal)
        
        self.alignSelf = .Stretch
        
        self.addSubnode(self.disconnectButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let disconnectStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.disconnectButton])
        disconnectStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 7, justifyContent: .Center, alignItems: .Center, children: [disconnectStack])
    }
}

class FeedbackSectionNode : SettingsSectionNode {
    
    var giveFeedbackButton : ButtonNode!
    
        override init() {
        super.init()
        
        self.title = ASTextNode()
        self.title.spacingAfter = 17
        self.title.alignSelf = .Stretch
        self.title.attributedString = NSAttributedString(string: "Feedback", attributes: titleAttributes)
        
        self.giveFeedbackButton = ButtonNode()
        self.giveFeedbackButton.setAttributedTitle(NSAttributedString(string: "Tell Us What You Think", attributes: self.subtitleAttributes), forState: ASControlState.Normal)
        
        self.alignSelf = .Stretch
        
        self.addSubnode(self.title)
        self.addSubnode(self.giveFeedbackButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let feedbackStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.giveFeedbackButton])
        feedbackStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 7, justifyContent: .Center, alignItems: .Center, children: [self.title, feedbackStack])
    }
    
}

class AboutNode : SettingsSectionNode {
    
    var aboutUsButton : ButtonNode!
    var termsAndConditionsButton : ButtonNode!
    var librariesButton : ButtonNode!
    
        override init() {
        super.init()
        
        self.title = ASTextNode()
        self.title.spacingAfter = 17
        self.title.alignSelf = .Stretch
        self.title.attributedString = NSAttributedString(string: "About", attributes: titleAttributes)
        
        self.aboutUsButton = ButtonNode()
        self.aboutUsButton.setAttributedTitle(NSAttributedString(string: "About Us", attributes: self.subtitleAttributes), forState: ASControlState.Normal)
        
        self.termsAndConditionsButton = ButtonNode()
        self.termsAndConditionsButton.setAttributedTitle(NSAttributedString(string: "Terms and Conditions", attributes: self.subtitleAttributes), forState: ASControlState.Normal)
        
        self.librariesButton = ButtonNode()
        self.librariesButton.setAttributedTitle(NSAttributedString(string: "Libraries", attributes: self.subtitleAttributes), forState: ASControlState.Normal)
        
        self.alignSelf = .Stretch
        
        self.addSubnode(self.title)
        self.addSubnode(self.aboutUsButton)
        self.addSubnode(self.termsAndConditionsButton)
        self.addSubnode(self.librariesButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let aboutUsStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.aboutUsButton])
        aboutUsStack.alignSelf = .Stretch
        
        let termsAndConditions = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.termsAndConditionsButton])
        termsAndConditions.alignSelf = .Stretch
        
        let librariesStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.librariesButton])
        librariesStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 7, justifyContent: .Center, alignItems: .Center, children: [self.title, aboutUsStack, termsAndConditions, librariesStack])
    }
}

class NotificationsNode : SettingsSectionNode {
    
    var followsNotificationSubtitle : ASTextNode!
    var followsNotificationCheckbox : BFPaperCheckbox!
    
    var streamsNotificationSubtitle : ASTextNode!
    var streamsNotificationCheckbox : BFPaperCheckbox!
    
    var newUserNotificationSubtitle : ASTextNode!
    var newUserNotificationCheckbox : BFPaperCheckbox!
    
    var myStreamNotificationSubtitle : ASTextNode!
    var myStreamNotificationCheckbox : BFPaperCheckbox!
    
        override init() {
        super.init()
        
        self.title = ASTextNode()
        self.title.spacingAfter = 17
        self.title.alignSelf = .Stretch
        self.title.attributedString = NSAttributedString(string: "Notifications", attributes: titleAttributes)
        
        self.followsNotificationSubtitle = ASTextNode()
        self.followsNotificationSubtitle.attributedString = NSAttributedString(string: "Follows", attributes: subtitleAttributes)
        
        self.followsNotificationCheckbox = BFPaperCheckbox(frame: CGRect(origin: CGPointZero, size: checkboxSize))
        self.followsNotificationCheckbox.tapCircleNegativeColor = UIColor.clearColor()
        self.followsNotificationCheckbox.tapCirclePositiveColor = UIColor.clearColor()
        self.followsNotificationCheckbox.rippleFromTapLocation = false
        self.followsNotificationCheckbox.layer.cornerRadius = 0
        
        self.streamsNotificationSubtitle = ASTextNode()
        self.streamsNotificationSubtitle.attributedString = NSAttributedString(string: "Streams", attributes: subtitleAttributes)
        
        self.streamsNotificationCheckbox = BFPaperCheckbox(frame: CGRect(origin: CGPointZero, size: checkboxSize))
        self.streamsNotificationCheckbox.tapCircleNegativeColor = UIColor.clearColor()
        self.streamsNotificationCheckbox.tapCirclePositiveColor = UIColor.clearColor()
        self.streamsNotificationCheckbox.rippleFromTapLocation = false
        self.streamsNotificationCheckbox.layer.cornerRadius = 0
        
        self.newUserNotificationSubtitle = ASTextNode()
        self.newUserNotificationSubtitle.attributedString = NSAttributedString(string: "New User", attributes: subtitleAttributes)
        
        self.newUserNotificationCheckbox = BFPaperCheckbox(frame: CGRect(origin: CGPointZero, size: checkboxSize))
        self.newUserNotificationCheckbox.tapCircleNegativeColor = UIColor.clearColor()
        self.newUserNotificationCheckbox.tapCirclePositiveColor = UIColor.clearColor()
        self.newUserNotificationCheckbox.rippleFromTapLocation = false
        self.newUserNotificationCheckbox.layer.cornerRadius = 0
        
        self.myStreamNotificationSubtitle = ASTextNode()
        self.myStreamNotificationSubtitle.attributedString = NSAttributedString(string: "My Stream", attributes: subtitleAttributes)
        
        self.myStreamNotificationCheckbox = BFPaperCheckbox(frame: CGRect(origin: CGPointZero, size: checkboxSize))
        self.myStreamNotificationCheckbox.tapCircleNegativeColor = UIColor.clearColor()
        self.myStreamNotificationCheckbox.tapCirclePositiveColor = UIColor.clearColor()
        self.myStreamNotificationCheckbox.rippleFromTapLocation = false
        self.myStreamNotificationCheckbox.layer.cornerRadius = 0
        
        self.alignSelf = .Stretch
        self.addSubnode(self.title)
        self.addSubnode(self.followsNotificationSubtitle)
        self.addSubnode(self.streamsNotificationSubtitle)
        self.addSubnode(self.newUserNotificationSubtitle)
        self.addSubnode(self.myStreamNotificationSubtitle)
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.addSubview(self.followsNotificationCheckbox)
        self.view.addSubview(self.streamsNotificationCheckbox)
        self.view.addSubview(self.newUserNotificationCheckbox)
        self.view.addSubview(self.myStreamNotificationCheckbox)
    }
    
    override func layout() {
        super.layout()
        self.followsNotificationCheckbox.center = CGPointMake(self.calculatedSize.width - 10, self.followsNotificationSubtitle.position.y)
        self.streamsNotificationCheckbox.center = CGPointMake(self.calculatedSize.width - 10, self.streamsNotificationSubtitle.position.y)
        self.newUserNotificationCheckbox.center = CGPointMake(self.calculatedSize.width - 10, self.newUserNotificationSubtitle.position.y)
        self.myStreamNotificationCheckbox.center = CGPointMake(self.calculatedSize.width - 10, self.myStreamNotificationSubtitle.position.y)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let followsStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.followsNotificationSubtitle])
        followsStack.alignSelf = .Stretch
        
        let streamsStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.streamsNotificationSubtitle])
        streamsStack.alignSelf = .Stretch
        
        let userStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.newUserNotificationSubtitle])
        userStack.alignSelf = .Stretch
        
        let mystreamStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.myStreamNotificationSubtitle])
        mystreamStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: checkboxSpacing, justifyContent: .Center, alignItems: .Center, children: [self.title, followsStack, streamsStack, userStack, mystreamStack])
    }
}

class SecurityPrivacyNode : SettingsSectionNode {
    
    var passwordSubtitle : ASTextNode!
    var privateModeSubtitle : ASTextNode!
    var privateModeCheckbox : BFPaperCheckbox!
    
        override init() {
        super.init()
        
        self.title = ASTextNode()
        self.title.spacingAfter = 17
        self.title.alignSelf = .Stretch
        self.title.attributedString = NSAttributedString(string: "Security / Privacy", attributes: titleAttributes)
        
        self.passwordSubtitle = ASTextNode()
        self.passwordSubtitle.attributedString = NSAttributedString(string: "Password", attributes: subtitleAttributes)
        
        self.privateModeSubtitle = ASTextNode()
        self.privateModeSubtitle.attributedString = NSAttributedString(string: "Private Mode", attributes: subtitleAttributes)
        
        self.privateModeCheckbox = BFPaperCheckbox(frame: CGRect(origin: CGPointZero, size: checkboxSize))
        self.privateModeCheckbox.tapCircleNegativeColor = UIColor.clearColor()
        self.privateModeCheckbox.tapCirclePositiveColor = UIColor.clearColor()
        self.privateModeCheckbox.rippleFromTapLocation = false
        self.privateModeCheckbox.layer.cornerRadius = 0
        
        self.alignSelf = .Stretch
        
        self.addSubnode(self.title)
        self.addSubnode(self.passwordSubtitle)
        self.addSubnode(self.privateModeSubtitle)
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.addSubview(self.privateModeCheckbox)
    }
    
    override func layout() {
        super.layout()
        self.privateModeCheckbox.center = CGPointMake(self.calculatedSize.width - 10, self.privateModeSubtitle.position.y)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let passwordStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.passwordSubtitle])
        passwordStack.spacingAfter = 12
        passwordStack.alignSelf = .Stretch
        
        let privateModeStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [self.privateModeSubtitle])
        privateModeStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.title, passwordStack, privateModeStack])
    }
}

class SettingsSourcesNode : SettingsSectionNode {
    
    var sourceButtons : [ButtonNode] = []
    
    var soundcloudButton : SourceLoginButtonNode!
    var spotifyButton : SourceLoginButtonNode!
    var youtubeButton : SourceLoginButtonNode!
    var googleplayButton : SourceLoginButtonNode!
    var groovesharkButton : SourceLoginButtonNode!
    
    var sources : [String] = ["Soundcloud", "Spotify", "YouTube", "Grooveshark", "Googleplay"]
    
        override init() {
        super.init()
        
        self.title = ASTextNode()
        self.title.spacingBefore = 23
        self.title.alignSelf = .Stretch
        self.title.attributedString = NSAttributedString(string: "Sources", attributes: titleAttributes)
        
        self.alignSelf = .Stretch
        
        self.soundcloudButton = SourceLoginButtonNode(source: .Soundcloud)
        self.spotifyButton = SourceLoginButtonNode(source: SynncExternalSource.Spotify)
        self.youtubeButton = SourceLoginButtonNode(source: SynncExternalSource.YouTube)
        self.googleplayButton = SourceLoginButtonNode(source: SynncExternalSource.GooglePlay)
        self.groovesharkButton = SourceLoginButtonNode(source: SynncExternalSource.Grooveshark)
        
        self.sourceButtons = [soundcloudButton, spotifyButton, youtubeButton, googleplayButton, groovesharkButton]
        
        self.addSubnode(soundcloudButton)
        self.addSubnode(spotifyButton)
        self.addSubnode(youtubeButton)
        self.addSubnode(googleplayButton)
        self.addSubnode(groovesharkButton)

        self.addSubnode(self.title)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let buttonStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Start, alignItems: .Start, children: self.sourceButtons)
        
        buttonStack.alignSelf = .Stretch
        buttonStack.spacingBefore = 12
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.title, buttonStack])
    }
}