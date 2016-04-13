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

class SynncArtistSmallNode : ASCellNode {
    var imageNode : ASNetworkImageNode!
    var usernameNode : ASTextNode!
    var sourceNode : ASTextNode!
    var selectionIndicator : ASDisplayNode!
    
    
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
                self.cellStateAnimation.toValue = state == .Add ? 0 : 1
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
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var cellStateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("cellStateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("cellStateAnimation")
                }
                x.springBounciness = 1
                x.property = self.cellStateAnimatableProperty
                self.pop_addAnimation(x, forKey: "cellStateAnimation")
                return x
            }
        }
    }
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            //            let translation = POPTransition(cellStateAnimationProgress, startValue: -self.selectedSeperatorNode.bounds.width / 2, endValue: 0)
            POPLayerSetScaleX(self.selectionIndicator.layer, cellStateAnimationProgress)
            //            POPLayerSetTranslationX(self.selectedSeperatorNode.layer, translation)
        }
    }
    
    
    override init() {
        super.init()
        
        self.imageNode = ASNetworkImageNode()
        self.imageNode.preferredFrameSize = CGSizeMake(80, 80)
        
        self.usernameNode = ASTextNode()
        self.usernameNode.maximumNumberOfLines = 1
        self.sourceNode = ASTextNode()
        self.sourceNode.spacingBefore = 5
        self.sourceNode.maximumNumberOfLines = 1
        
        self.selectionIndicator = ASDisplayNode()
        self.selectionIndicator.backgroundColor = UIColor.SynncColor()
        self.selectionIndicator.flexBasis = ASRelativeDimension(type: .Points, value: 3)
        self.selectionIndicator.alignSelf = .Stretch
        
        self.addSubnode(self.imageNode)
        self.addSubnode(self.usernameNode)
        self.addSubnode(self.sourceNode)
        self.addSubnode(self.selectionIndicator)
    }
    func configureForArtist(artist : SynncArtist) {
        if let x = artist.avatar, url = NSURL(string: x) {
            self.imageNode.URL = url
        }
        if let name = artist.name {
            self.usernameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 10.66)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1)])
        }
        if let src = artist.source {
            self.sourceNode.attributedString = NSAttributedString(string: "@"+src, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 9)!, NSForegroundColorAttributeName : UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1)])
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
                }
            })
        }
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.imageNode, self.usernameNode, self.sourceNode, spacer2, self.selectionIndicator])
        return a
    }
    
    
}