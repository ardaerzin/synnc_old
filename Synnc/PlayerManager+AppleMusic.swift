//
//  PlayerManager+AppleMusic.swift
//  Synnc
//
//  Created by Arda Erzin on 5/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import MediaPlayer

extension StreamPlayerManager {
    
    func initAppleMusicPlayer() -> MPMusicPlayerController {
        let player = MPMusicPlayerController.applicationMusicPlayer()
        player.beginGeneratingPlaybackNotifications()
        
        player.repeatMode = MPMusicRepeatMode.None
        player.shuffleMode = MPMusicShuffleMode.Off
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.appleMusicPlayerStateChanged(_:)), name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
            , object: player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.appleMusicPlayerItemChanged(_:)), name:
            MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: player)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.appleMusicPlayerVolumeChanged(_:)), name: MPMusicPlayerControllerVolumeDidChangeNotification, object: player)
        
        return player
    }
    
    func appleMusicPlayerStateChanged(notification: NSNotification) {
        
        print("STATE CHANGED:", (self.players[.AppleMusicPlayer] as! MPMusicPlayerController).playbackState.rawValue, "!!", MPMusicPlaybackState.Interrupted.rawValue, MPMusicPlaybackState.Paused.rawValue, MPMusicPlaybackState.Playing.rawValue, MPMusicPlaybackState.SeekingBackward.rawValue, MPMusicPlaybackState.SeekingForward.rawValue, MPMusicPlaybackState.Stopped.rawValue)
        
        updateControlCenterRate()
        
        guard let player = (self.players[.AppleMusicPlayer] as? MPMusicPlayerController) else {
            print("cannot find player")
            abort()
        }
        
        if player.playbackState == MPMusicPlaybackState.Playing {
            self.startAppleMusicTimer()
        }
        
//        if let item = player.nowPlayingItem {
//            self.readyToPlay = true
//        }
        
//        if (self.players[.AppleMusicPlayer] as! MPMusicPlayerController).playbackState == MPMusicPlaybackState.Interrupted || (self.players[.AppleMusicPlayer] as! MPMusicPlayerController).playbackState == MPMusicPlaybackState.Paused {
////            (self.players[.AppleMusicPlayer] as! MPMusicPlayerController).play()
//        }
    }
    func appleMusicPlayerItemChanged(notification: NSNotification) {
        print("PLAYER ITEM CHANGED:", (self.players[.AppleMusicPlayer] as! MPMusicPlayerController).nowPlayingItem)
        
        guard let player = (self.players[.AppleMusicPlayer] as? MPMusicPlayerController) else {
            print("cannot find apple music player")
            abort()
        }
        
        if player.playbackState == MPMusicPlaybackState.Playing {
            player.pause()
        }
        
        
        let currentItem = player.nowPlayingItem
        //
        if let prevItem = self.appleMusicItem where prevItem != currentItem {
            if let prevInfo = self.songInfo(prevItem) {
                
                if prevInfo.index == self.playlist.count - 1 {
                    endOfPlaylist = true
                    return
                } else {
                    switchPlayers(prevInfo)
                    self.loadNextSongForPlayer(prevInfo)
                }
            }
        } else {
            print("current index is:", self.currentIndex)
//
//            switchPlayers(nil)
        }
        
        if player === self.activePlayer {
            startAppleMusicTimer()
            self.play()
            updateControlCenterItem()
        } else {
            stopAppleMusicTimer()
        }
        
        
        if let item = player.nowPlayingItem {
            
//            print("SEXXXX", item.valueForKey(MPMediaItemPropertyAssetURL))
//            switchPlayers(info)
//            self.loadNextSongForPlayer(info)
        } else {
            stopAppleMusicTimer()
        }
        
        self.appleMusicItem = player.nowPlayingItem
        
//        self.play()
        
        self.syncManager.needsUpdate = true
    }
    func appleMusicPlayerVolumeChanged(notification: NSNotification) {
        //        print("VOLUME CHANGED")
    }
    func stopAppleMusicTimer() {
        if let timer = appleMusicPlayerTimer {
            timer.invalidate()
            appleMusicPlayerTimer = nil
        }
    }
    func startAppleMusicTimer() {
        if appleMusicPlayerTimer == nil {
            appleMusicPlayerTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(StreamPlayerManager.appleMusicTimerAction(_:)), userInfo: nil, repeats: true)
        }
    }
    func appleMusicTimerAction(sender : NSTimer){
        
        if let player = (self.players[.AppleMusicPlayer] as? MPMusicPlayerController) {
            let time = player.currentPlaybackTime
            if time.isFinite {
                self.playerTimeUpdated(CMTimeMakeWithSeconds(time, 1000))
            }
            
//            print("!*!*!*", MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
        }
    }
}