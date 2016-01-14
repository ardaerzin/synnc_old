//
//  SynncSong+Soundcloud.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON
import WCLSoundCloudKit

extension SynncTrack {
    
    internal class func soundcloudIdFromData(data: AnyObject) -> String {
        var id : String = ""
        if let x = JSON(data)["id"].number {
            id = "\(x)"
        }
        return id
    }
    
    internal func createSoundcloudSong(data: AnyObject) {
        let json = JSON(data)
        
        if json == nil && json.null != nil {
            assertionFailure("JSON for soundcloud Track is not a valid one")
        }
        self.name = json["title"].string
        let x = json["id"].number!
        self.song_id = "\(x)"
        self.source = SynncExternalSource.Soundcloud.rawValue
        
        var u = json["user"]
        if u.null == nil {
            let artist = SynncArtist.create(u.object, source: .Soundcloud)
            self.artists = [artist]
        }
        if let artwork = json["artwork_url"].string {
            self.artwork_url = WildSoundCloud.appendAccessToken(artwork)
        }
    }
}