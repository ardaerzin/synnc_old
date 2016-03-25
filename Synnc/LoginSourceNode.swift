//
//  LoginSourceNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class LoginSourceNode : CardNodeBase {
    
    var scButton : SourceLoginButtonNode!
    
    override init() {
        super.init()
        
        scButton = SourceLoginButtonNode(source: .Soundcloud)
        self.addSubnode(scButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [scButton])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(20, 0, 20, 0), child: x)
    }
}