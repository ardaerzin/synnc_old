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
    
    typealias TrackPlayerInfo = (item : AVPlayerItem?, index: Int, player: PlayerManagerPlayer)
    
    func assignTracksToPlayers(tracks : [SynncTrack]) -> [SynncTrack : TrackPlayerInfo] {
        
        var indexedData : [SynncTrack : TrackPlayerInfo] = [SynncTrack : TrackPlayerInfo]()
        
        for (ind, track) in tracks.enumerate() {
            
            guard let source = SynncExternalSource(rawValue: track.source) else {
                continue
            }
            
            var player : PlayerManagerPlayer!
            var item : AVPlayerItem!
            
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
                break
            default:
                break
            }
            
            if let p = player {
                indexedData[track] = (item: item, index: ind, player: p)
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

extension StreamPlayerManager {
    func assignToPlayers(startingAtIndex index: Int) {
        
        for (ind,track) in playlist.enumerate() {
            if ind < index {
                continue
            }
            if let info = playerIndexedPlaylist[track] {
                if let player = players[info.player], let item = info.item where player.currentItem == nil {
                    player.replaceCurrentItemWithPlayerItem(item)
                }
            }
        }
//        for (_,info) in playerIndexedPlaylist {
//            if let player = players[info.player], let item = info.item where player.currentItem == nil {
//                print("song", info.index)
//                player.replaceCurrentItemWithPlayerItem(item)
//            }
//        }
    }
}