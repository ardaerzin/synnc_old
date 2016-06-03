//
//  SynncArtistSmallNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/26/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop
import SwiftyJSON
import WCLMusicKit
import WCLUtilities
import Accelerate

class SynncTrackSearchEntityBackgroundNode : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    var tintNode : ASDisplayNode!
    var imageBlurOperation: NSOperation?
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        imageNode.backgroundColor = .yellowColor()
        imageNode.imageModificationBlock = { input in
            if let blurredImage = input.applyBlurWithRadius(
                30,
                tintColor: UIColor(white: 0.5, alpha: 0.3),
                saturationDeltaFactor: 1,
                maskImage: nil,
                didCancel:{ return false }) {
                return blurredImage
            } else {
                return input
            }
        }
        self.addSubnode(imageNode)
        
        tintNode = ASDisplayNode()
        tintNode.backgroundColor = UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 0.3)
        self.addSubnode(tintNode)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value : 1), ASRelativeDimension(type: .Percent, value : 1))
        let x = ASStaticLayoutSpec(children: [self.imageNode])
        return ASOverlayLayoutSpec(child: x, overlay: tintNode)
    }
}

class SynncArtistSmallNode : ASCellNode {
    var imageNode : ASNetworkImageNode!
    var usernameNode : ASTextNode!
    var selectionIndicator : ASDisplayNode!
    var backgroundNode : SynncTrackSearchEntityBackgroundNode!
    
    override var selected : Bool {
        didSet {
            if selected != oldValue {
                self.state = selected ? .Remove : .Add
            }
        }
    }
    var state : TrackCellState = .Add {
        didSet {
            if state != oldValue {
                
                if self.interfaceState != ASInterfaceState.InHierarchy {
                    self.cellStateAnimationProgress = state == .Add ? 0 : 1
                } else {
                    self.cellStateAnimation.toValue = state == .Add ? 0 : 1
                }
            }
        }
    }
    
    var cellStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("trackCellStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SynncArtistSmallNode).cellStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SynncArtistSmallNode).cellStateAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var cellStateAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("cellStateAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("cellStateAnimation")
                }
                x.property = self.cellStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "cellStateAnimation")
                return x
            }
        }
    }
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        self.pop_removeAllAnimations()
        
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            
            if let username = usernameNode.attributedString {
                let track_redT = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: 255) / 255
                let track_greenT = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: 255) / 255
                let track_blueT = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: 255) / 255
                
                let x = NSMutableAttributedString(attributedString: username)
                x.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: track_redT, green: track_greenT, blue: track_blueT, alpha: 1), range: NSMakeRange(0, self.usernameNode.attributedString!.length))
                self.usernameNode.attributedString = x
            }
            

            self.backgroundNode.alpha = cellStateAnimationProgress
            
//            let bg_redT = POPTransition(cellStateAnimationProgress, startValue: 246, endValue: 236) / 255
//            let bg_greenT = POPTransition(cellStateAnimationProgress, startValue: 246, endValue: 89) / 255
//            let bg_blueT = POPTransition(cellStateAnimationProgress, startValue: 246, endValue: 26) / 255
//            
//            self.backgroundColor = UIColor(red: bg_redT, green: bg_greenT, blue: bg_blueT, alpha: 1)
            
            //            let translation = POPTransition(cellStateAnimationProgress, startValue: -self.selectedSeperatorNode.bounds.width / 2, endValue: 0)
//            POPLayerSetScaleX(self.selectionIndicator.layer, cellStateAnimationProgress)
            //            POPLayerSetTranslationX(self.selectedSeperatorNode.layer, translation)
        }
    }
    
    
    override init() {
        super.init()
        
        self.imageNode = ASNetworkImageNode()
        self.imageNode.preferredFrameSize = CGSizeMake(80, 80)
        
        self.usernameNode = ASTextNode()
        self.usernameNode.maximumNumberOfLines = 1
        
        backgroundNode = SynncTrackSearchEntityBackgroundNode()
        
        self.addSubnode(backgroundNode)
        self.addSubnode(self.imageNode)
        self.addSubnode(self.usernameNode)
    }
    func configureForArtist(artist : SynncArtist) {
        if let x = artist.avatar, url = NSURL(string: x) {
            self.imageNode.URL = url
            self.backgroundNode.imageNode.URL = url
        }
        if let name = artist.name {
            self.usernameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10.66)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1)])
        }
        
        if artist.source == SynncExternalSource.Spotify.rawValue {
            SPTArtist.artistWithURI(NSURL(string: "spotify:artist:\(artist.id)")!, session: SPTAuth.defaultInstance().session, callback: { (err, data) in
                if let artist = data as? SPTArtist {
                    self.imageNode.clearContents()
                    if let img = artist.largestImage, url = img.imageURL {
                        self.imageNode.URL = url
                    } else if let img = artist.smallestImage, url = img.imageURL {
                        self.imageNode.URL = url
                    }
                    
                    if let img = artist.smallestImage, url = img.imageURL {
                        self.backgroundNode.imageNode.URL = url
                    }
                }
            })
        } else if artist.source == SynncExternalSource.AppleMusic.rawValue {
            
            WCLMusicKit.sharedInstance.artistAlbums(artist.id, limit: 1){
                response, data, error, timestamp, next in
                
                if let arr = data, let album = arr.first as? WCLMusicKitAlbum, let urlStr = album.artworkUrl100, let url = NSURL(string: urlStr) {
                    self.imageNode.URL = url
                }
                if let arr = data, let album = arr.first as? WCLMusicKitAlbum, let urlStr = album.artworkUrl60, let url = NSURL(string: urlStr) {
                    self.backgroundNode.imageNode.URL = url
                }
            }
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [self.imageNode, self.usernameNode])
        return ASBackgroundLayoutSpec(child: a, background: backgroundNode)
    }
    
    
}