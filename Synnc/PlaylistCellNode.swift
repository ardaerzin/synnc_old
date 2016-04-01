//
//  PlaylistCellNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/18/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import Cloudinary
import pop

class PlaylistCellInfoHolder : ASDisplayNode {
    var nameNode : ASTextNode!
    var trackCountNode : ASTextNode!
    var genresNode : ASTextNode!
    
    override init() {
        super.init()
        
        self.nameNode = ASTextNode()
        self.nameNode.spacingBefore = 20
        self.nameNode.alignSelf = .Stretch
        self.addSubnode(self.nameNode)
        
        self.trackCountNode = ASTextNode()
        self.trackCountNode.maximumNumberOfLines = 1
        self.addSubnode(self.trackCountNode)
        
        
        self.genresNode = ASTextNode()
        self.genresNode.flexGrow = true
        self.genresNode.maximumNumberOfLines = 1
        self.addSubnode(genresNode)
        
        backgroundColor = .whiteColor()
        
    }
    
    func configureForPlaylist(playlist : SynncPlaylist) {
        if let name = playlist.name {
            self.nameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5 ])
        }
        self.trackCountNode.attributedString = NSAttributedString(string: "\(playlist.songs.count) tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)])
        
        var genreText = ""
        for (ind,genre) in playlist.genres.enumerate() {
            if ind == 0 {
                genreText += genre.name
            } else {
                genreText += (" / " + genre.name)
            }
        }
        self.genresNode.attributedString = NSAttributedString(string: genreText, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)])
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let bottomStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 8, justifyContent: .Center, alignItems: .Center, children: [trackCountNode, genresNode])
        
        bottomStack.spacingBefore = 5
        bottomStack.spacingAfter = 24
        bottomStack.alignSelf = .Stretch
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 2, justifyContent: .Center, alignItems: .Center, children: [nameNode, bottomStack])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 9, 0, 9), child: stack)
    }
}

class PlaylistCell : ASDisplayNode {
    
    var imageNode : ASNetworkImageNode!
    var infoNode : PlaylistCellInfoHolder!
    var img : AnyObject!
    
    override func fetchData() {
        super.fetchData()
        
        let transformation = CLTransformation()
        transformation.width = self.imageNode.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.imageNode.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        if let id = self.img as? String, let x = _cloudinary.url(id, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            self.imageNode.URL = url
        } else if let img = self.img as? UIImage {
            if img.size.width != img.size.height {
                self.imageNode.contentMode = UIViewContentMode.ScaleAspectFill
            } else {
                self.imageNode.contentMode = UIViewContentMode.Center
            }
            self.imageNode.image = img
        }
    }
    
    override init() {
        super.init()
        
        self.imageNode = ASNetworkImageNode()
        self.imageNode.backgroundColor = UIColor.whiteColor()
        self.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 70))
        self.imageNode.image = Synnc.appIcon
        self.imageNode.contentMode = UIViewContentMode.Center
        self.addSubnode(self.imageNode)
        
        infoNode = PlaylistCellInfoHolder()
        infoNode.alignSelf = .Stretch
        self.addSubnode(infoNode)
        
        self.cornerRadius = 15
        self.clipsToBounds = true
        
        
    }
    
    func configureForPlaylist(playlist : SynncPlaylist) {
        self.infoNode.configureForPlaylist(playlist)
        if let id = playlist.cover_id where id != "" {
            self.img = id
        }
        if let img = playlist.coverImage {
            self.img = img
        }
        
        self.fetchData()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [self.imageNode]), infoNode])
        return a
    }
}

class PlaylistCellNode : ASCellNode {
    
    var contentNode : PlaylistCell!
    
    override init() {
        super.init()
        
        self.contentNode = PlaylistCell()
        
        self.addSubnode(contentNode)
        
        self.selectionStyle = .None
        
        self.shadowColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 0.5).CGColor
        self.shadowOpacity = 1
        self.shadowOffset = CGSizeMake(0, 1)
        self.shadowRadius = 2
    }
    func configureForPlaylist(playlist : SynncPlaylist) {
        contentNode.configureForPlaylist(playlist)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [contentNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(10, 15, 10, 15), child: a)
    }
}