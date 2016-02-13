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

class StreamFeedDataSource : WCLAsyncCollectionViewDataSource {
    override func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = StreamFeedNode()
        if let stream = self.data[indexPath.item] as? Stream {
            node.configure(stream)
        }
        return node
    }
}

class StreamFeedNode : ASCellNode {
    
    var titleNode : ASTextNode!
    var imageNode : ASNetworkImageNode!
    var streamInfoNode : StreamCellInfoNode!
    var genresNode : ASTextNode!
    
    var genreAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 230.255, green: 228/255, blue: 228/255, alpha: 1), NSKernAttributeName : 0.1]
    var genreStr : String!
    var imgId : String!
    
        override init() {
        super.init()
        
        streamInfoNode = StreamCellInfoNode()
        streamInfoNode.alignSelf = .Stretch
        streamInfoNode.spacingBefore = 8
        
        genresNode = ASTextNode()
        
        imageNode = ASNetworkImageNode(webImage: ())
        imageNode.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.addSubnode(imageNode)
        self.addSubnode(streamInfoNode)
        self.addSubnode(genresNode)
    }
    
    override func fetchData() {
        super.fetchData()
        
        let transformation = CLTransformation()
        transformation.width = self.imageNode.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.imageNode.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        if let id = self.imgId, let x = _cloudinary.url(id, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            self.imageNode.URL = url
            self.imageNode.contentMode = .ScaleAspectFill
        } else {
            self.imageNode.image = Synnc.appIcon
            self.imageNode.contentMode = .Center
        }
        
        self.genresNode.attributedString = NSAttributedString(string: genreStr, attributes: self.genreAttributes)
    }
    
    func configure(stream : Stream) {
        let transformation = CLTransformation()
        transformation.width = self.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        genreStr = ""
        for (index,genre) in stream.genres.enumerate() {
            if index == 0 {
                genreStr! += genre.name
            } else {
                genreStr! += (" / " + genre.name)
            }
        }
        
        if let id = stream.img {
            self.imgId = id as String
        }
        
        self.streamInfoNode.configure(stream)
        self.fetchData()
    }
    
    override func layout() {
        super.layout()
        
        self.genresNode.position.y = self.imageNode.calculatedSize.height - 5 - self.genresNode.calculatedSize.height / 2
        self.genresNode.position.x = self.imageNode.calculatedSize.width - 5 - self.genresNode.calculatedSize.width / 2 + 25
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let overlay = ASOverlayLayoutSpec(child: ASStaticLayoutSpec(children: [genresNode]), overlay: imageNode)
        overlay.flexBasis = ASRelativeDimension(type: .Points, value: 110)
        overlay.alignSelf = .Stretch

        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [overlay, streamInfoNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25), child: vStack)
    }
}

class StreamCellInfoNode : StreamTitleNode {
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        if let x = super.layoutSpecThatFits(constrainedSize) as? ASInsetLayoutSpec {
            x.insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return x
        }
        return super.layoutSpecThatFits(constrainedSize)
    }
}