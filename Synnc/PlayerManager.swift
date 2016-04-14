//
//  PlayerManager.swift
//  Synnc
//
//  Created by Arda Erzin on 4/14/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import WCLUtilities
import SwiftyJSON
import SocketIOClientSwift

class StreamPlayerManager {
    
    var players : [AnyObject] = []
    
    var syncManager : WildPlayerSyncManager!
    var trackManager : WildPlayerTrackManager!
    
    init() {
        self.trackManager = WildPlayerTrackManager()
        self.syncManager = WildPlayerSyncManager()
    }
}