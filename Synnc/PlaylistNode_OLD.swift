////
////  PlaylistCreateNode.swift
////  Synnc
////
////  Created by Arda Erzin on 12/14/15.
////  Copyright © 2015 Arda Erzin. All rights reserved.
////
//
//import Foundation
//import UIKit
//import WCLUIKit
//import WCLUtilities
//import AsyncDisplayKit
//import pop
//import SpinKit
//import WCLUserManager
//import DeviceKit
//
//protocol PlaylistNodeDelegate {
//    func imageForPlaylist() -> AnyObject?
//}
//class BackgroundImageNode : ASScrollNode {
//    var imageNode : ASNetworkImageNode!
//    override init!() {
//        super.init()
//        self.imageNode = ASNetworkImageNode()
//        self.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        self.addSubnode(self.imageNode)
//        self.view.scrollEnabled = false
//        self.clipsToBounds = false
//    }
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
//        return ASStaticLayoutSpec(children: [self.imageNode])
//    }
//}
//class PlaylistScrollNode : ASScrollNode, UIScrollViewDelegate {
//    var backgroundNode : BackgroundImageNode!
//    var tracksTable : ASTableNode!
//    var imageGradientNode : ASImageNode!
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let position: CGFloat = scrollView.contentOffset.y
//        var delta : CGFloat = 0
//        let limit : CGFloat = self.calculatedSize.width - 150
//        let x = (self.view.frame.size.height / 2 - 200 / 2) + self.view.frame.size.width
//        var bgScalePosition : CGFloat = 0
//        if scrollView.contentOffset.y < 0 {
//            self.backgroundNode.view.setContentOffset(CGPointMake(0, 0), animated: false)
//            let y = 1 + abs(position / self.calculatedSize.width)
//            bgScalePosition = position / 2
//            POPLayerSetScaleXY(self.backgroundNode.imageNode.layer, CGPointMake(y, y))
//            self.tracksTable.position.y = x
//        } else {
//            delta = max(0,position - limit)
//            let sp = min(limit * 0.25, max(0,position) * 0.25)
//            self.tracksTable.position.y = x + delta
//            self.backgroundNode.view.setContentOffset(CGPointMake(0, sp), animated: false)
//            self.tracksTable.view.contentOffset = CGPointMake(0, delta)
//        }
//        self.backgroundNode.position.y = (self.backgroundNode.calculatedSize.height / 2) + position - bgScalePosition
//        self.imageGradientNode.position.y = (self.backgroundNode.calculatedSize.height / 2) + position
//    }
//    
//    override init!() {
//        super.init()
//        
//        self.backgroundNode = BackgroundImageNode()
//        
//        imageGradientNode = ASImageNode()
//        imageGradientNode.image = UIImage(named: "imageGradient")
//
//        tracksTable = ASTableNode(style: UITableViewStyle.Plain)
//        tracksTable.alignSelf = .Stretch
//        tracksTable.flexGrow = true
//        tracksTable.view.separatorStyle = .None
//        tracksTable.view.scrollEnabled = false
//        tracksTable.clipsToBounds = true
//
//        self.addSubnode(backgroundNode)
//        self.addSubnode(imageGradientNode)
//        self.addSubnode(tracksTable)
//    }
//    override func didLoad() {
//        super.didLoad()
//        self.view.delegate = self
//    }
//    override func layout() {
//        super.layout()
//        self.scrollViewDidScroll(self.view)
//    }
//    
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
//        self.tracksTable.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - 200))
//        imageGradientNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
//        return ASStaticLayoutSpec(children: [backgroundNode, imageGradientNode, tracksTable])
//    }
//}
//class PlaylistNode : ASDisplayNode {
//    
//    var playlist : SynncPlaylist?
// 
//    var delegate : PlaylistNodeDelegate?
//    var mainScrollNode : PlaylistScrollNode!
//    
//    var headerNode : SmallHeaderNode!
//    var imageNode : ASNetworkImageNode! {
//        get {
//            return self.mainScrollNode.backgroundNode.imageNode
//        }
//    }
//    var playlistTitleNode : ASEditableTextNode!
//    var countTextNode : ASTextNode!
//
//    var addSongsButton : ButtonNode!
//    var streamButton : ButtonNode!
//    var editButton : ButtonNode!
//
//    var tracksTable : ASTableNode! {
//        get {
//            return self.mainScrollNode.tracksTable
//        }
//    }
//    
//    init(playlist : SynncPlaylist?) {
//        super.init()
//        self.playlist = playlist
//        
//        addSongsButton = TitleColorButton(normalTitleString: "ADD SONGS", selectedTitleString: "ADD SONGS", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
//        streamButton = TitleColorButton(normalTitleString: "STREAM", selectedTitleString: "STOP STREAM", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
//        editButton = TitleColorButton(normalTitleString: "EDIT", selectedTitleString: "SAVE", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
//
//        self.headerNode = SmallHeaderNode(buttons: [addSongsButton, streamButton, editButton])
//        headerNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 35))
//        
//        self.backgroundColor = UIColor.whiteColor()
//        
//        mainScrollNode = PlaylistScrollNode()
//        mainScrollNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        
//        imageNode.userInteractionEnabled = false
//        imageNode.enabled = false
//        imageNode.contentMode = .Center
//        
//        playlistTitleNode = ASEditableTextNode()
//        playlistTitleNode.returnKeyType = UIReturnKeyType.Done
//        playlistTitleNode.userInteractionEnabled = false
//        playlistTitleNode.attributedPlaceholderText = NSAttributedString(string: "New Playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
//        playlistTitleNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)]
//        
//        countTextNode = ASTextNode()
//
//        self.addSubnode(mainScrollNode)
//        self.addSubnode(headerNode)
//        self.addSubnode(playlistTitleNode)
//        self.addSubnode(countTextNode)
//    }
//
//    override func didLoad() {
//        super.didLoad()
//    }
//    func updateTrackCount(){
//        var countString : String = "0 Tracks"
//        if let p = self.playlist {
//            countString = "\(p.songs.count) Tracks"
//        }
//        countTextNode.attributedString = NSAttributedString(string: countString, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)])
//        countTextNode.setNeedsLayout()
//    }
//    override func fetchData() {
//        super.fetchData()
//        
//        if self.playlist == nil {
//            return
//        }
//
//        updateTrackCount()
//
//        if let imgData = self.delegate?.imageForPlaylist() {
//            if let url = imgData as? NSURL {
//                imageNode.URL = url
//                imageNode.contentMode = .ScaleAspectFill
//            } else if let img = imgData as? UIImage {
//                imageNode.URL = nil
//                imageNode.image = img
//                imageNode.contentMode = .ScaleAspectFill
//            } else {
//                imageNode.URL = nil
//                imageNode.image = UIImage(named: "camera-large")
//                imageNode.contentMode = .Center
//            }
//        } else {
//            imageNode.image = UIImage(named: "camera-large")
//            imageNode.contentMode = .Center
//        }
//    }
//    override func layout() {
//        super.layout()
//        
//        playlistTitleNode.position.x = (playlistTitleNode.calculatedSize.width / 2) + 20
//        playlistTitleNode.position.y = (playlistTitleNode.calculatedSize.height / 2) + 50
//        
//        countTextNode.position.x = (countTextNode.calculatedSize.width / 2) + 20
//        countTextNode.position.y = (playlistTitleNode.position.y + (playlistTitleNode.calculatedSize.height / 2)) + 10 + (countTextNode.calculatedSize.height / 2)
//    }
//
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec! {
//        let spacer = ASLayoutSpec()
//        spacer.flexGrow = true
//        
//        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: constrainedSize.max.width))
//        tracksTable.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        
//        let imageSpec = ASStaticLayoutSpec(children: [mainScrollNode, headerNode, playlistTitleNode, countTextNode])
//        
//        return imageSpec
//    }
//}