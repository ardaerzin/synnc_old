//
//  WildPlayer.swift
//  RadioHunt
//
//  Created by Arda Erzin on 9/8/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import WCLUtilities
import SocketIOClientSwift
import WCLSoundCloudKit
import WCLPopupManager

@objc protocol StreamerDelegate {
    optional func streamer(streamer : WildPlayer!, updatedToTime: CGFloat)
    optional func streamer(streamer : WildPlayer!, readyToPlay: Bool)
    optional func streamer(streamer : WildPlayer!, updatedToPosition position: CGFloat)
    optional func streamer(streamer : WildPlayer!, updatedRate rate: Float)
    optional func streamer(streamer : WildPlayer!, updatedPlaylistIndex index: Int)
    optional func streamer(streamer : WildPlayer!, updatedPreviewPosition position: CGFloat)
    optional func streamer(streamer : WildPlayer!, updatedPreviewStatus status: Bool)
    optional func streamer(streamer : WildPlayer!, isSyncing syncing : Bool)
    optional func endOfPlaylist(streamer : WildPlayer!)
}

class WildPlayer : AVQueuePlayer, AVAudioSessionDelegate {
    
    weak var stream : Stream? {
        willSet {
            if newValue != nil {
                self.endOfPlaylist = false
                self.syncManager.needsUpdate = true
            }
        }
    }
    
    var syncManager : WildPlayerSyncManager!
    var trackManager : WildPlayerTrackManager!
    var delegate : StreamerDelegate?
    var fadeDuration = 1.0
    
    var previousRate : Float! = 0
    
    var isSyncing : Bool! {
        didSet {
            if isSyncing != oldValue {
                self.delegate?.streamer?(self, isSyncing: isSyncing)
            }
        }
    }
    var isPlaying : Bool {
        get {
            if self.rate > 0 && self.error == nil {
                return true
            } else {
                return false
            }
        }
    }
    var currentIndex : Int = -1 {
        didSet{
            if currentIndex != oldValue && self.stream != nil {
                if self.stream != nil && self.stream === StreamManager.sharedInstance.userStream {
                    if self.stream == Synnc.sharedInstance.streamManager.userStream {
                        self.stream?.update(["currentSongIndex" : currentIndex])
                    }
                    self.delegate?.streamer?(self, updatedPlaylistIndex: currentIndex)
                }
            }
        }
    }
    var readyToPlay : Bool = false {
        willSet {
            self.delegate?.streamer?(self, readyToPlay: readyToPlay)
        }
    }
    var endOfPlaylist : Bool = false {
        willSet {
            if newValue && newValue != endOfPlaylist {
                
                if newValue {
                    
                    if let s = self.stream {
                        StreamManager.sharedInstance.finishedStream(s, completion: nil)
                    }
                }
            }
        }
    }
    var playbackPeriodicObserver : AnyObject!
    var fadeoutObserver : AnyObject!
    var needsPlay = false
    
