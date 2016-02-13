//
//  MeContentNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/31/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit
import WCLUserManager

class MeContentNode : ASScrollNode {
    
    var topHeaderNode : UserHeaderInfoNode!
    
        override init() {
        super.init()
        
        self.topHeaderNode = UserHeaderInfoNode()
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubnode(self.topHeaderNode)
    }
    override func didLoad() {
        super.didLoad()
        self.view.delegate = self
        self.view.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 1500 - UIScreen.mainScreen().bounds.width)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [topHeaderNode, spacer])
        
        return x
    }
}
extension MeContentNode : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        POPLayerSetTranslationY(self.topHeaderNode.layer, scrollView.contentOffset.y)
    }
}

class UserHeaderInfoNode : ASDisplayNode {
    
    var followersSection : UserHeaderSectionNode!
    var spacer1 : ASDisplayNode!
    var followingSection : UserHeaderSectionNode!
    var spacer2 : ASDisplayNode!
    var playlistsSection : UserHeaderSectionNode!
    
    class UserHeaderSectionNode : ASDisplayNode {
        var countNode : ASTextNode!
        var titleNode : ASTextNode!
        let countAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 18)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor(red: 83/255, green: 83/255, blue: 83/255, alpha: 1)]
        let titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 10)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor(red: 113/255, green: 111/255, blue: 111/255, alpha: 1)]
        var bottomBorder : ASDisplayNode!
        
        init!(sectionName : String) {
            super.init()
            
            self.countNode = ASTextNode()
            self.titleNode = ASTextNode()
            
            self.countNode.attributedString = NSAttributedString(string: "NaN", attributes: self.countAttributes)
            self.titleNode.attributedString = NSAttributedString(string: sectionName, attributes: self.titleAttributes)
            
            self.bottomBorder = ASDisplayNode()
            self.bottomBorder.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1)
            
            self.layer.shadowColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.5).CGColor
            self.layer.shadowOffset = CGSizeMake(0, 1)
            
            self.addSubnode(self.countNode)
            self.addSubnode(self.titleNode)
            self.addSubnode(self.bottomBorder)
        }
        
        override func layout() {
            super.layout()
            
            let height = 1/UIScreen.mainScreen().scale
            self.bottomBorder.frame = CGRectMake(0, self.calculatedSize.height - height , self.calculatedSize.width, height)
        }
        override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
            return ASStackLayoutSpec(direction: .Vertical, spacing: 6, justifyContent: .Center, alignItems: .Center, children: [self.countNode, self.titleNode])
        }
        
        func setCount(count : Int){
            self.countNode.attributedString = NSAttributedString(string: "\(count)", attributes: self.countAttributes)
            self.setNeedsLayout()
        }
    }
    
        override init() {
        super.init()
        
        self.alignSelf = .Stretch
        self.flexBasis = ASRelativeDimension(type: .Points, value: 62)
        self.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 0.51)
        
        followersSection = UserHeaderSectionNode(sectionName: "followers")
        followersSection.flexGrow = true
        followersSection.alignSelf = .Stretch
        
        followingSection = UserHeaderSectionNode(sectionName: "following")
        followingSection.flexGrow = true
        followingSection.alignSelf = .Stretch
        
        playlistsSection = UserHeaderSectionNode(sectionName: "playlists")
        playlistsSection.alignSelf = .Stretch
        playlistsSection.flexGrow = true
        
        spacer1 = ASDisplayNode()
        spacer1.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        spacer1.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 1), ASRelativeDimension(type: .Points, value: 37))
        
        spacer2 = ASDisplayNode()
        spacer2.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        spacer2.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: 1), ASRelativeDimension(type: .Points, value: 37))
        
        self.addSubnode(followersSection)
        self.addSubnode(self.spacer1)
        self.addSubnode(followingSection)
        self.addSubnode(self.spacer2)
        self.addSubnode(playlistsSection)
        
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [followersSection, ASStaticLayoutSpec(children: [ spacer1]), followingSection, ASStaticLayoutSpec(children: [ spacer2]), playlistsSection])
    }
}