//
//  PlaylistInfoNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/26/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Shimmer

class PlaylistInfoHolder : ASDisplayNode, TrackedView {
    var infoNode : PlaylistInfoNode!
    var headerSpacer : ASDisplayNode!
    var title: String! = "Playlist Info"
    override init() {
        super.init()
        infoNode = PlaylistInfoNode()
        infoNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(infoNode)
    
        headerSpacer = ASDisplayNode()
        headerSpacer.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        headerSpacer.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 60))
        self.addSubnode(headerSpacer)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        if let x = self.supernode as? PagerBaseControllerNode
//        print("SUPER NODE", self.supernode)
        return ASStaticLayoutSpec(children: [infoNode, headerSpacer])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
//        self.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
    }
}

class PlaylistInfoSubArea : ASDisplayNode {
    var titleNode : ASTextNode!
    var contentTextNode : ASEditableTextNode!
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    lazy var titleAttributes : [String : AnyObject] = {
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        return [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : p]
    }()
    
    lazy var placeholderAttributes : [String : AnyObject] = {
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        return [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 0.5), NSKernAttributeName : 0.75, NSParagraphStyleAttributeName : p]
    }()
    lazy var contentAttributes : [String : AnyObject] = {
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        return [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : p]
    }()
    
    override init() {
        super.init()
        titleNode = ASTextNode()
        titleNode.spacingBefore = 20
        titleNode.spacingAfter = 15
        self.addSubnode(titleNode)
        
        contentTextNode = ASEditableTextNode()
        contentTextNode.scrollEnabled = false
        contentTextNode.userInteractionEnabled = false
        contentTextNode.alignSelf = .Stretch
        contentTextNode.flexGrow = true
        
        self.addSubnode(contentTextNode)
     
        tapGestureRecognizer = UITapGestureRecognizer()
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        contentTextNode.flexBasis = ASRelativeDimension(type: .Percent, value: 0.9)
        let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [contentTextNode])
        a.spacingAfter = 25
        let c = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleNode, a])
        return c
    }
}

class GenreHolder : PlaylistInfoSubArea {
    
    override init() {
        super.init()
        
        titleNode.attributedString = NSAttributedString(string: "GENRES", attributes: self.titleAttributes)
        
        self.contentTextNode.attributedPlaceholderText = NSAttributedString(string: "None Selected", attributes: self.placeholderAttributes)
    }
}

class LocationHolder : PlaylistInfoSubArea {
    
    override init() {
        super.init()
        
        titleNode.attributedString = NSAttributedString(string: "LOCATION", attributes: self.titleAttributes)
        
        self.contentTextNode.attributedPlaceholderText = NSAttributedString(string: "Allow Location", attributes: self.placeholderAttributes)
    }
}

@objc protocol PlaylistInfoDelegate {
    optional func imageForPlaylist() -> AnyObject?
    optional func titleForPlaylist() -> String?
    optional func genresForPlaylist() -> [Genre]
    optional func locationForPlaylist() -> String?
    optional func trackCountForPlaylist() -> Int
}

class PlaylistInfoNode : WCLScrollNode {
    
    var infoDelegate : PlaylistInfoDelegate?
    
    var imageShimmer : FBShimmeringView!
    var imageNode : ASNetworkImageNode!
    var titleNode : ASEditableTextNode!
    var trackCountNode : ASTextNode!
    
    var genreHolder : GenreHolder!
    var locationHolder : LocationHolder!
    
    var topSeperator : ASDisplayNode!
    var genreSeperator : ASDisplayNode!
    var locationSeperator : ASDisplayNode!
    var seperators : [ASDisplayNode!] {
        get {
            return [topSeperator, genreSeperator, locationSeperator]
        }
    }
    
