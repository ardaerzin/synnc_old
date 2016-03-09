//
//  PlaylistCellNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/18/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import pop

class SelectablePlaylistCellNode : PlaylistCellNode {
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            self.alpha = POPTransition(cellStateAnimationProgress, startValue: 0.5, endValue: 1)
            
            let c = UIColor.SynncColor()
            let c_rgb = c.rgb()!
            
            let r = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: CGFloat(c_rgb.red))
            let g = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: CGFloat(c_rgb.green))
            let b = POPTransition(cellStateAnimationProgress, startValue: 87, endValue: CGFloat(c_rgb.blue))
            
            let tr = POPTransition(cellStateAnimationProgress, startValue: 125, endValue: CGFloat(c_rgb.red))
            let tg = POPTransition(cellStateAnimationProgress, startValue: 125, endValue: CGFloat(c_rgb.green))
            let tb = POPTransition(cellStateAnimationProgress, startValue: 125, endValue: CGFloat(c_rgb.blue))
            
            
            self.nameNode.attributedString = NSAttributedString(string: self.nameNode.attributedString!.string, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)])
            self.trackCountNode.attributedString = NSAttributedString(string: self.trackCountNode.attributedString!.string, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor(red: tr/255, green: tg/255, blue: tb/255, alpha: 0.41)])
        }
    }
    var cellStateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("trackCellStateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! SelectablePlaylistCellNode).cellStateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! SelectablePlaylistCellNode).cellStateAnimationProgress = values[0]
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
    
    var isSelected : Bool = false {
        didSet {
            self.cellStateAnimation.toValue = isSelected ? 1 : 0
        }
    }
}

class PlaylistCellNode : ASCellNode {
    var imageNode : ASNetworkImageNode!
    var nameNode : ASTextNode!
    var trackCountNode : ASTextNode!
    var img : AnyObject!
    
    override func fetchData() {
        super.fetchData()
        
        let transformation = CLTransformation()
        transformation.width = self.imageNode.calculatedSize.width * UIScreen.mainScreen().scale
        transformation.height = self.imageNode.calculatedSize.height * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        if let id = self.img as? String, let x = _cloudinary.url(id, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            self.imageNode.URL = url
        } else if let img = self.img as? UIImage {
            if img.size.width != img.size.height {
                self.imageNode.contentMode = UIViewContentMode.ScaleAspectFill
            } else {
                self.imageNode.contentMode = UIViewContentMode.Center
            }
            self.imageNode.image = img
        }
    }
    override init() {
        super.init()
        
        self.imageNode = ASNetworkImageNode()
        self.imageNode.preferredFrameSize = CGSizeMake(106, 106)
        
        self.nameNode = ASTextNode()
        self.nameNode.spacingBefore = 13
        self.nameNode.maximumNumberOfLines = 1
        self.trackCountNode = ASTextNode()
        self.trackCountNode.spacingBefore = 5
        self.trackCountNode.maximumNumberOfLines = 1
        
        self.imageNode.image = Synnc.appIcon
        self.imageNode.contentMode = UIViewContentMode.Center
        
        self.addSubnode(self.imageNode)
        self.addSubnode(self.nameNode)
        self.addSubnode(self.trackCountNode)
    }
    func configureForPlaylist(playlist : SynncPlaylist) {
        if let name = playlist.name {
            self.nameNode.attributedString = NSAttributedString(string: name, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 1)])
        }
        self.trackCountNode.attributedString = NSAttributedString(string: "\(playlist.songs.count) tracks", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 0.41)])
        
        if let id = playlist.cover_id where id != "" {
            self.img = id
        }
        if let img = playlist.coverImage {
            self.img = img
        }
        self.fetchData()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [spacer, self.imageNode, self.nameNode, self.trackCountNode, spacer2])
        return a
    }
}