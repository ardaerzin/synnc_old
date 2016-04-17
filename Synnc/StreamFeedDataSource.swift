//
//  StreamFeedDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLUserManager
import WCLPopupManager

class StreamFeedDataSource : WCLAsyncTableViewDataSource {
    override func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = StreamCellNode()
        
        if indexPath.item >= self.data.count {
            return node
        }
        
        if let stream = self.data[indexPath.item] as? Stream {
            node.configureForStream(stream)
        }
        return node
    }
}

protocol UserUIElement {
    var userId : String! {get set}
}
class UserImageNode : ASNetworkImageNode, UserUIElement {
    var userId : String!
}
class UserNameNode : ASTextNode, UserUIElement {
    var userId : String!
}

class StreamStoryNode : ASDisplayNode {
    var imageNode : UserImageNode!
    var textNode : ASTextNode!
    
    override init() {
        super.init()
        
        imageNode = UserImageNode()
        imageNode.preferredFrameSize = CGSize(width: 25,height: 25)
        self.addSubnode(imageNode)
        
        textNode = ASTextNode()
        textNode.userInteractionEnabled = true
        self.addSubnode(textNode)
    }
    
    
    
    func configureForStream(stream : Stream) {
        if let type = WCLUserLoginType(rawValue: stream.user.provider), let url = stream.user.avatarURL(type, frame: CGRect(x: 0, y: 0, width: 25, height: 25), scale: UIScreen.mainScreen().scale) {
            imageNode.URL = url
            imageNode.userId = stream.user._id
        }
        
        let attributes = [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)]
        let linkAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSLinkAttributeName : stream.user._id]
        
        let usernameStr = NSAttributedString(string: stream.user.username, attributes: linkAttributes)
        
        let storyString = NSAttributedString(string: " started a new stream", attributes: attributes)
        
        let mutableStr = NSMutableAttributedString()
        mutableStr.appendAttributedString(usernameStr)
        mutableStr.appendAttributedString(storyString)
        
        let r = mutableStr.string.NSRangeFromRange(mutableStr.string.rangeOfString(mutableStr.string)!)
        mutableStr.addAttribute(NSUnderlineColorAttributeName, value: UIColor.clearColor(), range: r)
        
        textNode.attributedString = mutableStr
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        textNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 35)
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Center, alignItems: .Center, children: [imageNode, textNode])
    }
}

class StreamCellButton : ButtonNode {
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.titleNode.flexGrow = true
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 6, justifyContent: .Start, alignItems: .Center, children: [self.imageNode, self.titleNode])
    }
}

class StreamCellContentNode : ASDisplayNode {
    
    var imageNode : ASNetworkImageNode!
    var titleNode : ASTextNode!
    var genresNode : ASTextNode!
    var listenersNode : StreamCellButton!
    var reactionsNode : StreamCellButton!
    
    var imageId : String?
    var streamTitle : String?
    var streamGenres : String = ""
    var listeners : Int = 0
    var reactions : Int = 0
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        self.addSubnode(imageNode)
        
        titleNode = ASTextNode()
        self.addSubnode(titleNode)
        
        genresNode = ASTextNode()
        genresNode.maximumNumberOfLines = 1
        self.addSubnode(genresNode)
        
        listenersNode = StreamCellButton()
        listenersNode.setImage(UIImage(named: "listeners-icon"), forState: .Normal)
        listenersNode.flexGrow = true
        self.addSubnode(listenersNode)
        
