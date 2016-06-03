//
//  StreamInfoNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/29/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Shimmer
import WCLUserManager

class StreamInfoHolder : ASDisplayNode, TrackedView {
    var infoNode : StreamInfoNode!
    var headerSpacer : ASDisplayNode!
    var title: String! = "Stream Info"
    
    init(usersSection : StreamListenersNode) {
        super.init()
        infoNode = StreamInfoNode(usersSection: usersSection)
        infoNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(infoNode)
        
        headerSpacer = ASDisplayNode()
        headerSpacer.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        headerSpacer.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 60))
        self.addSubnode(headerSpacer)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [infoNode, headerSpacer])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        //        self.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
    }
}

class StreamInfoNode : WCLScrollNode {
    
    var state : StreamControllerState! = .Inactive {
        didSet {
            
        }
    }
    
    var topSection : StreamTopSection!
    var listenersSection : StreamListenersNode!
    var playlistSection : StreamPlaylistSection!
    var genreSection : StreamGenreSection!
    var locationSection : StreamLocationSection!
    
    init(usersSection : StreamListenersNode) {
        super.init()
        topSection = StreamTopSection()
        topSection.alignSelf = .Stretch
        topSection.spacingBefore = 116
        topSection.spacingAfter = 13
        self.addSubnode(topSection)
        
        listenersSection = usersSection
        self.addSubnode(listenersSection)
        
        playlistSection = StreamPlaylistSection()
        self.addSubnode(playlistSection)
    
        genreSection = StreamGenreSection()
        self.addSubnode(genreSection)
    
        locationSection = StreamLocationSection()
        self.addSubnode(locationSection)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [topSection, listenersSection, playlistSection, genreSection, locationSection])
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        var height = self.locationSection.position.y + (self.locationSection.calculatedSize.height / 2) + 100
        if height < self.calculatedSize.height {
            height = self.calculatedSize.height + 1
        }
        self.view.contentSize.height = height
    }
    
    func configure(stream : Stream) {
        self.topSection.configure(stream)
        self.listenersSection.configure(stream)
        self.playlistSection.configure(stream)
        self.genreSection.configure(stream)
        self.locationSection.configure(stream)
    }
}

class TappableUserArea : ASControlNode {
    var userImage : ASNetworkImageNode!
    var usernameNode : ASTextNode!
    var userId : String!
    
    override init() {
        super.init()
        
        userImage = ASNetworkImageNode()
        userImage.spacingBefore = 18
        userImage.spacingAfter = 15
        userImage.preferredFrameSize = CGSize(width: 44,height: 44)
        self.addSubnode(userImage)
        
        usernameNode = ASTextNode()
        self.addSubnode(usernameNode)
    }
    
    func configure(user : WCLUser) {
        
        self.userId = user._id
        
        if let type = WCLUserLoginType(rawValue: user.provider), let url = user.avatarURL(type, frame: CGRect(x: 0, y: 0, width: 44, height: 44), scale: UIScreen.mainScreen().scale) {
            userImage.URL = url
        }
        
        usernameNode.attributedString = NSAttributedString(string: user.username, attributes: [NSFontAttributeName: UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.4])
        
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [userImage, usernameNode])
    }
}

class SourceHolder : ASDisplayNode {
    
    var buttons : [SourceButton] = []
    var buttonSize : CGSize!
    
    init(size : CGSize? = CGSizeMake(25, 25)) {
        super.init()
        
        self.buttonSize = size!
        for type in SynncExternalSource.premiumSources {
            if let t = WCLUserLoginType(rawValue: type.rawValue.lowercaseString), let user = Synnc.sharedInstance.user, let ext = user.userExtension(t) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SourceHolder.extensionLoginStatusChanged(_:)), name: "\(t.rawValue)LoginStatusChanged", object: ext)
            }
        }
    }
    
    internal func buttonForUserExtension(ext: WCLUserExtension) -> SourceButton? {
        for button in buttons {
            if button.source.rawValue.lowercaseString == ext.type.rawValue.lowercaseString {
                return button
            }
        }
        return nil
    }
    
    internal func extensionLoginStatusChanged(notification : NSNotification) {
        if let ext = notification.object as? WCLUserExtension, let button = self.buttonForUserExtension(ext) {
            
            if let status = ext.loginStatus where status {
                button.selected = true
            } else {
                button.selected = false
            }
        }
    }
    
    func configure(sources: [String]){
        
        for button in buttons {
            button.removeFromSupernode()
        }
        
        buttons = []
        
        for source in sources {
            let button = SourceButton(source: SynncExternalSource(rawValue: source)!)
            
            if let src = SynncExternalSource(rawValue: source), let type = WCLUserLoginType(rawValue: source.lowercaseString), let user = Synnc.sharedInstance.user, let ext = user.userExtension(type), let ind = SynncExternalSource.premiumSources.indexOf(src) {
                
                if let status = ext.loginStatus where status {
                    button.selected = true
                } else {
                    button.selected = false
                }
            } else {
                button.selected = true
            }
            
            button.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(self.buttonSize)
            self.addSubnode(button)
            buttons.append(button)
        }
        
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var buttonSpecs : [ASLayoutSpec] = []
        
        for button in buttons {
            buttonSpecs.append(ASStaticLayoutSpec(children: [button]))
        }
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 5, justifyContent: .Center, alignItems: .Center, children: buttonSpecs)
    }
}

class StreamTopSection : ASDisplayNode {
    
    var userArea : TappableUserArea!
    var sourceArea : SourceHolder!
//    var joinButton : ButtonNode!
    
