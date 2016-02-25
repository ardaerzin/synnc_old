//
//  ChatItem.swift
//  Synnc
//
//  Created by Arda Erzin on 2/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import WCLUtilities
import WCLUserManager
import SwiftyJSON
import AsyncDisplayKit
import WCLUIKit

class ChatBatch : ChatItem {
    var messages: [String]! = []
}

class ChatItem : Serializable {
    
    var status : Bool = true
    var message: String!
    var timestamp : NSDate = NSDate()
    var user_id : String!
    var stream_id : String!
    var user : WCLUser!
    
    required init() {
        super.init()
    }
    
    override func fromJSON(json: JSON) -> [String] {
        let x = super.fromJSON(json)
        self.timestamp = NSDate(timeIntervalSince1970: json["timestamp"].double! / 1000 )
        return x
    }
}