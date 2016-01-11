//
//  StreamBackgroundNode.swift
//  Synnc
//
//  Created by Arda Erzin on 1/3/16.
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

enum StreamBackgroundNodeState : Int {
    case Create = -1
    case ReadyToPlay = 1
    case Play = 2
    case Hidden = 0
}

class StreamInfoNode : ASDisplayNode {
    
    var titleShimmer : FBShimmeringView!
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
                print("did change title height")
                self.titleOffset = titleSizeHeight - old
            }
        }
    }
    var titleOffset : CGFloat! = 0 {
        didSet {
            if titleOffset != oldValue {
                print("did set titleOffset")
            }
            print("did set title offset")
        }
    }
    
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
                    values[0] = (obj as! StreamInfoNode).trackUpdateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamInfoNode).trackUpdateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var trackUpdateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("trackUpdateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.springBounciness = 0
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
//                print(z)
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
            
        trackTitle = ASTextNode()
        trackTitle.spacingAfter = 5
        trackTitle.alignSelf = .Stretch
        trackTitle.maximumNumberOfLines = 2
        
        streamStatusButton = TitleColorButton(normalTitleString: "START STREAMING", selectedTitleString: "STOP STREAMING", attributes: buttonAttributes, normalColor: .whiteColor(), selectedColor: .whiteColor())
        streamStatusButton.backgroundColor = UIColor.SynncColor()
        streamStatusButton.normalBgColor = UIColor.SynncColor()
        streamStatusButton.selectedBgColor = UIColor.SynncColor()
        
        
        streamStatusButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
//        streamStatusButton.setAttributedTitle(NSAttributedString(string: "STOP STREAMING", attributes: buttonAttributes), forState: ASControlState.Normal)
        streamStatusButton.cornerRadius = 3
        
        addToFavoritesButton = ButtonNode()
        addToFavoritesButton.cornerRadius = 3
        addToFavoritesButton.borderColor = UIColor.whiteColor().CGColor
        addToFavoritesButton.borderWidth = 1
        addToFavoritesButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
        addToFavoritesButton.setAttributedTitle(NSAttributedString(string: "ADD TO FAVORITES", attributes: buttonAttributes), forState: ASControlState.Normal)
        addToFavoritesButton.alpha = 0
        
        streamTitle = ASEditableTextNode()
        streamTitle.returnKeyType = UIReturnKeyType.Done
        streamTitle.attributedPlaceholderText = NSAttributedString(string: "Enter Stream Name", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 230/255, green: 228/255, blue: 228/255, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : self.paragraphAttributes])
        streamTitle.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size : 28)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSParagraphStyleAttributeName : self.paragraphAttributes, NSKernAttributeName : 0.3]
        
        titleShimmer = FBShimmeringView()
        titleShimmer.contentView = streamTitle.view
        
        startStreamButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        startStreamButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(162, 35))
        startStreamButton.cornerRadius = 3
        startStreamButton.setAttributedTitle(NSAttributedString(string: "START STREAMING", attributes: buttonAttributes), forState: ASControlState.Normal)
        
        playingIcon = AnimatedLogoNode(barCount: 5)
        playingIcon.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(30, 35))
        playingIcon.alpha = 0
        
        genreToggle = TitleColorButton(normalTitleString: "PICK GENRE(S)", selectedTitleString: "", attributes: self.genreAttributes, normalColor: UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1), selectedColor: UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1))
        locationToggle = TitleColorButton(normalTitleString: "SHOW LOCATION", selectedTitleString: "SECTOOR", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSKernAttributeName : 0.3], normalColor: UIColor.whiteColor(), selectedColor: UIColor.whiteColor())
        
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
            
            print("sex",self.supernode)
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
        
        let h = (streamTitle.calculatedSize.height + self.startStreamButton.calculatedSize.height + 41) / 2
        streamTitle.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 - h)
        startStreamButton.position = CGPointMake(self.calculatedSize.width / 2, self.calculatedSize.height / 2 + h)
        
        let h2 = self.trackTitle.calculatedSize.height + self.artistTitle.calculatedSize.height + 26 + self.streamStatusButton.calculatedSize.height + 20 + self.addToFavoritesButton.calculatedSize.height
        locationToggle.position = CGPointMake((locationToggle.calculatedSize.width / 2) + 23, (calculatedSize.height) - 37 - locationToggle.calculatedSize.height / 2)
        genreToggle.position = CGPointMake((genreToggle.calculatedSize.width / 2) + 23, (calculatedSize.height) - 19 - genreToggle.calculatedSize.height / 2)
        
        
        self.streamStatusButton.position.x = self.calculatedSize.width / 2
        self.streamStatusButton.position.y = self.calculatedSize.height / 2 + self.streamStatusButton.calculatedSize.height / 2 + 20
        
        self.addToFavoritesButton.position.x = self.calculatedSize.width / 2
        self.addToFavoritesButton.position.y = self.streamStatusButton.position.y + self.streamStatusButton.calculatedSize.height / 2 + self.addToFavoritesButton.calculatedSize.height / 2 + 20
        
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
class StreamBackgroundNode : ParallaxBackgroundNode {
    
