//
//  PlayerManager+UpdateCenter.swift
//  Synnc
//
//  Created by Arda Erzin on 4/14/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import Cloudinary
import MediaPlayer
import CoreMedia
import AsyncDisplayKit
import WCLUtilities
import Async

extension StreamPlayerManager {
    //Mark: Player Controls
    func updateControlCenterControls(){
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = true
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.addTarget(self, action: #selector(StreamPlayerManager.bookmarkAction(_:)))
        
        MPRemoteCommandCenter.sharedCommandCenter().togglePlayPauseCommand.enabled = true
        MPRemoteCommandCenter.sharedCommandCenter().togglePlayPauseCommand.addTarget(self, action: #selector(StreamPlayerManager.remotePlayPauseStream(_:)))
    }
    func updateControlCenterRate(){
        guard let ci = currentItem, let ct = currentTime else {
            print(#function, "nil")
            return
        }
        let duration = self.currentItemDuration
        
        if let info = MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo where info[MPMediaItemPropertyPlaybackDuration] != nil && (info[MPMediaItemPropertyPlaybackDuration]! as! NSTimeInterval) != NSTimeInterval(duration) {
            
            nowPlayingInfo.updateValue(NSTimeInterval(duration), forKey: MPMediaItemPropertyPlaybackDuration)
        }
        
        nowPlayingInfo.updateValue(self.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        nowPlayingInfo.updateValue(CMTimeGetSeconds(ct), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateControlCenterItem(){
        
        let ci = self.currentIndex as Int
        print(self.stream, self.currentItem)
        guard let st = self.stream, let npi = self.currentItem, let ct = currentTime where ci >= 0 else {
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = [String : AnyObject]()
            print(#function, "nil")
            return
        }
        let duration = self.currentItemDuration
        let track = st.playlist.songs[ci]
        
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = false
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist.hasTrack(track) {
            MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.localizedTitle = "Remove Song from Favorites"
        } else {
            MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.localizedTitle = "Add Song to Favorites"
        }
        MPRemoteCommandCenter.sharedCommandCenter().bookmarkCommand.enabled = true
        
        nowPlayingInfo.updateValue(NSTimeInterval(duration), forKey: MPMediaItemPropertyPlaybackDuration)
        
        nowPlayingInfo.updateValue(self.rate, forKey: MPNowPlayingInfoPropertyPlaybackRate)
        nowPlayingInfo.updateValue(CMTimeGetSeconds(ct), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
        
        let name = st.playlist.name == nil ? "Untitled" : st.playlist.name!
        nowPlayingInfo.updateValue(track.name, forKey: MPMediaItemPropertyTitle)
        nowPlayingInfo.updateValue(name + ", by " + st.user.username, forKey: MPMediaItemPropertyArtist)
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.nowPlayingInfo
        
        let downloader = ASPINRemoteImageDownloader.sharedDownloader()
        
        let transformation = CLTransformation()
        
        transformation.width = 500 * UIScreen.mainScreen().scale
        transformation.height = 500 * UIScreen.mainScreen().scale
        
        transformation.crop = "fill"
        
        if let str = st.playlist.cover_id, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            
            
            downloader.downloadImageWithURL(url, callbackQueue: dispatch_get_main_queue(), downloadProgress: nil) {
                (img, err, id) -> Void in
                if let image = img {
                    let albumArt = MPMediaItemArtwork(image: image)
                    self.nowPlayingInfo.updateValue(albumArt, forKey: MPMediaItemPropertyArtwork)
                }
                
                self.nowPlayingInfo.updateValue(NSTimeInterval(duration), forKey: MPMediaItemPropertyPlaybackDuration)
                Async.main {
                    MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = self.nowPlayingInfo
                }
//                    self.nowPlayingInfo
            }
            
        }
        
    }
    
    func userFavPlaylistUpdated(notification: NSNotification){
        self.updateControlCenterItem()
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
}