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
import SocketIOClientSwift
import WCLNotificationManager
import AsyncDisplayKit
import Cloudinary

class StreamPlayer : WildPlayer {
    
    var nowPlayingInfo : [String : AnyObject] = [String : AnyObject]()
    var isActiveSession : Bool = false
    
    override init(){
        super.init()
        setupMainPlayer()
    }
    
    override init(socket: SocketIOClient) {
        super.init(socket: socket)
        setupMainPlayer()
    }
    
    func audioRouteChanged(notification: NSNotification) {
        if let _ = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] {
            
            if let st = self.stream where st.status {
                
                if self.rate == 0 {
                    self.play()
                
                    if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                        WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Your stream is now Muted, but continues in the background", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                    }
                    
                    self.volume = 0
                }
            }
        }
    }
    
    override func playerTimeUpdated(time: CMTime) {
        super.playerTimeUpdated(time)
        self.syncManager.playerTimeUpdated(time)
    }
    
    func setActiveAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                self.isActiveSession = true
                updateControlCenterControls()
                print("set audio session")
            } catch let error as NSError {
                print(error)
                self.isActiveSession = false
            }
        } catch let error as NSError {
            print(error)
            self.isActiveSession = false
        }
    }
    
    func bookmarkAction(event: MPFeedbackCommandEvent) {
        
        guard let st = self.stream, let ind = st.currentSongIndex else {
            return
        }
        
        let song = st.playlist.songs[ind as Int]
        StreamManager.sharedInstance.toggleTrackFavStatus(song, callback: nil)
    }
    
    func remotePlayPauseStream(event: MPRemoteCommandEvent) {
        
    }
    
    func userFavPlaylistUpdated(notification: NSNotification){
        self.updateControlCenterItem()
    }
    
    func setupMainPlayer() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userFavPlaylistUpdated:"), name: "UpdatedFavPlaylist", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("audioRouteChanged:"), name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    override func play() {
        if !self.isActiveSession {
            setActiveAudioSession()
        }
        super.play()
    }
    
    //Mark: Player Controls
    func updateControlCenterControls(){
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = true
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.addTarget(self, action: Selector("bookmarkAction:"))
        
        MPRemoteCommandCenter.sharedCommandCenter().togglePlayPauseCommand.enabled = true
        MPRemoteCommandCenter.sharedCommandCenter().togglePlayPauseCommand.addTarget(self, action: Selector("remotePlayPauseStream:"))
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
        
        guard let st = self.stream, let ci = st.currentSongIndex, let npi = self.currentItem else {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [String : AnyObject]()
            return
        }
        
        let track = st.playlist.songs[ci as Int]
    
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = false
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist.hasTrack(track) {
            MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.localizedTitle = "Remove Song from Favorites"
        } else {
            MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.localizedTitle = "Add Song to Favorites"
        }
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = true
        
        nowPlayingInfo.updateValue(NSTimeInterval(CMTimeGetSeconds(self.currentItem!.duration)), forKey: MPMediaItemPropertyPlaybackDuration)
        
        nowPlayingInfo.updateValue(self.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        nowPlayingInfo.updateValue(CMTimeGetSeconds(self.currentTime()), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.nowPlayingInfo
        
        nowPlayingInfo.updateValue(track.name, forKey: MPMediaItemPropertyTitle)
        nowPlayingInfo.updateValue(st.name + ", by" + st.user.username, forKey: MPMediaItemPropertyArtist)
        
        
        let downloader = ASPINRemoteImageDownloader.sharedDownloader()
        
        let transformation = CLTransformation()
        
        transformation.width = 500 * UIScreen.mainScreen().scale
        transformation.height = 500 * UIScreen.mainScreen().scale
        
        transformation.crop = "fill"
        
        if let str = st.img, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            
            
            downloader.downloadImageWithURL(url, callbackQueue: dispatch_get_main_queue(), downloadProgress: nil) {
                (img, err, id) -> Void in
                if let image = img {
                    let albumArt = MPMediaItemArtwork(image: image)
                    self.nowPlayingInfo.updateValue(albumArt, forKey: MPMediaItemPropertyArtwork)
                }
                
                self.nowPlayingInfo.updateValue(NSTimeInterval(CMTimeGetSeconds(npi.duration)), forKey: MPMediaItemPropertyPlaybackDuration)
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.nowPlayingInfo
            }
            
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
        
        if let sm = self.syncManager {
            sm.needsUpdate = true
        }
    }
    
    func reloadTrackData(stream: Stream){
    }
    
    
    override func wildPlayerItem(playbackStalledForItem item: WildPlayerItem) {
        super.wildPlayerItem(playbackStalledForItem: item)
        self.syncManager.needsUpdate = true
    }
    
}