//
//  ImportPlaylistsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit

class ImportPlaylistsController : TabSubsectionController {
    override var _title : String! {
        return "Import Playlists"
    }
    override init(){
        let a = ASDisplayNode()
        super.init(node: a)
        a.backgroundColor = UIColor.greenColor()
        self.screenNode = a
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}