    override var rate : Float {
        didSet {
            if rate != oldValue {
                playerRateChanged()
            }
        }
    }
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    init(socket: SocketIOClient) {
        super.init()
        
        self.addObserver(self, forKeyPath: "status", options: [], context: nil)
        self.addObserver(self, forKeyPath: "currentItem", options: [], context: nil)
        
        playbackPeriodicObserver = self.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1.0/5.0 , 100), queue: nil, usingBlock: {
            
            [unowned self]
            time in
            
            if self.currentItem == nil {
                return
            }
            self.playerTimeUpdated(time)
            })
        
        self.trackManager = WildPlayerTrackManager(player: self)
        self.syncManager = WildPlayerSyncManager(player: self)
    }
    
    // MARK: Methods
    
    func playerTimeUpdated(time: CMTime){
        self.delegate?.streamer?(self, updatedToPosition: CGFloat(CMTimeGetSeconds(time)) / CGFloat(CMTimeGetSeconds(self.currentItem!.duration)))
    }
    override func play(){
        if self.readyToPlay {
            self.rate = 1
            needsPlay = false
        } else {
            needsPlay = true
        }
    }
    override func pause(){
        let pauseTime = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.currentTime()) + fadeDuration, self.currentItem!.asset.duration.timescale)
        self.fadeVolume(toValue: 0)
        
        fadeoutObserver = self.addBoundaryTimeObserverForTimes([NSValue(CMTime: pauseTime)], queue: nil, usingBlock: {
            self.rate = 0
        })
    }
    
    func fadeVolume(toValue value: Float){
        let item = self.currentItem
        
        if item == nil {
            return
        }
        
//        var audioTracks = item!.asset.tracksWithMediaType(AVMediaTypeAudio)
//        var currentTime = self.currentTime()
//        var timescale = item!.asset.duration.timescale
//        
//        var allAudioParams = NSMutableArray()
        
        
        //        for track in audioTracks {
        //            var currentTime = CMTimeGetSeconds(currentTime) == 0.0 ? CMTimeMake(0, timescale) : CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime), timescale)
        //
        //            var inputParams = AVMutableAudioMixInputParameters(track: track as! AVAssetTrack)
        //            inputParams.setVolumeRampFromStartVolume(value == 0 ? 1 : 0, toEndVolume: value, timeRange: CMTimeRangeMake(currentTime, CMTimeMakeWithSeconds(fadeDuration , 1)))
        //
        //            allAudioParams.addObject(inputParams)
        //        }
        //
        //        var audioMix = AVMutableAudioMix()
        //        audioMix.inputParameters = allAudioParams as [AnyObject]
        //
        //        item.audioMix = audioMix
    }
    
    // MARK: Key Value Observer
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === self, let path = keyPath {
            
            switch path {
                
            case "status" :
                playerStatusChanged()
                break
            case "currentItem" :
                currentItemChanged()
                break
            default:
                return
                
            }
        }
    }
    
    // MARK: Observation Handlers
    func currentItemChanged(){
        
        print("*****Current item changed", self.currentItem)
        //        if self.stream == nil {
        //            return
        //        }
        
        if self.currentItem == nil && !self.trackManager.isLoadingTrackData {
            print("end of playlist")
            self.endOfPlaylist = true
            self.rate = 0
            return
        }
        
        if let item = self.currentItem as? WildPlayerItem {
            currentIndex = item.index
            
            if item.status == AVPlayerItemStatus.ReadyToPlay {
            
                self.setRate(1, time: CMTimeMakeWithSeconds((0), self.currentItem!.asset.duration.timescale), atHostTime: CMTimeMakeWithSeconds(CMTimeGetSeconds(CMClockGetTime(CMClockGetHostTimeClock())), self.currentItem!.asset.duration.timescale) )
                print("current item changed ", item.index)
            } else {
                self.rate = 0
            }
        }
    }
    func playerRateChanged(){
        
        //        println("*****Player rate changed: \(self.rate)")
        
        if self.rate == previousRate {
            return
        }
        let rate = self.rate
        
        //        var songInfo : [NSObject : AnyObject] = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo != nil ? MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo : [NSObject : AnyObject]()
        //        songInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        //        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.currentTime())
        //        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        
        self.delegate?.streamer?(self, updatedRate: rate)
        if rate == 1 {
            self.fadeVolume(toValue: 1)
        }
        previousRate = rate
    }
    func playerStatusChanged(){
        //        println("*****Player status changed")
        switch self.status {
        case .Failed:
            break
        case .ReadyToPlay:
            self.readyToPlay = true
            if let s = self.stream where !s.isUserStream {
                self.syncManager.checkTimeSync()
//                self.play()
            }
            //            if timeUpdateData != nil {
            //                self.handleTimeUpdate(timeUpdateData)
            //            }
            
            if self.needsPlay {
                self.play()
            }
            break
        default:
            break
        }
    }
    
    
    func resetPlayer(){
        self.rate = 0
        
        for item in self.items().reverse() {
            self.trackManager.dequeueItem(item)
        }
        
        self.stream = nil
    }
    
    
    func didSetActiveStream(stream: Stream?, needsReload : Bool) {
        
        if let st = stream {
            self.stream = st
            if needsReload {
                self.trackManager.reloadTrackData(st)
            }
        } else {
            resetPlayer()
        }
        
    }
}

extension WildPlayer : WildPlayerItemDelegate {
    func wildPlayerItem(itemStatusChangedForItem item: WildPlayerItem) {
        
//        let ind = self.items().indexOf(item)
        switch item.status {
        case .ReadyToPlay:
            break
        case .Failed:
            break
        case .Unknown:
            break
        }
    }
    func wildPlayerItem(itemDidPlayToEnd item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(loadedItemTimeRangesForItem item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(metadataUpdatedForItem item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(playbackBufferEmptyForItem item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(playbackBufferFullForItem item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(playbackLikelyToKeepUpForItem item: WildPlayerItem) {
        //nothing... for now
    }
    func wildPlayerItem(playbackStalledForItem item: WildPlayerItem) {
        //nothing... for now
    }
}
