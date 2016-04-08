//
//  StreamsFeedEmptyStateNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

class StreamsFeedEmptyStateNode : EmptyStateNode {
    override init(){
        super.init()
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    override func fetchData() {
        super.fetchData()
        self.stateMsgNode.attributedString = NSAttributedString(string: "Wadap?", attributes: self.textAttributes)
        self.setNeedsLayout()
    }
}