    override init(){
        super.init()
        
        userArea = TappableUserArea()
        self.addSubnode(userArea)

        sourceArea = SourceHolder()
        sourceArea.spacingAfter = 18
        self.addSubnode(sourceArea)
        
//        joinButton = ButtonNode()
//        joinButton.setAttributedTitle(NSAttributedString(string: "JOIN", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.SynncColor()]), forState: .Normal)
//        joinButton.spacingAfter = 21
//        joinButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
//        joinButton.hidden = true
//        self.addSubnode(joinButton)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [userArea, spacer, sourceArea])
    }
    
    func configure(stream : Stream) {
        self.userArea.configure(stream.user)
        sourceArea.configure(stream.playlist.allSources())
        self.setNeedsLayout()
    }
}

class StreamInfoSubsection : ASDisplayNode {
    var titleNode : ASTextNode!
    var contentNode : ASTextNode!
    var separator : ASDisplayNode!
    
    lazy var contentAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5]
    }()
    lazy var titleAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5]
    }()
    
    override init() {
        super.init()
        
        separator = ASDisplayNode()
        separator.alignSelf = .Stretch
        separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        separator.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.2)
        self.addSubnode(separator)
        
        titleNode = ASTextNode()
        titleNode.spacingBefore = 25
        titleNode.spacingAfter = 15
        titleNode.alignSelf = .Stretch
        self.addSubnode(titleNode)
        
        contentNode = ASTextNode()
        contentNode.alignSelf = .Stretch
        contentNode.spacingAfter = 24
        
        self.addSubnode(contentNode)
        
        self.alignSelf = .Stretch
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let infoStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleNode, contentNode])
        
        let infoSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 20, 0, 20) , child: infoStack)
        infoSpec.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [separator, infoSpec])
    }
    
    func configure(stream: Stream) {
        
    }
}

class StreamPlaylistSection : StreamInfoSubsection {
    override init() {
        super.init()
        titleNode.attributedString = NSAttributedString(string: "STREAM LENGTH", attributes: self.titleAttributes)
    }
    
    override func configure(stream: Stream) {
        super.configure(stream)
        contentNode.attributedString = NSAttributedString(string: "\(stream.playlist.songs.count) Tracks", attributes: self.contentAttributes)
        self.setNeedsLayout()
    }
    
}

class StreamGenreSection : StreamInfoSubsection {
    override init() {
        super.init()
        titleNode.attributedString = NSAttributedString(string: "GENRES", attributes: self.titleAttributes)
    }
    
    override func configure(stream: Stream) {
        super.configure(stream)
        
        var genreText = ""
        for (ind,genre) in stream.playlist.genres.enumerate() {
            if ind == 0 {
                genreText += genre.name
            } else {
                genreText += (", " + genre.name)
            }
        }
        
        if genreText == "" {
            genreText = "Stream does not have any genres."
        }
        
        contentNode.attributedString = NSAttributedString(string: genreText, attributes: self.contentAttributes)
        self.setNeedsLayout()
    }
    
}

class StreamLocationSection : StreamInfoSubsection {
    override init() {
        super.init()
        titleNode.attributedString = NSAttributedString(string: "LOCATION", attributes: self.titleAttributes)
    }
    
    override func configure(stream: Stream) {
        super.configure(stream)
        
        var locationString : String
        if let location = stream.playlist.location {
            locationString = location
        } else {
            locationString = "No Public location"
        }
        
        contentNode.attributedString = NSAttributedString(string: locationString, attributes: self.contentAttributes)
        self.setNeedsLayout()
    }
    
}

class ListenersEmptyStateNode : ASDisplayNode {
    var msgNode : ASTextNode!
    lazy var msgAttributes : [String : AnyObject] = {
       
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5]
        
    }()
    
    override init() {
        super.init()
        
        msgNode = ASTextNode()
        msgNode.attributedString = NSAttributedString(string: "No active users", attributes: msgAttributes)
        self.addSubnode(msgNode)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [msgNode])
    }
}

class StreamListenersSection : ASDisplayNode {
    
    var emptyStateNode : ListenersEmptyStateNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = ListenersEmptyStateNode()
                }
                if emptyState {
                    self.addSubnode(emptyStateNode)
                } else {
                    emptyStateNode.removeFromSupernode()
                    emptyStateNode = nil
                }
                self.setNeedsLayout()
            }
        }
    }
    var titleNode : ASTextNode!
    var countNode : ASTextNode!
    lazy var countAttributes : [String : AnyObject] = {
        return [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)]
    }()
    var separator : ASDisplayNode!
    var collectionNode : ASCollectionNode!
    
    override init() {
        super.init()
        
        separator = ASDisplayNode()
        separator.alignSelf = .Stretch
        separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        separator.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.2)
        self.addSubnode(separator)
        
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: "JOINED USERS", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5])
        self.addSubnode(titleNode)
        
        countNode = ASTextNode()
        countNode.spacingBefore = 6
        self.addSubnode(countNode)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal

        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        collectionNode.alignSelf = .Stretch
        collectionNode.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        collectionNode.view.backgroundColor = .clearColor()
        
        self.addSubnode(collectionNode)
        self.alignSelf = .Stretch
    }
    
    func configure(stream: Stream) {
        countNode.attributedString = NSAttributedString(string: "\(stream.users.count)", attributes: self.countAttributes)
        
        self.emptyState = stream.users.isEmpty
        
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let titleStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [titleNode, countNode])
        titleStack.alignSelf = .Stretch
        titleStack.spacingBefore = 25
        titleStack.spacingAfter = 15
        
        
        let o = ASOverlayLayoutSpec(child: collectionNode, overlay: self.emptyStateNode)
        o.alignSelf = .Stretch
        o.flexBasis = ASRelativeDimension(type: .Points, value: 40)
        o.spacingAfter = 24
        
        let infoStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleStack, o])
        let infoSpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 20, 0, 20) , child: infoStack)
        infoSpec.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [separator, infoSpec])
    }
}