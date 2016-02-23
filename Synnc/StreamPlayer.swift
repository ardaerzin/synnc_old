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
    
    var nowPlayingInfo : [String : AnyObject] = [String : AnyObject]()
    let imgManager: SDWebImageManager = SDWebImageManager.sharedManager()
    let imgQueue = dispatch_queue_create("controlCenterImage",dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))
    
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
    
    override func currentItemChanged() {
        super.currentItemChanged()
        
        self.syncManager.needsUpdate = true
        updateControlCenterItem()
    }
    override func playerRateChanged() {
        super.playerRateChanged()
        updateControlCenterRate()
    }
    
    func reloadTrackData(stream: Stream){
    }
    
    
    override func wildPlayerItem(playbackStalledForItem item: WildPlayerItem) {
        super.wildPlayerItem(playbackStalledForItem: item)
        self.syncManager.needsUpdate = true
    }
    
}