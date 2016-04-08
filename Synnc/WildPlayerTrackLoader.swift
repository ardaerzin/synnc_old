//
//  WildPlayerTrackLoader.swift
//  Music App
//
//  Created by Arda Erzin on 6/4/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import WCLSoundCloudKit

class WildPlayerTrackManager {
    
    // MARK: Properties
    weak var player: WildPlayer!
    var isLoadingTrackData : Bool = false
    
    // MARK: Initializers
    init(player: WildPlayer){
        self.player = player
    }

    // MARK: Methods
    
    func reloadTrackData(stream: Stream){
        
        if isLoadingTrackData {
            print("SECTOOOOOR")
            return
        }
//        self.player.rate = 0
        
        isLoadingTrackData = true
        
        player.rate = 0
        
        for item in player.items().reverse() {
            self.dequeueItem(item)
        }
        
        print("ITEMS", self.player.items())
        
        let i : Int = stream == StreamManager.sharedInstance.userStream ? self.player.currentIndex : Int(stream.timestamp!.playlist_index)
        for (index,song) in (stream.playlist.songs).enumerate() {
            if index >= i {
                let mediaItem = self.newItem(song: song, index: index)
                print("!*!*!*! add item", mediaItem!.index)
                self.queueItem(mediaItem)
            }
        }
        isLoadingTrackData = false
//        self.player.rate = 1
    }
    func newItem(song song: SynncTrack, index: Int) -> WildPlayerItem? {
        if let url = NSURL(string: song.streamUrl) {
            return newItem(url: url, index: index)
        }
        return nil
    }
    
    func newItem(str str : String, index: Int) -> WildPlayerItem? {
        let url = NSURL(string: str)
        return url == nil ? nil : newItem(url: url!, index: index)
    }
    func newItem(url url: NSURL, index: Int) -> WildPlayerItem? {
        let item = WildPlayerItem(URL: url, player: player, delegate: player, index: index)
        if item == nil {
            return nil
        }
        return item!
    }
    func queueItem(item: AVPlayerItem?, atIndex ind: Int){
        if item == nil {
            return
        }
        self.player.insertItem(item!, afterItem: ind != 0 ? self.player.items()[ind-1] : nil)
    }
    func queueItem(item: AVPlayerItem?){
        if item == nil {
            return
        }
        self.player.insertItem(item!, afterItem: nil)
    }
    func dequeueItem(avItem: AVPlayerItem){
        print("dequeue item", avItem, (avItem as! WildPlayerItem).index)
        self.player.removeItem(avItem)
    }
}