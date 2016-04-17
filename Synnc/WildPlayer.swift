////
////  WildPlayer.swift
////  RadioHunt
////
////  Created by Arda Erzin on 9/8/15.
////  Copyright (c) 2015 Arda Erzin. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//import MediaPlayer
//import WCLUtilities
//import SocketIOClientSwift
//import WCLSoundCloudKit
//import WCLPopupManager
//
//class WildPlayer : AVQueuePlayer, AVAudioSessionDelegate {
//
////    var fadeDuration = 1.0
////    var fadeoutObserver : AnyObject!
//    
//    // MARK: Initializers
//    
//    override init() {
//        super.init()
//    }
//    
////    func fadeVolume(toValue value: Float){
////        let item = self.currentItem
////        
////        if item == nil {
////            return
////        }
//    
////        var audioTracks = item!.asset.tracksWithMediaType(AVMediaTypeAudio)
////        var currentTime = self.currentTime()
////        var timescale = item!.asset.duration.timescale
////        
////        var allAudioParams = NSMutableArray()
//        
//        
//        //        for track in audioTracks {
//        //            var currentTime = CMTimeGetSeconds(currentTime) == 0.0 ? CMTimeMake(0, timescale) : CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime), timescale)
//        //
//        //            var inputParams = AVMutableAudioMixInputParameters(track: track as! AVAssetTrack)
//        //            inputParams.setVolumeRampFromStartVolume(value == 0 ? 1 : 0, toEndVolume: value, timeRange: CMTimeRangeMake(currentTime, CMTimeMakeWithSeconds(fadeDuration , 1)))
//        //
//        //            allAudioParams.addObject(inputParams)
//        //        }
//        //
//        //        var audioMix = AVMutableAudioMix()
//        //        audioMix.inputParameters = allAudioParams as [AnyObject]
//        //
//        //        item.audioMix = audioMix
////    }
//    
//    
//    
//    // MARK: Observation Handlers
//}
//
//extension WildPlayer : WildPlayerItemDelegate {
////    func wildPlayerItem(itemStatusChangedForItem item: WildPlayerItem) {
////        
//////        let ind = self.items().indexOf(item)
////        switch item.status {
////        case .ReadyToPlay:
////            break
////        case .Failed:
////            break
////        case .Unknown:
////            break
////        }
////    }
////    func wildPlayerItem(itemDidPlayToEnd item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(loadedItemTimeRangesForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(metadataUpdatedForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(playbackBufferEmptyForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(playbackBufferFullForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(playbackLikelyToKeepUpForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
////    func wildPlayerItem(playbackStalledForItem item: WildPlayerItem) {
////        //nothing... for now
////    }
//}
