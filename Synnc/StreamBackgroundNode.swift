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

class StreamBackgroundNode : ParallaxBackgroundNode {
    
    var infoNode : StreamBackgroundInfoNode!
    var animationAlphaValues : [NSObject : CGFloat] = [NSObject : CGFloat]()
    
    var scrollPosition : CGFloat = 0
    var trackTitlePositionY : CGFloat!
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
            }
        }
    }
    var state : StreamVCState = .Hidden {
        didSet {
            if state != oldValue {
                self.stateAnimation.toValue = state.rawValue
                if state == StreamVCState.Syncing {
                    self.infoNode.syncShimmer.shimmering = true
                } else {
                    self.infoNode.syncShimmer.shimmering = false
                }
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
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") as? POPSpringAnimation{
                return anim
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("stateAnimation")
                }
//                x.duration = 2
                x.springBounciness = 0
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = 1 {
        didSet {
        
            self.infoNode.trackTitle.alpha = max(stateAnimationProgress - 1, 1)
            self.addToFavs_animationAlpha = stateAnimationProgress - 1
            
            self.infoNode.streamTitle.alpha = -stateAnimationProgress + 1
            self.infoNode.startStreamButton.alpha = -stateAnimationProgress
            
            
            self.artistLabel_animationAlpha = max(stateAnimationProgress - 1, 1)
            self.genreToggle_animationAlpha = fabs(stateAnimationProgress)
            self.locationToggle_animationAlpha = fabs(stateAnimationProgress)
            
            var startButtonAlpha : CGFloat = 0
            
            if state.rawValue <= 1 {
                startButtonAlpha = stateAnimationProgress
            } else if state.rawValue < 4 {
                let y = POPTransition(abs(stateAnimationProgress - 1), startValue: 1, endValue: 0)
                if let x = animationAlphaValues[infoNode.streamStatusButton] {
                    if y < x {
                        startButtonAlpha = y
                    } else {
                        startButtonAlpha = x
                    }
                } else {
                    startButtonAlpha = y
                }
            
            } else {
                
                self.infoNode.trackTitle.alpha = 4 - stateAnimationProgress
                self.addToFavs_animationAlpha = 4 - stateAnimationProgress
                
                self.artistLabel_animationAlpha = 4 - stateAnimationProgress
                self.genreToggle_animationAlpha = 4 - stateAnimationProgress
                self.locationToggle_animationAlpha = 4 - stateAnimationProgress
            
                self.streamEndTitle_animationAlpha = stateAnimationProgress - 3
                self.closeButton_animationAlpha = stateAnimationProgress - 3
            }
            animationAlphaValues[infoNode.streamStatusButton] = startButtonAlpha
            self.infoNode.streamStatusButton.alpha = startButtonAlpha    
        }
    }
    
    
    var locationToggle_alphaMultiplier : CGFloat! = 1 {
        didSet {
            locationToggle_alpha = locationToggle_alphaMultiplier * locationToggle_animationAlpha
        }
    }
    var genreToggle_alphaMultiplier : CGFloat! = 1 {
        didSet {
            genreToggle_alpha = genreToggle_alphaMultiplier * genreToggle_animationAlpha
        }
    }
    
    var locationToggle_animationAlpha : CGFloat! = 1 {
        didSet {
            locationToggle_alpha = locationToggle_alphaMultiplier * locationToggle_animationAlpha
        }
    }
    var genreToggle_animationAlpha : CGFloat! = 1 {
        didSet {
            genreToggle_alpha = genreToggle_alphaMultiplier * genreToggle_animationAlpha
        }
    }
    
    var locationToggle_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.locationToggle.alpha = locationToggle_alpha
        }
    }
    var genreToggle_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.genreToggle.alpha = genreToggle_alpha
        }
    }
    
    
    var statusButton_animationAlpha : CGFloat! = 1 {
        didSet {
            statusButton_alpha = statusButton_alphaMultiplier * statusButton_animationAlpha
        }
    }
    var statusButton_alphaMultiplier : CGFloat! = 1 {
        didSet {
            statusButton_alpha = statusButton_alphaMultiplier * statusButton_animationAlpha
        }
    }
    var statusButton_alpha : CGFloat! = 1 {
        didSet {
//            locationToggle_alpha = locationToggle_alphaMultiplier * locationToggle_animationAlpha
        }
    }
    
    
    var artistLabel_animationAlpha : CGFloat! = 1 {
        didSet {
            artistLabel_alpha = artistLabel_alphaMultiplier * artistLabel_animationAlpha
        }
    }
    var artistLabel_alphaMultiplier : CGFloat! = 1 {
        didSet {
            artistLabel_alpha = artistLabel_alphaMultiplier * artistLabel_animationAlpha
        }
    }
    var artistLabel_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.artistTitle.alpha = artistLabel_animationAlpha * artistLabel_alphaMultiplier
        }
    }
    
    var addToFavs_animationAlpha : CGFloat! = 1 {
        didSet {
            addToFavs_alpha = addToFavs_alphaMultiplier * addToFavs_animationAlpha
        }
    }
    var addToFavs_alphaMultiplier : CGFloat! = 1 {
        didSet {
            addToFavs_alpha = addToFavs_alphaMultiplier * addToFavs_animationAlpha
        }
    }
    var addToFavs_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.addToFavoritesButton.alpha = addToFavs_alphaMultiplier * addToFavs_animationAlpha
        }
    }
    
    var streamEndTitle_animationAlpha : CGFloat! = 1 {
        didSet {
            streamEndTitle_alpha = streamEndTitle_alphaMultiplier * streamEndTitle_animationAlpha
        }
    }
    var streamEndTitle_alphaMultiplier : CGFloat! = 1 {
        didSet {
            streamEndTitle_alpha = streamEndTitle_alphaMultiplier * streamEndTitle_animationAlpha
        }
    }
    var streamEndTitle_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.endTitle.alpha = streamEndTitle_alpha
        }
    }
    
    var closeButton_animationAlpha : CGFloat! = 1 {
        didSet {
            closeButton_alpha = closeButton_alphaMultiplier * closeButton_animationAlpha
        }
    }
    var closeButton_alphaMultiplier : CGFloat! = 1 {
        didSet {
            closeButton_alpha = closeButton_alphaMultiplier * closeButton_animationAlpha
        }
    }
    var closeButton_alpha : CGFloat! = 1 {
        didSet {
            self.infoNode.closeButton.alpha = closeButton_alpha
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
        self.infoNode = StreamBackgroundInfoNode()
        
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
    
    override func updateScrollPositions(position: CGFloat, ratioProgress: CGFloat) {
        
        self.scrollPosition = position
        super.updateScrollPositions(position,ratioProgress: ratioProgress)
        
        var delta : CGFloat = 0
        let limit : CGFloat = self.calculatedSize.width - 150
        delta = -max(0,position - limit)
        
        let moveShit = position + (-position / 2)
        let percentage = position/limit
        
        self.locationToggle_alphaMultiplier = 1 - min(0.5,percentage)*2
        self.genreToggle_alphaMultiplier = 1 - min(0.5,percentage)*2
        self.genreToggle_alphaMultiplier = 1 - min(0.5,percentage)*2
        
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
        
        if self.state == .ReadyToPlay || self.state == .Play || self.state == .Syncing || state == .Finished {
            
            self.artistLabel_alphaMultiplier = 1 - min(0.5,percentage)*2
            
            let trackT = self.infoNode.trackTitle
            let trackTitleLimit = trackT.calculatedSize.height / 2 + 25
            let e = (position + (-position / 3))
            if e <= (trackT.position.y - trackTitleLimit) && percentage < 1 {
                POPLayerSetTranslationY(trackT.layer, position/3)
                POPLayerSetTranslationY(self.infoNode.playingIcon.layer, position/3)
                POPLayerSetTranslationY(self.infoNode.endTitle.layer, position/3)
            } else if e <= (trackT.position.y - trackTitleLimit) && percentage >= 1 {
                POPLayerSetTranslationY(trackT.layer, limit - e)
                POPLayerSetTranslationY(self.infoNode.playingIcon.layer, limit - e)
                POPLayerSetTranslationY(self.infoNode.endTitle.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (trackT.position.y - trackTitleLimit)
                if !b {
                    let z = e - (trackT.position.y - trackTitleLimit)
                    POPLayerSetTranslationY(trackT.layer, position/3 + z + delta)
                    POPLayerSetTranslationY(self.infoNode.playingIcon.layer, position/3 + z + delta)
                    POPLayerSetTranslationY(self.infoNode.endTitle.layer, position/3 + z + delta)
                }
            }
            let s = POPTransition(percentage, startValue: 1, endValue: 0.75)
            POPLayerSetScaleXY(trackT.layer, CGPointMake(s,s))
            
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
            let favbuttonLimit = min(trackTitleLimit + trackT.calculatedSize.height / 2 + 30 + artistT.calculatedSize.height / 2, 150 - favbutton.calculatedSize.height / 2 - 10)
            if e <= (favbutton.position.y - favbuttonLimit) && percentage < 1 {
                POPLayerSetTranslationY(favbutton.layer, position/3)
                POPLayerSetTranslationY(self.infoNode.closeButton.layer, position/3)
            } else if e <= (favbutton.position.y - favbuttonLimit) && percentage >= 1 {
                POPLayerSetTranslationY(favbutton.layer, limit - e)
                POPLayerSetTranslationY(self.infoNode.closeButton.layer, limit - e)
            } else {
                let pos = (limit - (limit/3))
                let b = pos < (favbutton.position.y - favbuttonLimit)
                if !b {
                    let z = e - (favbutton.position.y - favbuttonLimit)
                    POPLayerSetTranslationY(favbutton.layer, position/3 + z + delta)
                    POPLayerSetTranslationY(self.infoNode.closeButton.layer, position/3 + z + delta)
                }
            }
            
            let streambutton = self.infoNode.streamStatusButton
            let streambuttonLimit = 150 - (streambutton.calculatedSize.height / 2 + 10)
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
            
        }
    }
}