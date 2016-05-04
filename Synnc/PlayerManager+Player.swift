//
//  PlayerManager+Player.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

extension StreamPlayerManager {
    /// Wrap Player Related Attributes
    var currentItemDuration : CGFloat {
        get {
            if let avItem = self.currentItem as? AVPlayerItem {
                return CGFloat(CMTimeGetSeconds(avItem.duration))
            } else if let player = self.activePlayer as? SynncSpotifyPlayer {
                return CGFloat(player.currentTrackDuration)
            }
            return 0
        }
    }
    var currentItem : AnyObject? {
        get {
            if let avplayer = activePlayer as? AVPlayer {
                return avplayer.currentItem
            } else if let spotifyPlayer = activePlayer as? SPTAudioStreamingController {
                return spotifyPlayer.currentTrackURI
            } else {
                return nil
            }
        }
    }
    var currentTime : CMTime? {
        get {
            guard let player = activePlayer else {
                return nil
            }
            if let avplayer = player as? AVPlayer {
                return avplayer.currentTime()
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
                return CMTimeMakeWithSeconds(spotifyPlayer.currentPlaybackPosition, 1000)
            } else {
                return nil
            }
        }
    }
    var rate : Float {
        get {
            guard let player = activePlayer else {
                return 0
            }
            if let avplayer = player as? AVPlayer {
                return avplayer.rate
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
                return spotifyPlayer.isPlaying ? 1 : 0
            } else {
                return 0
            }
        }
        set {
            guard let player = activePlayer else {
                return
            }
            if let avplayer = player as? AVPlayer {
                avplayer.rate = newValue
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
                
            }
        }
    }
    var volume : Float {
        get {
            guard let player = activePlayer else {
                return 0
            }
            if let avplayer = player as? AVPlayer {
                return avplayer.volume
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
                return Float(spotifyPlayer.volume)
            } else {
                return 0
            }
        }
        set {
            guard let player = activePlayer else {
                return
            }
            if let avplayer = player as? AVPlayer {
                avplayer.volume = newValue
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
                spotifyPlayer.setVolume(Double(newValue), callback: nil)
            }
        }
    }
    var isPlaying : Bool {
        get {
            guard let player = activePlayer else {
                return false
            }
            if player.rate > 0 && player.error == nil {
                return true
            } else {
                return false
            }
        }
    }
 
    func play(){
        checkActiveSession()
        if self.readyToPlay {
            self.rate = 1
            needsPlay = false
        } else {
            needsPlay = true
        }
    }
}