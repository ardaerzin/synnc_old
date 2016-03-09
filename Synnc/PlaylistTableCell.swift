//
//  PlaylistTableCell.swift
//  Synnc
//
//  Created by Arda Erzin on 12/20/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop

class PlaylistTableCell : ASCellNode {
    
    var trackNameNode : ASTextNode!
    var artistNameNode : ASTextNode!
    var sourceNode : ASImageNode!
    
    var selectedSeperatorNode : ASDisplayNode!
    var seperatorNode : ASDisplayNode!

    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        let a = self.cellStateAnimationProgress
        self.cellStateAnimationProgress = a
    }
    var cellStateAnimationProgress : CGFloat = 0 {
        didSet {
            let translation = POPTransition(cellStateAnimationProgress, startValue: -self.selectedSeperatorNode.bounds.width / 2, endValue: 0)
            POPLayerSetScaleX(self.selectedSeperatorNode.layer, cellStateAnimationProgress)
            POPLayerSetTranslationX(self.selectedSeperatorNode.layer, translation)
        }
    }
    
    override init() {
        super.init()
        
        self.artistNameNode = ASTextNode()
        self.artistNameNode.layerBacked = true
        self.artistNameNode.maximumNumberOfLines = 1
        
        self.trackNameNode = ASTextNode()
        self.trackNameNode.layerBacked = true
//        self.trackNameNode.maximumNumberOfLines = 1
        self.trackNameNode.spacingBefore = 18
        
        self.sourceNode = ASImageNode()
        self.sourceNode.layerBacked = true
        self.sourceNode.preferredFrameSize = CGSizeMake(12, 12)
        self.sourceNode.spacingBefore = 8
        
        self.seperatorNode = ASDisplayNode()
        self.seperatorNode.backgroundColor = UIColor.lightGrayColor()
        
        self.selectedSeperatorNode = ASDisplayNode()
        self.selectedSeperatorNode.backgroundColor = UIColor.orangeColor()
        
        self.addSubnode(self.trackNameNode)
        self.addSubnode(self.artistNameNode)
        self.addSubnode(self.sourceNode)
        
        self.addSubnode(self.seperatorNode)
        self.selectionStyle = .None
        
        self.backgroundColor = UIColor.whiteColor()
    }
    func configureForTrack(track : SynncTrack) {
        var artistStr : String?
        for artist in track.artists {
            if artistStr == nil {
                artistStr = artist.name
            } else {
                artistStr! += (" / " + artist.name)
            }
        }
        self.artistNameNode.attributedString = NSAttributedString(string: artistStr!, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSForegroundColorAttributeName : UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1)])
        
        if let x = track.name {
            trackNameNode.attributedString = NSAttributedString(string: x, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 94/255, green: 94/255, blue: 94/255, alpha: 1)])
        }
        
        if let x = track.source {
            self.sourceNode.image = UIImage(named: x.lowercaseString+"_active")
        }
    }
    override func layout() {
        super.layout()
//        self.seperatorNode.frame = CGRectMake(25, self.calculatedSize.height - 1, self.calculatedSize.width - 42.5, 1)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let bottomLine = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [self.artistNameNode, self.sourceNode])
        bottomLine.alignSelf = .Stretch
        bottomLine.spacingBefore = 5
        bottomLine.spacingAfter = 18
        
//        trackNameNode.spa
        
        self.seperatorNode.flexBasis = ASRelativeDimension(type: .Points, value: 0.5)
        self.seperatorNode.alignSelf = .Stretch
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [trackNameNode, bottomLine, seperatorNode])
        a.alignSelf = .Stretch
        a.spacingBefore = 25
        
        a.flexBasis = ASRelativeDimension(type: .Points, value: max(0,constrainedSize.max.width - 25))
        let b = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [a])
        return b
    }
}