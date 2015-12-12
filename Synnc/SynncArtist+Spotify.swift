//
//  SynncArtist+Spotify.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON

extension SynncArtist {
    class func spotifyArtist(data : AnyObject?) -> SynncArtist {
        let artist = SynncArtist()
        artist.parseSpotify(data)
        return artist
    }
    private func parseSpotify(data : AnyObject?) {
        guard let user = data as? SPTPartialArtist else {
            print("data cannot be converted to SPTPartialArtist")
            return
        }
        self.source = .Spotify
        self.id = user.identifier
        self.name = user.name
    }
}