//
//  PlayerManager+AVPlayerItem.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

extension StreamPlayerManager {
    func playerItem(metadataUpdatedForItem item: AVPlayerItem) {
        
    }
    func playerItem(itemStatusChangedForItem item: AVPlayerItem) {
        
//        print("PlayerManager:","status changed for item", item, item.status == AVPlayerItemStatus.ReadyToPlay, self.currentItem, self.activePlayer)
        if item === self.currentItem {
            self.play()
        }
    }
    func playerItem(loadedItemTimeRangesForItem item: AVPlayerItem) {
        
        if let st = self.stream where !st.isUserStream && item === currentItem {
            self.syncManager.checkTimeSync()
            
            if self.rate == 0 {
                self.play()
            }
        }
        
    }
    func playerItem(playbackBufferFullForItem item: AVPlayerItem) {
        
    }
    func playerItem(playbackBufferEmptyForItem item: AVPlayerItem) {
        
    }
    func playerItem(playbackLikelyToKeepUpForItem item: AVPlayerItem) {
        
    }
    func playerItem(itemDidPlayToEnd item: AVPlayerItem) {
        
    }
    func playerItem(playbackStalledForItem item: AVPlayerItem) {
        print("PlayerManager:", "PLAYBACK STALLED")
        self.syncManager.needsUpdate = true
    }
}