    var infoNode : StreamInfoNode!
    var animationAlphaValues : [NSObject : CGFloat] = [NSObject : CGFloat]()
    
    var scrollPosition : CGFloat = 0
    var trackTitlePositionY : CGFloat! {
        didSet {
            if oldValue != nil && trackTitlePositionY != oldValue {
                print("trackTitle position y has changed")
            }
        }
    }
    var trackTranslationY : CGFloat = 0
    
    
    var playingStateAnimation : POPBasicAnimation! {
        get {
            if let anim = self.infoNode.playingIcon.pop_animationForKey("playingStateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                x.duration = 0.2
                self.infoNode.playingIcon.pop_addAnimation(x, forKey: "playingStateAnimation")
                return x
            }
        }
    }
    var playingState : Bool! {
        didSet {
            if playingState != oldValue {
                if playingState! {
                    self.playingStateAnimation.toValue = 1
                    self.infoNode.playingIcon.startAnimation()
                } else {
                    self.playingStateAnimation.toValue = 0
                    self.infoNode.playingIcon.stopAnimation()
                }
                
                self.infoNode.streamStatusButton.selected = playingState
                print("playing state changed")
            }
        }
    }
    var state : StreamBackgroundNodeState! {
        didSet {
            if state != oldValue {
                if let old = oldValue {
                    self.stateAnimation.fromValue = old.rawValue
                }
                self.stateAnimation.toValue = state.rawValue
            }
        }
    }
    override var editing : Bool {
        didSet {
            if editing != oldValue {
                self.updateEditingState()
            }
        }
    }
    
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamBackgroundNode).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamBackgroundNode).stateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.duration = 0.5
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = -2 {
        didSet {
            
            self.infoNode.trackTitle.alpha = stateAnimationProgress
            self.infoNode.artistTitle.alpha = stateAnimationProgress
            
            print(stateAnimationProgress-1)
            self.infoNode.addToFavoritesButton.alpha = (stateAnimationProgress-1)
            
            self.infoNode.streamTitle.alpha = -stateAnimationProgress + 1
            self.infoNode.startStreamButton.alpha = -stateAnimationProgress
            
            print("!*!*!*!**!*!", fabs(stateAnimationProgress))
            animationAlphaValues[infoNode.genreToggle] = fabs(stateAnimationProgress)
            animationAlphaValues[infoNode.locationToggle] = fabs(stateAnimationProgress)
            animationAlphaValues[infoNode.streamStatusButton] = stateAnimationProgress
            
            
            if self.scrollPosition > 0 {
                let limit : CGFloat = self.calculatedSize.width - 150
                let percentage = scrollPosition/limit
                
                self.infoNode.locationToggle.alpha = min( 1 - min(0.5,percentage)*2, animationAlphaValues[infoNode.locationToggle]!)
                self.infoNode.genreToggle.alpha = min( 1 - min(0.5,percentage)*2, animationAlphaValues[infoNode.genreToggle]!)
            } else {
                self.infoNode.locationToggle.alpha = fabs(stateAnimationProgress)
                self.infoNode.genreToggle.alpha = fabs(stateAnimationProgress)
            }
//            self.infoNode.locationToggle.alpha = fabs(stateAnimationProgress)
//            self.infoNode.genreToggle.alpha = fabs(stateAnimationProgress)
            
            
            self.infoNode.streamStatusButton.alpha = stateAnimationProgress
        }
    }
    var locationUpdateAnimation : POPBasicAnimation! {
        get {
            if let anim = self.infoNode.locationToggle.pop_animationForKey("locationUpdateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                x.duration = 0.2
                self.infoNode.locationToggle.pop_addAnimation(x, forKey: "locationUpdateAnimation")
                return x
            }
        }
    }
    var genreUpdateAnimation : POPBasicAnimation! {
        get {
            if let anim = self.infoNode.genreToggle.pop_animationForKey("genreUpdateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
                x.duration = 0.2
                self.infoNode.genreToggle.pop_addAnimation(x, forKey: "genreUpdateAnimation")
                return x
            }
        }
    }
    
        override init() {
        super.init()

        self.view.delaysContentTouches = false
        self.infoNode = StreamInfoNode()
        
        self.addSubnode(self.infoNode)
        
        self.updateEditingState()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.infoNode.streamTitle.resignFirstResponder()
    }
    
    func configure(stream : Stream){
        var cityString : String = ""
        if let city = stream.city {
            cityString = city as String
        } else {
            cityString = "No Location Info"
        }
        self.infoNode.locationToggle.selectedTitle = NSAttributedString(string: cityString, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSKernAttributeName : 0.3, NSForegroundColorAttributeName : UIColor.whiteColor()])
        self.infoNode.locationToggle.selected = true
        
        var genreString : String = ""
        if !stream.genres.isEmpty {
            for (index,genre) in stream.genres.enumerate() {
                if index == 0 {
                    genreString += genre.name
                } else {
                    genreString += (" / " + genre.name)
                }
            }
        } else {
            genreString = "No Genre Info"
        }
        self.infoNode.genreToggle.setAttributedTitle(NSAttributedString(string: genreString, attributes: self.infoNode.genreAttributes), forState: ASControlState.Normal)
    }
    func updateGenres(genres: [Genre]) {
        genreUpdateAnimation.completionBlock = {
            anim, finished in
            var str = ""
            for (index,genre) in genres.enumerate() {
                if index == 0 {
                    str += genre.name
                } else {
                    str += (" / " + genre.name)
                }
            }
            self.genreUpdateAnimation.completionBlock = {
                anim, finished in
                self.infoNode.genreToggle.pop_removeAnimationForKey("genreUpdateAnimation")
            }
            self.infoNode.genreToggle.setAttributedTitle(NSAttributedString(string: str, attributes: self.infoNode.genreAttributes), forState: ASControlState.Normal)
            self.infoNode.genreToggle.setNeedsLayout()
            self.genreUpdateAnimation.toValue = 1
        }
        genreUpdateAnimation.toValue = 0
    }
    func updateLocation(city: String? = nil, status: Bool){
        locationUpdateAnimation.completionBlock = {
            anim, finished in
            if let str = city {
                self.infoNode.locationToggle.selectedTitle = NSAttributedString(string: str, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSKernAttributeName : 0.3, NSForegroundColorAttributeName : UIColor.whiteColor()])
            }
            self.locationUpdateAnimation.completionBlock = {
                anim, finished in
                self.infoNode.locationToggle.pop_removeAnimationForKey("locationUpdateAnimation")
            }
            self.infoNode.locationToggle.selected = status
            self.infoNode.locationToggle.setNeedsLayout()
            self.locationUpdateAnimation.toValue = 1
        }
        locationUpdateAnimation.toValue = 0
    }
    func updateForTrack(track : SynncTrack) {
        self.infoNode.updateForTrack(track)
    }
    
    func updateEditingState(){
        self.infoNode.streamTitle.userInteractionEnabled = editing
        self.infoNode.locationToggle.enabled = editing
        self.infoNode.locationToggle.userInteractionEnabled = editing
        self.infoNode.startStreamButton.enabled = editing
        self.infoNode.startStreamButton.userInteractionEnabled = editing
        self.infoNode.genreToggle.enabled = editing
        self.infoNode.genreToggle.userInteractionEnabled = editing
        self.infoNode.titleShimmer.shimmering = editing
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = super.layoutSpecThatFits(constrainedSize)
        self.infoNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(constrainedSize.max)
        return ASStaticLayoutSpec(children: [x, self.infoNode])
    }
    
    override func updateScrollPositions(position: CGFloat) {
        
        self.scrollPosition = position
        super.updateScrollPositions(position)
        
        var delta : CGFloat = 0
        let limit : CGFloat = self.calculatedSize.width - 150
        delta = -max(0,position - limit)
    
        let moveShit = position + (-position / 2)
        
        let percentage = position/limit
        
        if let locationAnimVal = animationAlphaValues[infoNode.locationToggle] {
            self.infoNode.locationToggle.alpha = min( 1 - min(0.5,percentage)*2, locationAnimVal)
        }
        if let genreAnimVal = animationAlphaValues[infoNode.genreToggle] {
//            print("shit", min( 1 - min(0.5,percentage)*2, genreAnimVal))
            self.infoNode.genreToggle.alpha = min( 1 - min(0.5,percentage)*2, genreAnimVal)
        }
        
        let title = self.infoNode.streamTitle
        let a = (position + (-position / 2))
        let titleLimit = title.calculatedSize.height / 2 + 40
        if moveShit <= (title.position.y - titleLimit) && percentage < 1 {
            POPLayerSetTranslationY(title.layer, position/2)
        } else if moveShit <= (title.position.y - titleLimit) && percentage >= 1 {
            POPLayerSetTranslationY(title.layer, limit - a)
        } else {
            let pos = (limit - (limit/2))
            let b = pos < (title.position.y - titleLimit)
            if !b {
                let z = moveShit - (title.position.y - titleLimit)
                POPLayerSetTranslationY(title.layer, position/2 + z + delta)
            }
        }
        
        let button = self.infoNode.startStreamButton
        let buttonLimit = button.calculatedSize.height / 2 + titleLimit + 40
        let c = (position + (-position / 3))
        if c <= (button.position.y - buttonLimit) && percentage < 1 {
            POPLayerSetTranslationY(button.layer, position/3)
        } else if c <= (button.position.y - buttonLimit) && percentage >= 1 {
            POPLayerSetTranslationY(button.layer, limit - c)
        } else {
            let pos = (limit - (limit/3))
            let b = pos < (button.position.y - buttonLimit)
            if !b {
                let z = c - (button.position.y - buttonLimit)
                POPLayerSetTranslationY(button.layer, position/3 + z + delta)
            }
        }
       
        if self.state == .Play {
            if let statusAnimVal = animationAlphaValues[self.infoNode.streamStatusButton] {
                self.infoNode.streamStatusButton.alpha = min( 1 - min(0.5,percentage)*2, statusAnimVal)
                self.infoNode.artistTitle.alpha = min( 1 - min(0.5,percentage)*2, statusAnimVal)
                animationAlphaValues[self.infoNode.artistTitle] = self.infoNode.artistTitle.alpha
            }
            
            let trackT = self.infoNode.trackTitle
            let trackTitleLimit = trackT.calculatedSize.height / 2 + 20
            let e = (position + (-position / 3))
            if e <= (trackT.position.y - trackTitleLimit) && percentage < 1 {
                POPLayerSetTranslationY(trackT.layer, position/3)
                POPLayerSetTranslationY(self.infoNode.playingIcon.layer, position/3)
            } else if e <= (trackT.position.y - trackTitleLimit) && percentage >= 1 {
                POPLayerSetTranslationY(trackT.layer, limit - e)
                POPLayerSetTranslationY(self.infoNode.playingIcon.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (trackT.position.y - trackTitleLimit)
                if !b {
                    let z = e - (trackT.position.y - trackTitleLimit)
                    POPLayerSetTranslationY(trackT.layer, position/3 + z + delta)
                    POPLayerSetTranslationY(self.infoNode.playingIcon.layer, position/3 + z + delta)
                }
            }

            let artistT = self.infoNode.artistTitle
            let artistTitleLimit = trackTitleLimit + trackT.calculatedSize.height / 2 + 5 + artistT.calculatedSize.height / 2
            if e <= (artistT.position.y - artistTitleLimit) && percentage < 1 {
                POPLayerSetTranslationY(artistT.layer, position/3)
            } else if e <= (artistT.position.y - artistTitleLimit) && percentage >= 1 {
                POPLayerSetTranslationY(artistT.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (artistT.position.y - artistTitleLimit)
                if !b {
                    let z = e - (artistT.position.y - artistTitleLimit)
                    POPLayerSetTranslationY(artistT.layer, position/3 + z + delta)
                }
            }

            let favbutton = self.infoNode.addToFavoritesButton
            let favbuttonLimit = trackTitleLimit + trackT.calculatedSize.height / 2 + 20 + favbutton.calculatedSize.height / 2
            print("limit:", favbuttonLimit)
//            let d = (position + (position / 3))
            if e <= (favbutton.position.y - favbuttonLimit) && percentage < 1 {
                POPLayerSetTranslationY(favbutton.layer, position/3)
            } else if e <= (favbutton.position.y - favbuttonLimit) && percentage >= 1 {
                POPLayerSetTranslationY(favbutton.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (favbutton.position.y - favbuttonLimit)
                if !b {
                    let z = e - (favbutton.position.y - favbuttonLimit)
                    POPLayerSetTranslationY(favbutton.layer, position/3 + z + delta)
                }
            }
            
            let streambutton = self.infoNode.streamStatusButton
            let streambuttonLimit = favbuttonLimit - 20 - favbutton.calculatedSize.height / 2 - streambutton.calculatedSize.height / 2
            if e <= (streambutton.position.y - streambuttonLimit) && percentage < 1 {
                POPLayerSetTranslationY(streambutton.layer, position/3)
            } else if e <= (streambutton.position.y - streambuttonLimit) && percentage >= 1 {
                POPLayerSetTranslationY(streambutton.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (streambutton.position.y - streambuttonLimit)
                if !b {
                    let z = e - (streambutton.position.y - streambuttonLimit)
                    POPLayerSetTranslationY(streambutton.layer, position/3 + z + delta)
                }
            }
            
//            let trackT = self.trackTitle
//            print("LAYOUT SHIT", trackT.calculatedSize.height)
//            let trackTitleLimit = trackT.calculatedSize.height / 2 + 20
//            if moveShit <= (trackT.position.y - trackTitleLimit) {
//                POPLayerSetTranslationY(favbutton.layer, 0)
//            } else {
//                let z = moveShit - (trackT.position.y - trackTitleLimit)
//                print(z + delta)
//                POPLayerSetTranslationY(trackT.layer, z + delta)
//            }
            
        }
    }
}