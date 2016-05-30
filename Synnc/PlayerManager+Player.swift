//
//  PlayerManager+Player.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import MediaPlayer
import WCLUtilities
import Async

extension StreamPlayerManager {
    /// Wrap Player Related Attributes
    var currentItemDuration : CGFloat {
        get {
            if let avItem = self.currentItem as? AVPlayerItem {
                return CGFloat(CMTimeGetSeconds(avItem.asset.duration))
            } else if let player = self.activePlayer as? SynncSpotifyPlayer {
                return CGFloat(player.currentTrackDuration)
            } else if let player = self.activePlayer as? MPMusicPlayerController {
                if let item = player.nowPlayingItem {
                    return CGFloat(item.playbackDuration)
                }
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
            } else if let appleMusicPlayer = activePlayer as? MPMusicPlayerController {
                return appleMusicPlayer.nowPlayingItem
            }
            
            return nil
            
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
            } else if let appleMusicPlayer = activePlayer as? MPMusicPlayerController {
                let time = appleMusicPlayer.currentPlaybackTime
                if time.isFinite {
                    return CMTimeMakeWithSeconds(time, 1000)
                }
            }
            
            return nil
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
            } else if let appleMusicPlayer = player as? MPMusicPlayerController {
                if appleMusicPlayer.playbackState == MPMusicPlaybackState.Playing {
                    return 1
                } else {
                    return 0
                }
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
               
                spotifyPlayer.setIsPlaying(newValue == 1 ? true : false, callback: nil)
            } else if let appleMusicPlayer = player as? MPMusicPlayerController {
                if newValue == 1 {
                    Async.main {
                        appleMusicPlayer.play()
                        
                    }
                } else {
                    Async.main {
                        appleMusicPlayer.stop()
                    }
                }
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
            } else if let appleMusicPlayer = player as? MPMusicPlayerController {
//                appleMusicPlayer.volume
                return 1
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