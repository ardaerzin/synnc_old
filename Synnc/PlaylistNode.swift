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
                
                
//                (self.mainScrollNode.backgroundNode as! PlaylistBackgroundNode).imageSelector.enabled = editing
//                (self.mainScrollNode.backgroundNode as! PlaylistBackgroundNode).imageSelector.userInteractionEnabled = editing
                
//                self.imageNode.userInteractionEnabled = editing
//                self.imageNode.enabled = editing
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
//        self.titleShimmer.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
        
        self.imageNode.userInteractionEnabled = false
        self.imageNode.enabled = false
        
        self.view.addSubview(self.titleShimmer)
        self.addSubnode(countTextNode)
    }
    
    override func layout() {
        super.layout()
        
//        var
//        playlistTitleNode.position.x = (playlistTitleNode.calculatedSize.width / 2) + 20
//        playlistTitleNode.position.y = (playlistTitleNode.calculatedSize.height / 2) + 50
//        print(self.playlistTitleNode.calculatedSize)
        
        countTextNode.position.x = (countTextNode.calculatedSize.width / 2) + 20
        countTextNode.position.y = (((playlistTitleNode.calculatedSize.height / 2) + 50) + (playlistTitleNode.calculatedSize.height / 2)) + 10 + (countTextNode.calculatedSize.height / 2)
    
        titleShimmer.frame = CGRect(origin: CGPointMake(20, 50), size: self.playlistTitleNode.calculatedSize)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        playlistTitleNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: 30)), ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 100)))
        return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode])
    }
}
extension PlaylistNode : MyTextNodeDelegate{
    func needsLayout() {
        self.setNeedsLayout()
    }
}



class PlaylistBackgroundNode : ParallaxBackgroundNode {
//    var imageSelector : ButtonNode!
    
//    var enableSelectionAnimation : POPBasicAnimation! {
//        get {
//            if let anim = self.imageSelector.pop_animationForKey("enableSelectionAnimation") as? POPBasicAnimation {
//                return anim
//            } else {
//                let anim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
//                anim.completionBlock = {
//                    a, finished in
//                    if ((a as! POPBasicAnimation).toValue as! CGFloat) == 1.0 {
//                        self.imageSelector.userInteractionEnabled = true
//                        self.imageSelector.enabled = true
//                    } else {
//                        self.imageSelector.userInteractionEnabled = false
//                        self.imageSelector.enabled = false
//                    }
//                }
//                self.imageSelector.pop_addAnimation(anim, forKey: "enableSelectionAnimation")
//                return anim
//            }
//        }
//    }
    
    override init(){
        super.init()
        
//        imageSelector = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
//        imageSelector.setImage(UIImage(named: "camera-large")?.resizeImage(usingWidth: 20), forState: ASControlState.Normal)
//        imageSelector.minScale = 1
//        imageSelector.enabled = false
//        imageSelector.userInteractionEnabled = false
//        imageSelector.alpha = 0
//        
//        imageSelector.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50, 50))
//        
//        self.addSubnode(imageSelector)
    }
    
//    override func layout() {
//        super.layout()
//        
//        self.imageSelector.position.x = self.calculatedSize.width - (self.imageSelector.calculatedSize.width / 2)
//        self.imageSelector.position.y = self.calculatedSize.height - (self.imageSelector.calculatedSize.height / 2)
//    }
    
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        let x = super.layoutSpecThatFits(constrainedSize)
//        return ASStaticLayoutSpec(children: [x, imageSelector])
//    }
//    
//    override func updateScrollPositions(position: CGFloat) {
//        if position < 0 {
//            POPLayerSetTranslationY(self.imageSelector.layer, -position/2)
//        } else {
//            POPLayerSetTranslationY(self.imageSelector.layer, 0)
//        }
//        super.updateScrollPositions(position)
//    }
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