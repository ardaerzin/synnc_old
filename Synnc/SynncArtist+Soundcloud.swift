//
//  SynncArtist+Soundcloud.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLSoundCloudKit
import SwiftyJSON

extension SynncArtist {
//    class func soundcloudArtist(data : AnyObject?) -> SynncArtist {
//        let artist = SynncArtist()
//        artist.parseSoundcloud(data)
//        return artist
//    }
    
    internal class func soundcloudIdFromData(data: AnyObject) -> String {
        var id : String = ""
        if let x = JSON(data)["id"].int {
            id = "\(x)"
        }
        return id
    }
    
    internal func parseSoundcloud(data : AnyObject?) {
        guard let d = data else {
            print("soundcloud user data is nil")
            return
        }
        let json = JSON(d)
        if json == nil && json.null != nil {
            assertionFailure("JSON for soundcloud Track is not a valid one")
        }
        
        if let idNo = json["id"].int {
            self.id = "\(idNo)"
        } else if let idStr = json["id"].string {
            self.id = idStr
        }
        
        self.source = SynncExternalSource.Soundcloud.rawValue
        self.name = json["username"].string
        self.avatar = json["avatar_url"].string
    }
}