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
    func getPlayerQueueUrls() -> [String] {
        let prevURLs : [String] = (self.player.items()).map({
            
            if let urlAsset = $0.asset as? AVURLAsset {
                return urlAsset.URL.absoluteString
            }
            return ""
        })
        return prevURLs
    }
    
    func reloadTrackData(stream: Stream){
        
        if isLoadingTrackData {
            return
        }
        isLoadingTrackData = true
        
        for (index,song) in (stream.playlist.songs).enumerate() {
            if index >= player.currentIndex {
                let mediaItem = self.newItem(song: song, index: index)
                self.queueItem(mediaItem)
            }
        }
        
//        var pSet = Set(prevURLs)
//        var newURLs : [String] = stream.songIds.map({
//            return (WildSoundCloud.sharedInstance().streamURL(forTrackId: $0))!.absoluteString!
//        })
//        var cIndex = player.currentIndex
//        var prevItem : AVPlayerItem!
//        for (index,url) in enumerate(newURLs) {
//            
//            if index >= cIndex {
//                if let oldInd = find(prevURLs, url) {
//                    //yuklenmis asset
//                    var item : AVPlayerItem!
//                    var assetArr = (self.player.items() as! [AVPlayerItem]).filter({
//                        ($0.asset as! AVURLAsset).URL!.absoluteString! == url
//                    })
//                    if assetArr.count > 0 && (oldInd != (index-cIndex)) {
//                        item = assetArr[0]
//                        self.dequeueItem(item)
//                        self.queueItem(item)
//                    }
//                } else {
//                    // yuklenmemis asset. yeni yarat
//                    var item = newItem(str: url)
//                    self.queueItem(item)
//                }
//            } else {
//                if let oldInd = find(prevURLs, url) {
//                    self.dequeueItem(prevItemsArr[oldInd])
//                    prevURLs = getPlayerQueueUrls()
//                }
//            }
//            
//        }
        
        isLoadingTrackData = false
    }
    func newItem(song song: SynncTrack, index: Int) -> WildPlayerItem? {
        if let url = song.streamUrl {
            
        } else {
            print("YOKH")
        }
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
//        println(self.player)
        self.player.insertItem(item!, afterItem: nil)
    }
    func dequeueItem(avItem: AVPlayerItem){
        self.player.removeItem(avItem)
    }
}