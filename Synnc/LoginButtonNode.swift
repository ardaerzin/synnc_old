//
//  LoginButtonNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/2/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LoginButtonNode : ButtonNode {
    override init(normalColor: UIColor? = .clearColor(), selectedColor: UIColor? = .clearColor()) {
        super.init(normalColor: normalColor, selectedColor: selectedColor)
//        self.imageNode.spacingAfter = 15
    }
//    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
//        
//        let spacer = ASLayoutSpec()
//        spacer.flexGrow = true
//        
//        var imgSpec : ASLayoutable!
//        
//        if self.imageNode.image != nil {
//            imgSpec = ASRatioLayoutSpec(ratio: 1, child: self.imageNode)
//            imgSpec.flexGrow = false
//            self.imageNode.contentMode = UIViewContentMode.Center
//            imgSpec.spacingBefore = 20
//            
//            let a = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Center, children: [imgSpec, self.titleNode])
//            return a
//        } else {
//            let x = super.layoutSpecThatFits(ASSizeRange(min: self.frame.size, max: self.frame.size))
//            return x
//        }
//    }
}