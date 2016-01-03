//
//  StreamVC.swift
//  Synnc
//
//  Created by Arda Erzin on 12/31/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLNotificationManager

class StreamVC : ASViewController {
    
    var tempStream : Stream!
    var selectedImage : UIImage!
    var stream : Stream!
    
    var playlist : SynncPlaylist!
    var streamName : String!
    let a = PlaylistSelectorController()
    
    var imagePicker : SynncImagePicker!
    
    var screenNode : StreamViewNode!
    init(){
        a.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 150)
        let node = StreamViewNode()
        super.init(node: node)
        self.screenNode = node
        self.tempStream = Stream(user: Synnc.sharedInstance.user)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}