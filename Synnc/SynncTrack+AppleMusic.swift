//
//  SynncTrack+AppleMusic.swift
//  Synnc
//
//  Created by Arda Erzin on 5/2/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON
import WCLMusicKit

extension SynncTrack {
    
    convenience init?(data: WCLMusicKitTrack) {
        
        if data.kind == "song" {
            self.init()
//            self.parse
            return
        }
        return nil
    }
    
    internal class func appleMusicIdFromData(data: AnyObject) -> String {
        var id : String = ""
        if let track = data as? WCLMusicKitTrack {
            id = "\(track.trackId)"
        }
        return id
    }
    
    internal func createAppleMusicSong(data: AnyObject) {
        
        guard let track = data as? WCLMusicKitTrack else {
            assertionFailure("invalid data type Apple Music")
            return
        }
        
//        print("release date:", track.releaseDate)
        
        
//        print("track country:", track.country)
        self.source = SynncExternalSource.AppleMusic.rawValue
        self.name = track.trackName
        self.song_id = "\(track.trackId)"
        self.artwork_url = track.artworkUrl100
        self.artwork_small = track.artworkUrl60
        self.duration = track.trackTimeMillis
        self.albumName = track.collectionName
        
        self.artists = []
        if let a = track.artist {
            self.artists.append(SynncArtist.create(a, source: .AppleMusic))
            
        }
//        self.artwork_url = track.artworkUrl100.absoluteString
    }
    
//    internal func createSpotifySong(data: AnyObject) {
//        guard let track = data as? SPTPartialTrack else {
//            assertionFailure("data cannot be converted to SPTPartialTrack")
//            return
//        }
//        self.source = SynncExternalSource.Spotify.rawValue
//        self.name = track.name
//        self.song_id = track.identifier
//        
//        if let uri = track.uri {
//            self.uri = uri.absoluteString
//        }
//        
//        var artists : [SynncArtist] = []
//        for artistData in track.artists {
//            let artist = SynncArtist.create(artistData, source: .Spotify)
//            artists.append(artist)
//        }
//        self.artists = artists
//        
//        var coverUrl : String?
//        if let largeCover = track.album.largestCover {
//            coverUrl = largeCover.imageURL.absoluteString
//        } else if let smallCover = track.album.smallestCover {
//            coverUrl = smallCover.imageURL.absoluteString
//        }
//        self.artwork_url = coverUrl
//    }
}
