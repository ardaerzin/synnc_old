//
//  WildPlayerSyncManager.swift
//  Music App
//
//  Created by Arda Erzin on 6/4/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import WCLUtilities
import SwiftyJSON

class WildPlayerSyncManager {
    
    weak var player: WildPlayer!
    var updateInterval : Double = 1.0
    var oldUpdate : Float64?
    var timeUpdateData : JSON!
    var offSet : NSTimeInterval = 0
    var needsUpdate : Bool = true
    
    var timestamp : StreamTimeStamp! {
        didSet {
            if timestamp != oldValue {
                if !player.stream!.isUserStream {
                    self.handleTimeStampChange(timestamp)
                }
            }
        }
    }
    
    init(player: WildPlayer) {
        self.player = player
    }
    
    func playerTimeUpdated(time: CMTime) {
        
        if player.stream != nil && player.stream!.isUserStream {
            let timeS = CMTimeGetSeconds(time)
            if (self.oldUpdate != nil && (abs(timeS - self.oldUpdate!) < updateInterval)){
                return
            }
            
            if needsUpdate {
                let timestamp = StreamTimeStamp()
                timestamp.stream_id = player.stream!.o_id
                timestamp.player_time = CMTimeGetSeconds(time)
                timestamp.timeStamp = NSDate().timeIntervalSince1970 - offSet
                timestamp.playlist_index = player.currentIndex
                
                player.stream?.update(["timestamp" : timestamp])
                needsUpdate = false
            }
        } else {
            let timeS = CMTimeGetSeconds(time)
            if (self.oldUpdate != nil && (abs(timeS - self.oldUpdate!) < updateInterval)){
                return
            } else {
                self.checkTimeSync()
            }
        }
        
    }
}

extension WildPlayerSyncManager {
    
    func handleTimeStampChange(ts: StreamTimeStamp){
        if player.currentIndex != ts.playlist_index {
            self.player.isSyncing = true
            player.currentIndex = ts.playlist_index as Int
            player.trackManager.reloadTrackData(player.stream!)
            handleTimeStampChange(ts)
        } else {
            self.checkTimeSync()
        }
    }
    
    func checkTimeSync(){
        
        let hpt = self.timestamp.player_time as Double
        let hlut = self.timestamp.timeStamp as Double + offSet
        
        if player.currentIndex != self.timestamp.playlist_index {
            //do not update time until song indices are the same.
            return
        }
        
        let now = NSDate().timeIntervalSince1970
        let diff = now - hlut
        let playerNewTime = hpt + diff
        
        let actualTime = CMTimeGetSeconds(self.player.currentTime())
        let clockTime = CMClockGetTime(CMClockGetHostTimeClock())
        
        
        
        
        if let item = self.player.currentItem where !self.player.isPlaying && self.player.readyToPlay {
            
            self.player.seekToTime(CMTimeMakeWithSeconds((playerNewTime + 1), item.asset.duration.timescale), completionHandler: {
                
                cb in
                self.player.setRate(1, time: CMTimeMakeWithSeconds((playerNewTime + 0.25), self.player.currentItem!.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime), self.player.currentItem!.asset.duration.timescale) )
                self.checkTimeSync()
            })
            self.player.isSyncing = true
            
        } else if self.player.isPlaying {
            
            if abs(playerNewTime - actualTime) > 0.01 {
                
                self.player.setRate(1, time: CMTimeMakeWithSeconds((playerNewTime), self.player.currentItem!.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime), self.player.currentItem!.asset.duration.timescale) )
                self.player.isSyncing = true
                
            } else {
                
                self.player.isSyncing = false
            
            }
        }
    }
}
