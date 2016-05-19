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

class PlaylistCellCover : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    
    override init() {
        super.init()
        imageNode = ASNetworkImageNode()
        imageNode.image = Synnc.appIcon
        imageNode.contentMode = UIViewContentMode.Center
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value : 1), ASRelativeDimension(type: .Percent, value : 1))
        self.addSubnode(imageNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [imageNode])
    }
}

class CellButtonNode : ButtonNode {
    var indexPath : NSIndexPath!
}

class PlaylistCellInfoHolder : ASDisplayNode {
    var nameNode : ASTextNode!
    var trackCountNode : ASTextNode!
    var genresNode : ASTextNode!
    var buttonNode : CellButtonNode!
    var sourceHolder : SourceHolder!
    var genresText : String!
    
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
        self.genresNode.maximumNumberOfLines = 1
        self.genresNode.truncationMode = .ByTruncatingTail
        self.genresNode.flexShrink = true
        self.addSubnode(genresNode)
        
        self.buttonNode = CellButtonNode()
        self.buttonNode.setImage(UIImage(named: "submenu"), forState: .Normal)
        self.addSubnode(buttonNode)
        
        sourceHolder = SourceHolder(size: CGSizeMake(15, 15))
        self.addSubnode(sourceHolder)
        
        backgroundColor = .whiteColor()
        
    }
    
    func configureForPlaylist(playlist : SynncPlaylist) {
        if let name = playlist.name {
            self.nameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5 ])
        }
        self.trackCountNode.attributedString = NSAttributedString(string: "\(playlist.songs.count) tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: 1)])
        
        var genreText : String!
        for (ind,genre) in playlist.genres.enumerate() {
            if genreText == nil {
                genreText = ""
            }
            if ind == 0 {
                genreText! += genre.name
            } else {
                genreText! += (", " + genre.name)
            }
        }
        if genreText == nil {
            self.genresNode.attributedString = nil
        } else {
            self.genresNode.attributedString = NSAttributedString(string: genreText, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 13)!, NSForegroundColorAttributeName : UIColor.SynncColor()])
        }
        self.genresText = genreText
        self.sourceHolder.configure(playlist.allSources())
    
        self.genresNode.setNeedsLayout()
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        let bottomStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 8, justifyContent: .Center, alignItems: .Center, children: [trackCountNode, sourceHolder, spacer])
        
        bottomStack.spacingBefore = 5
        bottomStack.spacingAfter = 5
        bottomStack.alignSelf = .Stretch
        
        genresNode.alignSelf = .Stretch
        var items : [ASLayoutable] = [nameNode, bottomStack]
        if genresText != nil {
            items.append(genresNode)
            genresNode.spacingAfter = 24
        } else {
            bottomStack.spacingAfter = 24
        }
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 2, justifyContent: .Center, alignItems: .Center, children: items)
        stack.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 50)
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [stack, buttonNode])
        buttonNode.flexGrow = true
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 9, 0, 9), child: x)
    }
}

class PlaylistCell : ASDisplayNode {
    
    var imageNode : ASNetworkImageNode! {
        get {
            return self.coverNode.imageNode
        }
    }
    var coverNode : PlaylistCellCover!
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
        
        self.coverNode = PlaylistCellCover()
        self.coverNode.backgroundColor = UIColor.whiteColor()
        self.coverNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 70))
        
        self.addSubnode(self.coverNode)
        
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
        
        self.setNeedsDataFetch()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [self.coverNode]), infoNode])
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