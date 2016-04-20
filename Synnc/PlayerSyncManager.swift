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
    
//    weak var player: WildPlayer!
    
    var updateInterval : Double = 2.0
    var oldUpdate : Float64?
    var timeUpdateData : JSON!
    var offSet : NSTimeInterval = 0
    var needsUpdate : Bool = true
    var canTimeSynnc : Bool = false
    var canSeek : Bool = true
    
    var timestamp : StreamTimeStamp! {
        didSet {
            if timestamp != oldValue {
                print("timestamp changed", StreamPlayerManager.sharedInstance.stream)
                if let stream = StreamPlayerManager.sharedInstance.stream where !stream.isUserStream {
                    print("listener")
                    self.handleTimeStampChange(timestamp)
                } else {
                    print("host")
                }
            }
        }
    }

    init() {
        
    }
    func playerTimeUpdated(time: CMTime, infoDict: [String : AnyObject]?) {
        
        if let dict = infoDict, let stream = dict["stream"] as? Stream, let streamId = dict["id"] as? String, let currentIndex = dict["currentIndex"] as? Int {
            let timeS = CMTimeGetSeconds(time)
            
            if timeS == 0 || (self.oldUpdate != nil && (abs(timeS - self.oldUpdate!) < updateInterval)){
                return
            }
            
            if needsUpdate {
                let timestamp = StreamTimeStamp()
                timestamp.stream_id = streamId
                timestamp.player_time = CMTimeGetSeconds(time)
                
                var date : NSDate
                if NHNetworkClock.sharedNetworkClock().isSynchronized {
                    date = NSDate.networkDate()
                } else {
                    date = NSDate()
                }
                
                timestamp.timeStamp = date.timeIntervalSince1970
                timestamp.playlist_index = currentIndex
                
                var update : [String : AnyObject] = [String : AnyObject]()
                update["timestamp"] = timestamp
                
                if currentIndex != stream.currentSongIndex {
                    update["currentSongIndex"] = currentIndex
                    print("update currentSongIndex:", currentIndex)
                }
                stream.update(update)
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
        let manager = StreamPlayerManager.sharedInstance
        if manager.currentIndex != ts.playlist_index {
//            manager.isSyncing = true
            
            print("handleTimeStampChange")
            
            let index = ts.playlist_index as Int
            
            
            manager.loadSong(ts.playlist_index as Int)
            manager.loadSong((ts.playlist_index as Int) + 1)
            
            let ind = ts.playlist_index as Int
//            if ind < ts.pla
            let manager = StreamPlayerManager.sharedInstance
            if ind < manager.playlist.count && ind == manager.stream!.currentSongIndex as Int {
                let track = manager.playlist[ind]
                if let info = manager.playerIndexedPlaylist[track], let player = manager.players[info.player] {
                    manager.activePlayer = player
                }
            }
            manager.play()
            
//            player.trackManager.reloadTrackData(player.stream!)
//            player.currentIndex = ts.playlist_index as Int
//            handleTimeStampChange(ts)
        } else {
            Async.main {
                self.checkTimeSync()
            }
        }
    }
    
    func checkTimeSync(){
        
        let manager = StreamPlayerManager.sharedInstance
        let hpt = self.timestamp.player_time as Double
        let hlut = self.timestamp.timeStamp as Double
        
        if manager.currentIndex != self.timestamp.playlist_index {
            print("indexes are not the same", manager.currentIndex, self.timestamp.playlist_index)
//            manager.rate = 0
            //do not update time until song indices are the same.
            return
        }
        
        var date : NSDate
        if NHNetworkClock.sharedNetworkClock().isSynchronized {
            date = NSDate.networkDate()
        } else {
            date = NSDate()
        }
        
        let now = date.timeIntervalSince1970
        let diff = now - hlut
        let playerNewTime = hpt + diff
        
        let actualTime = CMTimeGetSeconds(manager.currentTime!)
        let clockTime = CMClockGetTime(CMClockGetHostTimeClock())
 
        if let item = manager.currentItem as? AVPlayerItem {
            
            if actualTime/item.asset.duration.seconds >= 1 {
                manager.rate = 0
                return
            }
            
            if abs(playerNewTime - actualTime) > 0.02 {
                
                if playerNewTime/item.asset.duration.seconds < 0.97 {
                    
                    Async.background {
                        if item.status == AVPlayerItemStatus.ReadyToPlay && !manager.isSyncing {
                            
                            for seekableRange in item.seekableTimeRanges {
                                let range = seekableRange.CMTimeRangeValue
                                if playerNewTime <= CMTimeGetSeconds(range.duration) {
                                    manager.isSyncing = true
                                    Async.main {
                                        manager.activePlayer.setRate(1, time: CMTimeMakeWithSeconds((playerNewTime), item.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime), item.asset.duration.timescale) )
                                    }
                                    continue
                                } else {
                                    print("LIMBO", playerNewTime, CMTimeGetSeconds(range.duration), item.seekableTimeRanges)
                                }
                            }
                            
                        } else {
                            if item.status == AVPlayerItemStatus.ReadyToPlay {
                                if let range = item.loadedTimeRanges.first?.CMTimeRangeValue {
                                    if playerNewTime <= CMTimeGetSeconds(range.duration) {
                                        manager.isSyncing = false
                                        self.checkTimeSync()
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                }
                
            } else {
                manager.isSyncing = false
            }
        }
    }
}
