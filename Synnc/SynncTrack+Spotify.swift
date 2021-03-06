//
//  SynncSong+Spotify.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON

extension SynncTrack {    
    internal class func spotifyIdFromData(data: AnyObject) -> String {
        var id : String = ""
        if let sptsong = data as? SPTPartialTrack {
            id = sptsong.identifier
        }
        return id
    }
    internal func createSpotifySong(data: AnyObject) {
        guard let track = data as? SPTPartialTrack else {
            assertionFailure("data cannot be converted to SPTPartialTrack")
            return
        }
        self.source = SynncExternalSource.Spotify.rawValue
        self.name = track.name
        self.song_id = track.identifier
        self.duration = track.duration * 1000
        
        if let uri = track.uri {
            self.uri = uri.absoluteString
        }
        
        var artists : [SynncArtist] = []
        for artistData in track.artists {
            let artist = SynncArtist.create(artistData, source: .Spotify)
            artists.append(artist)
        }
        self.artists = artists
        
        var coverUrl : String?
        if let largeCover = track.album.largestCover {
            coverUrl = largeCover.imageURL.absoluteString
        } else if let smallCover = track.album.smallestCover {
            coverUrl = smallCover.imageURL.absoluteString
        }
        if let smallCover = track.album.smallestCover {
            self.artwork_small = smallCover.imageURL.absoluteString
        }
        self.artwork_url = coverUrl
    }
}