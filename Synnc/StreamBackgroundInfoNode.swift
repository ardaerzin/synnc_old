//
//  StreamBackgroundInfoNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager
import Shimmer

class StreamBackgroundInfoNode : ASDisplayNode {
    
    var titleShimmer : FBShimmeringView!
    var syncShimmer : FBShimmeringView!
    
    var playingIcon : AnimatedLogoNode!
    var streamTitle : ASEditableTextNode!
    var startStreamButton : ButtonNode!
    var locationToggle : TitleColorButton!
    var genreToggle : TitleColorButton!
    
    var streamStatusButton : TitleColorButton!
    var addToFavoritesButton : ButtonNode!
    var trackTitle : ASTextNode!
    var artistTitle : ASTextNode!
    
    var titleSizeHeight : CGFloat! {
        didSet {
            if let old = oldValue where titleSizeHeight != old {
                self.titleOffset = titleSizeHeight - old
            }
        }
    }
    var titleOffset : CGFloat! = 0
    
    var paragraphAttributes : NSMutableParagraphStyle = {
        let x = NSMutableParagraphStyle()
        x.alignment = .Center
        return x
    }()
    
    var trackAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 36)!, NSForegroundColorAttributeName : UIColor(red: 230/255, green: 228/255, blue: 228/255, alpha: 1), NSKernAttributeName : 0.4]
    var artistAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size : 14)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 0.7), NSKernAttributeName : 0.2]
    var buttonAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 10)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1)]
    var genreAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 10)!, NSForegroundColorAttributeName : UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1), NSKernAttributeName : 1.1]
    
    var trackUpdateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamBackgroundInfoNode).trackUpdateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamBackgroundInfoNode).trackUpdateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var trackUpdateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("trackUpdateAnimation") as? POPBasicAnimation {
                return anim
            } else {
                let x = POPBasicAnimation()
                //                x.springBounciness = 0
                x.duration = 0.2
                x.property = self.trackUpdateAnimatableProperty
                self.pop_addAnimation(x, forKey: "trackUpdateAnimation")
                return x
            }
        }
    }
    var trackUpdateAnimationProgress : CGFloat = 1 {
        didSet {
            self.trackTitle.alpha = trackUpdateAnimationProgress
            if let x = self.supernode as? StreamBackgroundNode, let z = x.animationAlphaValues[self.artistTitle] {
                let a = min(z,trackUpdateAnimationProgress)
                self.artistTitle.alpha = a
            }
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let x = super.hitTest(point, withEvent: event)
        if x == self.view {
            return nil
        } else {
            return x
        }
    }
    
    override init() {
        super.init()
        
        trackAttributes[NSParagraphStyleAttributeName] = paragraphAttributes
        
        artistTitle = ASTextNode()
        artistTitle.maximumNumberOfLines = 1
        artistTitle.alpha = 0
        
        trackTitle = ASTextNode()
        trackTitle.alpha = 0
        trackTitle.spacingAfter = 5
        trackTitle.alignSelf = .Stretch
        trackTitle.maximumNumberOfLines = 2
        
        streamStatusButton = TitleColorButton(normalTitleString: "START STREAMING", selectedTitleString: "START STREAMING", attributes: buttonAttributes, normalColor: .whiteColor(), selectedColor: .whiteColor())
        streamStatusButton.backgroundColor = UIColor.SynncColor()
        streamStatusButton.normalBgColor = UIColor.SynncColor()
        streamStatusButton.selectedBgColor = UIColor.SynncColor()
        
        
        streamStatusButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
        streamStatusButton.cornerRadius = 3
        streamStatusButton.alpha = 0
        
        addToFavoritesButton = ButtonNode()
        addToFavoritesButton.cornerRadius = 3
        addToFavoritesButton.borderColor = UIColor.whiteColor().CGColor
        addToFavoritesButton.borderWidth = 1
        addToFavoritesButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
        addToFavoritesButton.setAttributedTitle(NSAttributedString(string: "ADD TO FAVORITES", attributes: buttonAttributes), forState: ASControlState.Normal)
        addToFavoritesButton.alpha = 0
        
        streamTitle = ASEditableTextNode()
        streamTitle.alpha = 0
        streamTitle.returnKeyType = UIReturnKeyType.Done
        streamTitle.attributedPlaceholderText = NSAttributedString(string: "Enter Stream Name", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 230/255, green: 228/255, blue: 228/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : self.paragraphAttributes])
        streamTitle.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSParagraphStyleAttributeName : self.paragraphAttributes, NSKernAttributeName : 0.3]
        
        titleShimmer = FBShimmeringView()
        titleShimmer.contentView = streamTitle.view
        
        syncShimmer = FBShimmeringView()
        syncShimmer.contentView = self.view
        
        startStreamButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        startStreamButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
        startStreamButton.alpha = 0
        startStreamButton.cornerRadius = 3
        startStreamButton.setAttributedTitle(NSAttributedString(string: "START STREAMING", attributes: buttonAttributes), forState: ASControlState.Normal)
        
        playingIcon = AnimatedLogoNode(barCount: 5)
        playingIcon.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30, 35))
        playingIcon.alpha = 0
        
        genreToggle = TitleColorButton(normalTitleString: "PICK GENRE(S)", selectedTitleString: "", attributes: self.genreAttributes, normalColor: UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1), selectedColor: UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1))
        genreToggle.alpha = 0
        
        locationToggle = TitleColorButton(normalTitleString: "SHOW LOCATION", selectedTitleString: "SECTOOR", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSKernAttributeName : 0.3], normalColor: UIColor.whiteColor(), selectedColor: UIColor.whiteColor())
        locationToggle.alpha = 0
        
        self.addSubnode(trackTitle)
        self.addSubnode(artistTitle)
        self.addSubnode(streamStatusButton)
        self.addSubnode(addToFavoritesButton)
        
        self.addSubnode(streamTitle)
        self.addSubnode(startStreamButton)
        self.addSubnode(locationToggle)
        self.addSubnode(genreToggle)
        self.addSubnode(playingIcon)
    }
    
    func updateForTrack(track : SynncTrack) {
        var str = ""
        for (index,artist) in track.artists.enumerate() {
            if index == 0 {
                str += artist.name
            } else {
                str += (" / " + artist.name)
            }
        }
        
        self.trackUpdateAnimation.completionBlock = {
            anim, finished in
            self.trackTitle.attributedString = NSAttributedString(string: track.name, attributes: self.trackAttributes)
            self.artistTitle.attributedString = NSAttributedString(string: str, attributes: self.artistAttributes)
            self.setNeedsLayout()
            
            if let x = self.supernode as? StreamBackgroundNode {
                x.updateScrollPositions(x.scrollPosition)
            }
            self.trackUpdateAnimation.toValue = 1
        }
        
        self.trackUpdateAnimation.toValue = 0
    }
    override func layout() {
        super.layout()
        
        titleShimmer.frame = self.bounds
        syncShimmer.frame = self.bounds
        
        let h = (streamTitle.calculatedSize.height + self.startStreamButton.calculatedSize.height + 41) / 2
        streamTitle.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 - h)
        startStreamButton.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 + h)
        
        locationToggle.position = CGPointMake((locationToggle.calculatedSize.width / 2) + 23, (calculatedSize.height) - 37 - locationToggle.calculatedSize.height / 2)
        genreToggle.position = CGPointMake((genreToggle.calculatedSize.width / 2) + 23, (calculatedSize.height) - 19 - genreToggle.calculatedSize.height / 2)
        
        
        self.streamStatusButton.position.x = self.calculatedSize.width / 2
        self.streamStatusButton.position.y = self.calculatedSize.height / 2 + self.streamStatusButton.calculatedSize.height / 2 + 20
        
        self.addToFavoritesButton.position.x = self.calculatedSize.width / 2
        self.addToFavoritesButton.position.y = self.streamStatusButton.position.y
        //            + self.streamStatusButton.calculatedSize.height / 2 + self.addToFavoritesButton.calculatedSize.height / 2 + 20
        
        self.trackTitle.position.x = self.calculatedSize.width / 2
        self.trackTitle.position.y = self.calculatedSize.height / 2 - 60 - self.artistTitle.calculatedSize.height / 2
        
        self.artistTitle.position.x = self.calculatedSize.width / 2
        self.artistTitle.position.y = self.trackTitle.position.y + self.trackTitle.calculatedSize.height / 2 + self.artistTitle.calculatedSize.height / 2 + 5
        
        
        let z1 = (self.trackTitle.position.y - self.trackTitle.calculatedSize.height / 2) + (self.artistTitle.position.y + self.artistTitle.calculatedSize.height / 2)
        
        self.playingIcon.position.x = self.calculatedSize.width - (self.playingIcon.calculatedSize.width / 2)
        self.playingIcon.position.y = z1 / 2
        
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        titleSizeHeight = self.trackTitle.calculatedSize.height
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let statusButtonSpec = ASStaticLayoutSpec(children: [streamStatusButton])
        statusButtonSpec.spacingAfter = 20
        self.trackTitle.sizeRange = ASRelativeSizeRangeMake(ASRelativeSizeMake(ASRelativeDimension(type: .Percent, value: 0.8), ASRelativeDimension(type: .Points, value: 0)), ASRelativeSizeMake(ASRelativeDimension(type: .Percent, value: 0.8), ASRelativeDimension(type: .Points, value: 100)))
        
        return ASStaticLayoutSpec(children: [streamTitle, startStreamButton, locationToggle, genreToggle, streamStatusButton, addToFavoritesButton, trackTitle, artistTitle, playingIcon])
    }
}