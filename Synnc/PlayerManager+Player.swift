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
    var currentItem : AVPlayerItem? {
        get {
            if activePlayer == nil {
                return nil
            }
            return activePlayer.currentItem
        }
    }
    var currentTime : CMTime? {
        get {
            if activePlayer == nil {
                return nil
            }
            return activePlayer.currentTime()
        }
    }
    var rate : Float {
        get {
            guard let player = activePlayer else {
                return 0
            }
            return player.rate
        }
        set {
            guard let player = activePlayer else {
                return
            }
            player.rate = newValue
        }
    }
    var volume : Float {
        get {
            guard let player = activePlayer else {
                return 0
            }
            return player.volume
        }
        set {
            guard let player = activePlayer else {
                return
            }
            player.volume = newValue
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
 
    func fadeVolume(toValue value: Float){
        guard let item = self.currentItem, let ct = currentTime else {
            return
        }
        
        let audioTracks = item.asset.tracksWithMediaType(AVMediaTypeAudio)
        let timescale = item.asset.duration.timescale
        
        var allAudioParams : [AVAudioMixInputParameters] = []
        
        
        for track in audioTracks {
            let ct2 = CMTimeGetSeconds(ct) == 0.0 ? CMTimeMake(0, timescale) : CMTimeMakeWithSeconds(CMTimeGetSeconds(ct), timescale)
            
            let inputParams = AVMutableAudioMixInputParameters(track: track )
            inputParams.setVolumeRampFromStartVolume(value == 0 ? 1 : 0, toEndVolume: value, timeRange: CMTimeRangeMake(ct2, CMTimeMakeWithSeconds(fadeDuration , 1)))
            
            allAudioParams.append(inputParams)
        }
        
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = allAudioParams
        
        item.audioMix = audioMix
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
    
//    func pause(){
//        guard let player = self.activePlayer, let ct = currentTime else {
//            return
//        }
//        let pauseTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(ct) + fadeDuration, self.currentItem!.asset.duration.timescale)
//        self.fadeVolume(toValue: 0)
//        
//        fadeoutObserver = player.addBoundaryTimeObserverForTimes([NSValue(CMTime: pauseTime)], queue: nil, usingBlock: {
//            self.rate = 0
//        })
//    }
}