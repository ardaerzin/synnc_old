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
import Shimmer

class PlaylistNode : ParallaxNode {
    
    var emptyStateNode : PlaylistEmptyNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = PlaylistEmptyNode()
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
    
    var playlist : SynncPlaylist?
    
    var tracksTable : ASTableNode!
    var imageNode : ASNetworkImageNode! {
        get {
            return self.mainScrollNode.backgroundNode.imageNode
        }
    }
    var titleShimmer : FBShimmeringView!
    var playlistTitleNode : MyTextNode!
    var countTextNode : ASTextNode!

    var editing : Bool = false {
        didSet {
            if editing != oldValue {
                self.playlistTitleNode.userInteractionEnabled = editing
                
                self.titleShimmer.shimmeringHighlightLength = 0.7
                self.titleShimmer.shimmeringPauseDuration = 0
                
                self.titleShimmer.shimmering = editing
                self.mainScrollNode.backgroundNode.editing = editing
            
            }
        }
    }
    
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
        } else {
            print("YOKH PLAYLIST")
        }
        countTextNode.attributedString = NSAttributedString(string: countString, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)])
        self.setNeedsLayout()
    }
    override func fetchData() {
        super.fetchData()
        updateTrackCount()
    }
    init(playlist: SynncPlaylist?) {
        
        let table = ASTableNode(style: UITableViewStyle.Plain)
        table.alignSelf = .Stretch
        table.flexGrow = true
        table.view.separatorStyle = .None
        table.view.scrollEnabled = false
        table.clipsToBounds = true
        
        
        let bgNode = PlaylistBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: table)
        
        self.playlist = playlist
        
        self.headerNode.buttons = self.buttons
        self.tracksTable = table
        
        playlistTitleNode = MyTextNode()
        playlistTitleNode.layoutDelegate = self
        playlistTitleNode.returnKeyType = UIReturnKeyType.Done
        playlistTitleNode.userInteractionEnabled = false
        playlistTitleNode.attributedPlaceholderText = NSAttributedString(string: "New Playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
        playlistTitleNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)]
        
        if let title = self.playlist?.name {
            playlistTitleNode.attributedText = NSAttributedString(string: title, attributes: (self.playlistTitleNode.typingAttributes as [String : AnyObject]!))
        }
        countTextNode = ASTextNode()

        self.backgroundColor = UIColor.whiteColor()
     
        self.titleShimmer = FBShimmeringView()
        self.titleShimmer.contentView = self.playlistTitleNode.view
        
        self.imageNode.userInteractionEnabled = false
        self.imageNode.enabled = false

        
        self.view.addSubview(self.titleShimmer)
        self.addSubnode(countTextNode)
    }
    
    override func didScroll(position: CGFloat) {
        super.didScroll(position)
        if let esn = self.emptyStateNode {
            POPLayerSetTranslationY(esn.layer, -position)
        }
    }
    
    
    override func layout() {
        super.layout()
        
        emptyStateNode?.position.y = self.calculatedSize.width + (emptyStateNode.calculatedSize.height / 2)
        
        countTextNode.position.x = (countTextNode.calculatedSize.width / 2) + 20
        countTextNode.position.y = (((playlistTitleNode.calculatedSize.height / 2) + 50) + (playlistTitleNode.calculatedSize.height / 2)) + 10 + (countTextNode.calculatedSize.height / 2)
    
        titleShimmer.frame = CGRect(origin: CGPointMake(20, 50), size: self.playlistTitleNode.calculatedSize)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        playlistTitleNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: 30)), ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 100)))
        
        self.emptyStateNode?.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - constrainedSize.max.width - 50))
        
        if self.emptyStateNode == nil {
            return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode])
        } else {
            return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode, self.emptyStateNode])
        }
    }
}
extension PlaylistNode : MyTextNodeDelegate{
    func needsLayout() {
        self.setNeedsLayout()
    }
    func tf_becomeFirstResponder() {
        
    }
    func tf_resignFirstResponder() {
        
    }
}



class PlaylistBackgroundNode : ParallaxBackgroundNode {
    override init(){
        super.init()
    }
}




protocol MyTextNodeDelegate {
    func needsLayout()
}


class MyTextNode : ASEditableTextNode {
    var layoutDelegate : MyTextNodeDelegate?
    var hh : CGFloat = 0 {
        didSet {
            if hh != oldValue {
                self.layoutDelegate?.needsLayout()
            }
        }
    }
    var ww : CGFloat = 0 {
        didSet {
            if ww != oldValue {
                self.layoutDelegate?.needsLayout()
            }
        }
    }
    override func invalidateCalculatedLayout() {
        super.invalidateCalculatedLayout()
        self.measureWithSizeRange(self.constrainedSizeForCalculatedLayout)
        if self.calculatedSize.height != self.hh {
            self.hh = self.calculatedSize.height
        }
    }
    
    override func layout() {
        super.layout()
    }
}