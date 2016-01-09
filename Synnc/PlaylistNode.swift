//
//  PlaylistNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit

class PlaylistNode : ParallaxNode {
    
    var playlist : SynncPlaylist?
    
    var tracksTable : ASTableNode!
    var imageNode : ASNetworkImageNode! {
        get {
            return self.mainScrollNode.backgroundNode.imageNode
        }
    }
    var playlistTitleNode : ASEditableTextNode!
    var countTextNode : ASTextNode!

    lazy var addSongsButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "ADD SONGS", selectedTitleString: "ADD SONGS", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    lazy var streamButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "STREAM", selectedTitleString: "STOP STREAM", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    lazy var editButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "EDIT", selectedTitleString: "SAVE", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    
    var buttons : [ButtonNode] {
        get {
            return [addSongsButton, streamButton, editButton]
        }
    }
    
    func updateTrackCount(){
        var countString : String = "0 Tracks"
        if let p = self.playlist {
            countString = "\(p.songs.count) Tracks"
        }
        countTextNode.attributedString = NSAttributedString(string: countString, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)])
        self.setNeedsLayout()
    }
    override func fetchData() {
        super.fetchData()
        updateTrackCount()
    }
    init(playlist: SynncPlaylist?) {
        
        var table = ASTableNode(style: UITableViewStyle.Plain)
        table.alignSelf = .Stretch
        table.flexGrow = true
        table.view.separatorStyle = .None
        table.view.scrollEnabled = false
        table.clipsToBounds = true
        
        
        var bgNode = ParallaxBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: table)
        
        self.playlist = playlist
        
        self.headerNode.buttons = self.buttons
        self.tracksTable = table
        
        playlistTitleNode = ASEditableTextNode()
        playlistTitleNode.returnKeyType = UIReturnKeyType.Done
        playlistTitleNode.userInteractionEnabled = false
        playlistTitleNode.attributedPlaceholderText = NSAttributedString(string: "New Playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
        playlistTitleNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)]
        if let title = self.playlist?.name {
            playlistTitleNode.attributedText = NSAttributedString(string: title, attributes: (self.playlistTitleNode.typingAttributes as! [String : AnyObject]))
        }
        countTextNode = ASTextNode()

        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(playlistTitleNode)
        self.addSubnode(countTextNode)
    }
    
    override func layout() {
        super.layout()
        
        playlistTitleNode.position.x = (playlistTitleNode.calculatedSize.width / 2) + 20
        playlistTitleNode.position.y = (playlistTitleNode.calculatedSize.height / 2) + 50
        
        countTextNode.position.x = (countTextNode.calculatedSize.width / 2) + 20
        countTextNode.position.y = (playlistTitleNode.position.y + (playlistTitleNode.calculatedSize.height / 2)) + 10 + (countTextNode.calculatedSize.height / 2)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
        let x = super.layoutSpecThatFits(constrainedSize)
        return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode])
    }
}