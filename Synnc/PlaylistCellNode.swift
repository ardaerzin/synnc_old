//
//  PlaylistCellNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/18/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit

class PlaylistCellNode : ASCellNode {
    var imageNode : ASNetworkImageNode!
    var nameNode : ASTextNode!
    var trackCountNode : ASTextNode!
    
    override init!() {
        super.init()
        
        self.imageNode = ASNetworkImageNode()
        self.imageNode.preferredFrameSize = CGSizeMake(106, 106)
        
        self.nameNode = ASTextNode()
        self.nameNode.spacingBefore = 13
        self.nameNode.maximumNumberOfLines = 1
        self.trackCountNode = ASTextNode()
        self.trackCountNode.spacingBefore = 5
        self.trackCountNode.maximumNumberOfLines = 1
        
        self.imageNode.image = UIImage(named: "camera-large")
        self.addSubnode(self.imageNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.trackCountNode)
    }
    func configureForPlaylist(playlist : SynncPlaylist) {
//        if let x = playlist.cover_pic {
//            self.imageNode.image = x
//        }
        if let name = playlist.name {
            print(name)
            self.nameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1)])
        }
//        if let songs = playlist.songs {
            self.trackCountNode.attributedString = NSAttributedString(string: "\(playlist.songs.count) tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.41)])
//        }
        
        if let urlStr = playlist.cover_url, let url = NSURL(string: urlStr) {
            self.imageNode.URL = url
        }
    }
//    func configureForArtist(artist : SynncArtist) {
//        if let x = artist.avatar, url = NSURL(string: x) {
//            self.imageNode.URL = url
//        }
//        if let name = artist.name {
//            self.usernameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10.66)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1)])
//        }
//        if let src = artist.source {
//            self.trackCountNode.attributedString = NSAttributedString(string: "@"+src.rawValue, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 9)!, NSForegroundColorAttributeName : UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)])
//        }
//    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [spacer, self.imageNode, self.nameNode, self.trackCountNode, spacer2])
        return a
    }
}