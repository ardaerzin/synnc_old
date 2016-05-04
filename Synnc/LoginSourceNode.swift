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
    var spotifyButton : SourceLoginButtonNode!
    var appleMusicButton : SourceLoginButtonNode!
    var buttons : [SourceLoginButtonNode] {
        get {
            return [appleMusicButton, scButton, spotifyButton]
        }
    }
    
    override init() {
        super.init()
        
        scButton = SourceLoginButtonNode(source: .Soundcloud)
        self.addSubnode(scButton)
        
        spotifyButton = SourceLoginButtonNode(source: .Spotify)
        self.addSubnode(spotifyButton)
        
        appleMusicButton = SourceLoginButtonNode(source: .AppleMusic)
        self.addSubnode(appleMusicButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        var layoutables : [ASLayoutable] = []
        
        for (ind,button) in buttons.enumerate() {
            if ind == 0 {
                let spacer = ASLayoutSpec()
                spacer.flexGrow = true
                layoutables.append(spacer)
            }
            
            layoutables.append(button)
            
            let spacer = ASLayoutSpec()
            spacer.flexGrow = true
            layoutables.append(spacer)
        }
        
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: layoutables)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(20, 0, 20, 0), child: x)
    }
}