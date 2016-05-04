//
//  PlayerManager+TrackLoader.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUtilities

extension Int {
    func isEven() -> Bool {
        return (self%2 == 0)
    }
}

extension StreamPlayerManager {
    
    typealias TrackPlayerInfo = (item : AnyObject?, index: Int, player: PlayerManagerPlayer)
//    typealias TrackPlayerInfo = (item : AVPlayerItem?, index: Int, player: PlayerManagerPlayer)
    
    func assignTracksToPlayers(tracks : [SynncTrack], currentIndex : Int? = 0) -> [SynncTrack : TrackPlayerInfo] {
        
        var indexedData : [SynncTrack : TrackPlayerInfo] = [SynncTrack : TrackPlayerInfo]()
        var spotifyUris : [NSURL] = []
        for (ind, track) in tracks.enumerate() {
            
            guard let source = SynncExternalSource(rawValue: track.source) else {
                continue
            }
            
            var player : PlayerManagerPlayer!
            var item : AnyObject!
            
            switch source {
            case .Soundcloud:
                if ind.isEven() {
                    player = .URLPlayerEven
                } else {
                    player = .URLPlayerOdd
                }
                item = newItem(song: track)
                break
            case .Spotify:
                player = .SpotifyPlayer
                if let uriStr = track.uri where ind >= currentIndex {
                    if let uri = NSURL(string: uriStr) {
                        print("Append:", uri)
                        item = uri
                        spotifyUris.append(uri)
                    }
                }
                break
            default:
                break
            }
            
            if let p = player {
                indexedData[track] = (item: item, index: ind, player: p)
            }
        }
        
        if !spotifyUris.isEmpty {
            if let player = self.players[.SpotifyPlayer] as? SynncSpotifyPlayer {
 
                player.queueURIs(spotifyUris, clearQueue: true) { (err) in
                    if let error = err {
                        print("couldn't queue URIs", error.description)
                        return
                    }
                    print("stop player")
                    player.setIsPlaying(false, callback: nil)
                }
            }
        }
        
        return indexedData
    }
}

extension StreamPlayerManager {
    func newItem(song song: SynncTrack) -> AVPlayerItem? {
        if let url = NSURL(string: song.streamUrl) {
            return newItem(url: url)
        }
        return nil
    }
    func newItem(str str : String) -> AVPlayerItem? {
        let url = NSURL(string: str)
        return url == nil ? nil : newItem(url: url!)
    }
    func newItem(url url: NSURL) -> AVPlayerItem? {
        //        let item = WildPlayerItem(URL: url, player: player, delegate: player, index: index)
        let asset = AVAsset(URL: url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: nil)
        //        if item == nil {
        //            return nil
        //        }
        //        return item!
        return item
    }
}

//extension StreamPlayerManager {
//    func assignToPlayers(startingAtIndex index: Int) {
//        
//        for (ind,track) in playlist.enumerate() {
//            if ind < index {
//                continue
//            }
//            if let info = playerIndexedPlaylist[track] {
//                if let player = players[info.player] as? AVPlayer, let item = info.item as? AVPlayerItem where player.currentItem == nil {
//                    player.replaceCurrentItemWithPlayerItem(item)
//                }
//            }
//        }
//    }
//}