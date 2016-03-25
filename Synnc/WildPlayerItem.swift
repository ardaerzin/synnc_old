//
//  WildPlayerItem.swift
//  Music App
//
//  Created by Arda Erzin on 6/1/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

@objc protocol WildPlayerItemDelegate {
    optional func wildPlayerItem(metadataUpdatedForItem item: WildPlayerItem)
    optional func wildPlayerItem(itemStatusChangedForItem item: WildPlayerItem)
    optional func wildPlayerItem(loadedItemTimeRangesForItem item: WildPlayerItem)
    optional func wildPlayerItem(playbackBufferFullForItem item: WildPlayerItem)
    optional func wildPlayerItem(playbackBufferEmptyForItem item: WildPlayerItem)
    optional func wildPlayerItem(playbackLikelyToKeepUpForItem item: WildPlayerItem)
    
    optional func wildPlayerItem(itemDidPlayToEnd item: WildPlayerItem)
    optional func wildPlayerItem(playbackStalledForItem item: WildPlayerItem)

}

class WildPlayerItem : AVPlayerItem {

    weak var player : WildPlayer!
    var delegate : WildPlayerItemDelegate?
    var index: Int! = -1
    var observedKeys : [String] = ["status", "loadedTimeRanges", "playbackBufferFull", "playbackBufferEmpty", "playbackLikelyToKeepUp", "timedMetadata"]
    
    deinit {
        if self.player != nil {
            for keyPath in observedKeys {
                self.removeObserver(self, forKeyPath: keyPath)
            }
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemPlaybackStalledNotification, object: self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self)
    }
    
    convenience init!(URL: NSURL, player : WildPlayer!, delegate: WildPlayerItemDelegate?, index: Int) {
        self.init(URL: URL, player : player)
        self.delegate = delegate
        self.index = index
    }
    init!(URL: NSURL, player : WildPlayer!) {
//        super.init(URL : URL)
        super.init(asset: AVAsset(URL: URL), automaticallyLoadedAssetKeys: nil)
//        super.init(asset: AVAsset(URL: URL))
        self.player = player
        
        addObservers()
    }
    
    
    
    func addObservers(){
        
        for keyPath in observedKeys {
            self.addObserver(self, forKeyPath: keyPath, options: NSKeyValueObservingOptions.New, context: nil)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WildPlayerItem.playbackStalled(_:)), name: AVPlayerItemPlaybackStalledNotification, object: self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WildPlayerItem.didPlayToEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self)
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
//        _ = object as! AVPlayerItem
        
        if self.delegate == nil {
            return
        }
        
        if keyPath == "timedMetadata" {
            self.delegate?.wildPlayerItem?(metadataUpdatedForItem: self)
        } else if keyPath == "status" {
            self.delegate?.wildPlayerItem?(itemStatusChangedForItem: self)
        } else if keyPath == "loadedTimeRanges" {
            self.delegate?.wildPlayerItem?(loadedItemTimeRangesForItem: self)
        } else if keyPath == "playbackBufferFull" {
            self.delegate?.wildPlayerItem?(playbackBufferFullForItem: self)
        } else if keyPath == "playbackBufferEmpty" {
            self.delegate?.wildPlayerItem?(playbackBufferEmptyForItem: self)
        } else if keyPath == "playbackLikelyToKeepUp" {
            self.delegate?.wildPlayerItem?(playbackLikelyToKeepUpForItem: self)
        }
        
    }
    
    func playbackStalled(notification: NSNotification){
        
        self.delegate?.wildPlayerItem?(playbackStalledForItem: self)
        //        println("PLAYBACK STALLED")
        //        println(notification)
    }
    func didPlayToEnd(notification: NSNotification) {
        self.delegate?.wildPlayerItem?(itemDidPlayToEnd: self)
    }
}