        reactionsNode = StreamCellButton()
        reactionsNode.setImage(UIImage(named: "reactions-icon"), forState: .Normal)
        reactionsNode.flexGrow = true
        reactionsNode.hidden = true
        self.addSubnode(reactionsNode)
    }
    
    override func fetchData() {
        let transformation = CLTransformation()
        
        transformation.width = self.imageNode.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.imageNode.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        
        if let img = imageId, let x = _cloudinary.url(img, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            self.imageNode.URL = url
            self.imageNode.contentMode = .ScaleAspectFit
        } else {
            self.imageNode.contentMode = .Center
            self.imageNode.image = Synnc.appIcon
        }
        
        let title = streamTitle == nil ? "Untitled" : streamTitle!
        titleNode.attributedString = NSAttributedString(string: title, attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5])
        
        genresNode.attributedString = NSAttributedString(string: streamGenres, attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)])
        
        
        let x = NSAttributedString(string: "\(self.listeners)", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)])
        listenersNode.setAttributedTitle(x, forState: .Normal)
        
        self.setNeedsLayout()
    }
    
    func configureForStream(stream : Stream) {
        
        if let img = stream.playlist.cover_id {
            self.imageId = img as String
        }
        
        var genreText : String = ""
        for (ind,genre) in stream.playlist.genres.enumerate() {
            
            if ind == 0 {
                genreText = genre.name
            } else {
                genreText += (" / " + genre.name)
            }
        }
        streamGenres = genreText
        streamTitle = stream.playlist.name
        
        listeners = stream.users.count
        
        self.setNeedsDataFetch()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let imageStack = ASStaticLayoutSpec(children: [imageNode])
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width * 0.23, constrainedSize.max.width * 0.23))
        imageStack.spacingBefore = 20
        imageStack.spacingAfter = 25
        
        titleNode.alignSelf = .Stretch
        
        let buttonStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [listenersNode, reactionsNode])
        buttonStack.alignSelf = .Stretch
        buttonStack.spacingBefore = 23
        
        let textStack = ASStackLayoutSpec(direction: .Vertical, spacing: 3, justifyContent: .Start, alignItems: .Start, children: [titleNode, genresNode, buttonStack])
        textStack.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - constrainedSize.max.width * 0.23 - 50)
        textStack.spacingAfter = 10
        
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [imageStack, textStack])
    }
}

class StreamCell : ASDisplayNode {
    var storyNode : StreamStoryNode!
    var streamNode : StreamCellContentNode!
    var separator : ASDisplayNode!
    
    override init() {
        super.init()
        
        storyNode = StreamStoryNode()
        storyNode.alignSelf = .Stretch
        self.addSubnode(storyNode)
        
        separator = ASDisplayNode()
        separator.alignSelf = .Stretch
        separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        separator.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        self.addSubnode(separator)
        
        streamNode = StreamCellContentNode()
        streamNode.alignSelf = .Stretch
        self.addSubnode(streamNode)
        
        self.cornerRadius = 8
        self.backgroundColor = .whiteColor()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let storySpec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 12, 0, 12), child: storyNode)
        storySpec.alignSelf = .Stretch
        storySpec.spacingBefore = 10
        storySpec.spacingAfter = 12
        
        streamNode.spacingBefore = 16
        streamNode.spacingAfter = 15
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [storySpec, separator, streamNode])
    }
    
    func configureForStream(stream : Stream) {
        self.storyNode.configureForStream(stream)
        self.streamNode.configureForStream(stream)
    }
}

class StreamCellNode : ASCellNode {
    var contentNode : StreamCell!
    
    override init() {
        
        super.init()
        
        self.contentNode = StreamCell()
        self.contentNode.alignSelf = .Stretch
        self.addSubnode(contentNode)
        
        self.selectionStyle = .None
        
        self.shadowColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 0.5).CGColor
        self.shadowOpacity = 1
        self.shadowOffset = CGSizeMake(0, 1)
        self.shadowRadius = 2
        
        self.contentNode.storyNode.textNode.delegate = self
        self.contentNode.storyNode.imageNode.addTarget(self, action: #selector(StreamCellNode.tappedOnUserImage(_:)), forControlEvents: .TouchUpInside)
        self.userInteractionEnabled = true
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [contentNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 15, 5, 15), child: a)
    }
    
    func configureForStream(stream : Stream) {
        self.contentNode.configureForStream(stream)
    }
}

extension StreamCellNode : ASTextNodeDelegate {
    func textNode(textNode: ASTextNode, tappedLinkAttribute attribute: String, value: AnyObject, atPoint point: CGPoint, textRange: NSRange) {
        if let id = value as? String {
            displayUserPopup(id)
        }
        AnalyticsEvent.new(category: "ui_action", action: "text_tap", label: "streamCell_user", value: nil)
    }
    func tappedOnUserImage(image: UserImageNode) {
        if let id = image.userId {
            displayUserPopup(id)
        }
        AnalyticsEvent.new(category: "ui_action", action: "image_tap", label: "streamCell_user", value: nil)
    }
    func displayUserPopup(id : String){
        if let user = WCLUserManager.sharedInstance.findUser(id) {
            let size = CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200)
            let x = UserProfilePopup(size: size, user: user)
            WCLPopupManager.sharedInstance.newPopup(x)
        }
    }
}