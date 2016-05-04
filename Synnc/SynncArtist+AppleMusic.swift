//
//  SynncArtist+AppleMusic.swift
//  Synnc
//
//  Created by Arda Erzin on 5/2/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON
import WCLMusicKit

extension SynncArtist {
    internal class func appleMusicIdFromData(data: AnyObject) -> String {
        var id : String = ""
        if let sptsong = data as? SPTPartialArtist {
            id = sptsong.identifier
        }
        return id
    }
    internal func parseAppleMusic(data : AnyObject?) {
        guard let user = data as? WCLMusicKitArtist else {
            return
        }
        
        self.source = SynncExternalSource.AppleMusic.rawValue
        self.id = "\(user.artistId)"
        self.name = user.artistName
        
        //        if let x = user as? SPTArtist {
        //            print(x)
        //        }
    }
}
