//
//  WildPlayerSyncManager.swift
//  Music App
//
//  Created by Arda Erzin on 6/4/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import AVFoundation
import WCLUtilities
import SwiftyJSON

class WildPlayerSyncManager {
    
    weak var socket: SocketIOClient!
    weak var player: WildPlayer!
    
    var hostPlayerTime : Double!
    var hostLastUpdateTime : Double!
    var playerNewTime : Double!
    
    var updateInterval : Double = 3.0
    var oldUpdate : Float64?
    var timeUpdateData : JSON!
    var offSet : NSTimeInterval = 0
    
    init(socket: SocketIOClient, player: WildPlayer) {
        self.player = player
        self.socket = socket
        
        self.socket.on("Stream:timeUpdate", callback: timeUpdateHandler())
    }
    
    func timeUpdateHandler() -> NormalCallback {
        return {
            (dataArr, ack) in
            print("received time update")
            if let data = dataArr.first {
                let json = JSON(data)
                if json["stream_id"].string == self.player.stream?.o_id && self.player.stream != Synnc.sharedInstance.streamManager.userStream {
                    self.handleTimeUpdate(json)
                }
            }
        }
    }
    
    func playerTimeUpdated(time: CMTime) {
        
        if player.stream != nil && player.stream!.isUserStream {
            let timeS = CMTimeGetSeconds(time)
            if player.isSeeking || (self.oldUpdate != nil && (abs(timeS - self.oldUpdate!) < updateInterval)){
                return
            }
            
//            let dict = ["stream_id" : player.stream!.o_id, "player_time": CMTimeGetSeconds(time), "timeStamp" : NSDate().timeIntervalSince1970, "playlist_index" : player.currentIndex]
            
            let dict = ["stream_id" : player.stream!.o_id, "player_time": CMTimeGetSeconds(time), "timeStamp" : NSDate().timeIntervalSince1970 - offSet, "playlist_index" : player.currentIndex]
            self.oldUpdate = CMTimeGetSeconds(time)
            socket.emitWithAck("Stream:timeUpdate", dict)(timeoutAfter: 0) {
                data in
            }
            
        }
        
    }

    
    func handleTimeUpdate(data: JSON){
        if !player.readyToPlay{
            timeUpdateData = data
            //            return
        }
        
        print("handle time update")
    
        let pInd = data["playlist_index"].intValue
        if data["stream_id"].stringValue == player.stream!.o_id {
            //set track data
            
            if player.currentIndex != pInd {
                self.player.isSyncing = true
                player.currentIndex = pInd
                player.trackManager.reloadTrackData(player.stream!)
            } else {
                self.hostPlayerTime = data["player_time"].double!
                self.hostLastUpdateTime = data["timeStamp"].double! + offSet
                self.checkTimeSync()
            }
        }
    }
    
    
    func checkTimeSync(){
        if hostLastUpdateTime == nil || hostPlayerTime == nil {
            return
        }
        let now = NSDate().timeIntervalSince1970
        let diff = now - hostLastUpdateTime
        
//        print(diff, NSDate(timeIntervalSince1970: hostLastUpdateTime), NSDate(timeIntervalSinceReferenceDate: hostLastUpdateTime))
        playerNewTime = hostPlayerTime + diff
        
        let actualTime = CMTimeGetSeconds(self.player.currentTime())
        let clockTime = CMClockGetTime(CMClockGetHostTimeClock())
        
//        print("player new time:", playerNewTime, "actual time:", actualTime)
//        NSDate
        if !self.player.isPlaying && self.player.readyToPlay {
            
//            print("a")
            self.player.seekToTime(CMTimeMakeWithSeconds((playerNewTime - 1), self.player.currentItem!.asset.duration.timescale), completionHandler: {
                
                cb in
                self.player.setRate(1, time: CMTimeMakeWithSeconds((self.playerNewTime+0.25), self.player.currentItem!.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime)+0.25, self.player.currentItem!.asset.duration.timescale) )
            })
            self.player.isSyncing = true
            
        } else if self.player.isPlaying {
            
//            print("b")
            if abs(playerNewTime - actualTime) > 0.01 {
                self.player.setRate(1, time: CMTimeMakeWithSeconds((playerNewTime+0.1), self.player.currentItem!.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime)+0.1, self.player.currentItem!.asset.duration.timescale) )
                self.player.isSyncing = true
            
            } else {
                self.player.isSyncing = false
            }
        }
    }
}