    lazy var trackCountAttributes : [String : AnyObject] = {
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        return [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size: 10)!, NSForegroundColorAttributeName : UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : p]
    }()
    
    lazy var titleAttributes : [String : AnyObject] = {
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        return [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : p]
    }()
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        
        imageShimmer = FBShimmeringView()
        imageShimmer.contentView = self.imageNode.view
        
        self.addSubnode(imageNode)
        
        titleNode = ASEditableTextNode()
        titleNode.returnKeyType = UIReturnKeyType.Done
        titleNode.spacingBefore = 25
        titleNode.spacingAfter = 10
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        titleNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.45, NSParagraphStyleAttributeName : p]
        titleNode.attributedPlaceholderText = NSAttributedString(string: "Name Your Playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor.SynncColor().colorWithAlphaComponent(0.5), NSKernAttributeName : 0.45, NSParagraphStyleAttributeName : p])
        self.addSubnode(titleNode)
        
        trackCountNode = ASTextNode()
        trackCountNode.attributedString = NSAttributedString(string: "", attributes: self.trackCountAttributes)
        trackCountNode.spacingAfter = 25
        self.addSubnode(trackCountNode)
        
        topSeperator = ASDisplayNode()
        self.addSubnode(topSeperator)
        
        genreHolder = GenreHolder()
        genreHolder.alignSelf = .Stretch
        self.addSubnode(genreHolder)
        
        genreSeperator = ASDisplayNode()
        self.addSubnode(genreSeperator)
        
        locationHolder = LocationHolder()
        locationHolder.alignSelf = .Stretch
        self.addSubnode(locationHolder)
        
        locationSeperator = ASDisplayNode()
        self.addSubnode(locationSeperator)
        
        for sep in seperators {
            sep.backgroundColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.25)
            sep.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale ))
        }
    }
    
    override func fetchData() {
        super.fetchData()
        
        if let x = self.infoDelegate?.imageForPlaylist!() {
            
            if var img = x as? UIImage {

//                if img == Synnc.appIcon {
//                    img = UIImage(named: "cameraPlaceholder")!
//                }
//
                if img != self.imageNode.image {
                    self.imageNode.URL = nil
                    self.imageNode.image = img
            
                    if img.size.height < self.imageNode.calculatedSize.height && img.size.width < self.imageNode.calculatedSize.width {
                        self.imageNode.contentMode = .Center
                    } else {
                        self.imageNode.contentMode = .ScaleAspectFill
                    }
                }
            } else if let url = x as? NSURL {
                if let prevURL = self.imageNode.URL where prevURL.absoluteString == url.absoluteString {
                } else {
                    self.imageNode.URL = url
                    self.imageNode.contentMode = .ScaleAspectFill
                }
            }
        } else {
            self.imageNode.image = UIImage(named: "camera-placeholder")!
            self.imageNode.contentMode = .Center
        }
        
        if let title = self.infoDelegate?.titleForPlaylist!() {
            self.titleNode.attributedText = NSAttributedString(string: title, attributes: self.titleAttributes)
        }
        
        if let location = self.infoDelegate!.locationForPlaylist!() {
            self.locationHolder.contentTextNode.attributedText = NSAttributedString(string: location, attributes: self.locationHolder.contentAttributes)
        } else {
            self.locationHolder.contentTextNode.attributedText = NSAttributedString(string: "", attributes: self.locationHolder.contentAttributes)
        }
        
        let genres = self.infoDelegate!.genresForPlaylist!()
        var genreText = ""
        for (ind,genre) in genres.enumerate() {
            if ind == 0 {
                genreText += genre.name
            } else {
                genreText += (", " + genre.name)
            }
        }
        self.genreHolder.contentTextNode.attributedText = NSAttributedString(string: genreText, attributes: self.genreHolder.contentAttributes)
        genreHolder.setNeedsLayout()
        
        let trackCount = self.infoDelegate!.trackCountForPlaylist!()
        let trackText = "\(trackCount) Tracks"
        
        self.trackCountNode.attributedString = NSAttributedString(string: trackText, attributes: self.trackCountAttributes)
        self.setNeedsLayout()
    }
    
    override func layout() {
        super.layout()
        
        self.imageShimmer.bounds = CGRect(origin: CGPointZero, size: self.imageNode.calculatedSize)
        self.imageShimmer.center = self.imageNode.position
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        self.view.contentSize = CGSizeMake(self.calculatedSize.width, self.locationSeperator.position.y + (self.locationSeperator.calculatedSize.height / 2) + 20 + 65)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.6), ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.6))
        let imageSpec = ASStaticLayoutSpec(children: [imageNode])
        imageSpec.spacingBefore = 85
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent:.Start, alignItems: .Center, children: [imageSpec, titleNode, trackCountNode, ASStaticLayoutSpec(children: [topSeperator]), genreHolder, ASStaticLayoutSpec(children: [genreSeperator]), locationHolder, ASStaticLayoutSpec(children: [locationSeperator])])
        
        return stack
    }
}

