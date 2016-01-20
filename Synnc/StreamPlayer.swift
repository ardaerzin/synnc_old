//
//  StreamPlayer.swift
//  RadioHunt
//
//  Created by Arda Erzin on 9/8/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import WCLUtilities
import WCLSoundCloudKit
import CoreMedia
import UIKit
import SDWebImage
import SocketIOClientSwift

class StreamPlayer : WildPlayer {
    
    //    var maxPreviewDuration : Double = 10
    //    var previewPlayer : Bool = false
    
    var nowPlayingInfo : [String : AnyObject] = [String : AnyObject]()
    let imgManager: SDWebImageManager = SDWebImageManager.sharedManager()
    let imgQueue = dispatch_queue_create("controlCenterImage",dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))
    //    let playerQueue = dispatch_queue_create("playerQueue",dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))
    
    //    var isPlaying : Bool {
    //        get {
    //            if self.player.rate > 0 && self.player.error == nil {
    //                return true
    //            } else {
    //                return false
    //            }
    //        }
    //    }
    //    var currentIndex : Int = -1 {
    //        didSet{
    //            if currentIndex != oldValue && self.stream != nil {
    //                if self.stream != nil && self.stream === MusicApp.sharedInstance().streamManager.userStream {
    //                    var dict = ["currentSongIndex" : currentIndex]
    //                    self.stream!.fromJSON(JSON(dict))
    //                }
    //            }
    //        }
    //    }
    var playerReadyToPlay : Bool = false {
        willSet {
            self.delegate?.streamer?(self, readyToPlay: playerReadyToPlay)
        }
    }
    //    var isSeeking : Bool = false
    //    var isSyncing : Bool = false {
    //        didSet {
    //            if !isSyncing && isSyncing != oldValue {
    //                fadeVolume(toValue: 1)
    //            }
    //        }
    //        willSet {
    //            if newValue == true && isSyncing != newValue {
    //                fadeVolume(toValue: 0)
    //            }
    //        }
    //    }
    //    var endOfPlaylist : Bool = false {
    //        willSet {
    //            if newValue && newValue != endOfPlaylist {
    //                self.player.pause()
    //                self.delegate?.endOfPlaylist?(self)
    //            }
    //        }
    //    }
    
    override init(){
        super.init()
        setupMainPlayer()
    }
    
    override init(socket: SocketIOClient) {
        super.init(socket: socket)
        setupMainPlayer()
    }
    
    override func playerTimeUpdated(time: CMTime) {
        super.playerTimeUpdated(time)
        self.syncManager.playerTimeUpdated(time)
    }
    
    func setupMainPlayer() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            } catch let error as NSError {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    //Mark: Player Controls
    override func seekToPosition(position: CGFloat) {
        super.seekToPosition(position)
        updateControlCenterRate()
    }
    func updateControlCenterRate(){
        if self.currentItem != nil && MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] != nil && (MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo![MPMediaItemPropertyPlaybackDuration]! as! NSTimeInterval) != NSTimeInterval(CMTimeGetSeconds(self.currentItem!.duration)) {
            
            nowPlayingInfo.updateValue(NSTimeInterval(CMTimeGetSeconds(self.currentItem!.duration)), forKey: MPMediaItemPropertyPlaybackDuration)
        }
        
        nowPlayingInfo.updateValue(self.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        nowPlayingInfo.updateValue(CMTimeGetSeconds(self.currentTime()), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateControlCenterItem(){
        
        if self.currentItem == nil {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [String : AnyObject]()
            return
        }
        
        nowPlayingInfo.updateValue(NSTimeInterval(CMTimeGetSeconds(self.currentItem!.duration)), forKey: MPMediaItemPropertyPlaybackDuration)
        nowPlayingInfo.updateValue(self.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        nowPlayingInfo.updateValue(CMTimeGetSeconds(self.currentTime()), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        if self.currentItem != nil && self.stream != nil {
//            WildSoundCloud.sharedInstance().track(self.stream!.songIds[currentIndex], cb: {
//                [weak self]
//                (response, data, error, timestamp) in
//
//                if data == nil {
//                    return
//                }
//                var song = data![0] as! SoundCloudTrack
//                self!.nowPlayingInfo.updateValue(song.title, forKey: MPMediaItemPropertyTitle)
//                
//                dispatch_async(self!.imgQueue, {
//                    var urlStr = song.artwork_url != nil ? song.artwork_url.stringByReplacingOccurrencesOfString("large", withString: "t500x500", options: nil, range: nil) : "http://icons.iconarchive.com/icons/pelfusion/long-shadow-media/128/Contact-icon.png"
//                    var x = self!.imgManager.downloadImageWithURL( NSURL(string: urlStr) , options: nil, progress: nil, completed: {
//                        [weak self]
//                        (cb) in
//                        if cb.0 == nil {
//                            return
//                        }
//                        dispatch_async(dispatch_get_main_queue(), {
//                            var albumArt = MPMediaItemArtwork(image: cb.0)
//                            self!.nowPlayingInfo.updateValue(albumArt, forKey: MPMediaItemPropertyArtwork)
//                            self!.nowPlayingInfo.updateValue(NSTimeInterval(CMTimeGetSeconds(self!.currentItem.duration)), forKey: MPMediaItemPropertyPlaybackDuration)
//                            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self!.nowPlayingInfo
//                        })
//                        })
//                })
//                })
        }
        
    }
    
    //Mark: Observers
    
    
    
    //Mark: StreamManager Delegate
    //    var hostPlayerTime : Double!
    //    var hostLastUpdateTime : Double!
    //    var playerNewTime : Double!
    
    //    func checkTimeSync(){
    //        if hostLastUpdateTime == nil || hostPlayerTime == nil {
    //            return
    //        }
    //        var now = NSDate().timeIntervalSince1970
    //        var diff = now - hostLastUpdateTime
    //
    //        playerNewTime = hostPlayerTime + diff
    //
    //        var actualTime = CMTimeGetSeconds(self.player.currentTime())
    //        var clockTime = CMClockGetTime(CMClockGetHostTimeClock())
    //
    //        if !self.isPlaying && self.playerReadyToPlay {
    //            self.player.seekToTime(CMTimeMakeWithSeconds((playerNewTime - 1), self.player.currentItem.asset.duration.timescale), completionHandler: {
    //
    //                cb in
    //                self.player.setRate(1, time: CMTimeMakeWithSeconds((self.playerNewTime+0.25), self.player.currentItem.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime)+0.25, self.player.currentItem.asset.duration.timescale) )
    //            })
    //            self.isSyncing = true
    //
    //        } else if self.isPlaying {
    //            if abs(playerNewTime - actualTime) > 0.01 {
    //                self.player.setRate(1, time: CMTimeMakeWithSeconds((playerNewTime+0.1), self.player.currentItem.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(clockTime)+0.1, self.player.currentItem.asset.duration.timescale) )
    //                self.isSyncing = true
    //            } else {
    //                self.isSyncing = false
    //            }
    //        }
    //    }
    
    //    var timeUpdateData : JSON!
    //    func handleTimeUpdate(data: JSON){
    //        if !playerReadyToPlay{
    //            timeUpdateData = data
    ////            return
    //        }
    //        var pInd = data["playlist_index"].intValue
    //        if data["stream_id"].stringValue == self.stream!.o_id {
    //            //set track data
    //
    //            if self.currentIndex != pInd {
    //                self.currentIndex = pInd
    //                self.reloadTrackData(self.stream!)
    //            } else {
    //                self.hostPlayerTime = data["player_time"].double!
    //                self.hostLastUpdateTime = data["timeStamp"].double!
    //                self.checkTimeSync()
    //            }
    //        }
    //    }
    
//    override var stream : Stream? {
//        get {
//            return nil
//        }
//    }
    
    override func currentItemChanged() {
        super.currentItemChanged()
        
        updateControlCenterItem()
    }
    override func playerRateChanged() {
        super.playerRateChanged()
        updateControlCenterRate()
    }
    
    func reloadTrackData(stream: Stream){
    }
    
    override func streamManager(manager: StreamManager, didSetActiveStream stream: Stream?) {
        super.streamManager(manager, didSetActiveStream: stream)
    }
}