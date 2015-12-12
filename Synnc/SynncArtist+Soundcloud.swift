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
    class func soundcloudArtist(data : AnyObject?) -> SynncArtist {
        let artist = SynncArtist()
        artist.parseSoundcloud(data)
        return artist
    }
    private func parseSoundcloud(data : AnyObject?) {
        guard let d = data else {
            print("soundcloud user data is nil")
            return
        }
        let json = JSON(d)
        if json == nil && json.null != nil {
            assertionFailure("JSON for soundcloud Track is not a valid one")
        }
        
        let id = json["id"].int
        self.source = .Soundcloud
        self.id = "\(id)"
        self.name = json["username"].string
        self.avatar = json["avatar_url"].string
    }
}