//
//  MyProfileController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class MyProfileController : TabSubsectionController {
    override var _title : String! {
        return "Profile"
    }
    init(){
        let node = ASDisplayNode()
        super.init(node: node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}