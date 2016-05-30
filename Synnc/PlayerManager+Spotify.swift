//
//  PlayerManager+Spotify.swift
//  Synnc
//
//  Created by Arda Erzin on 4/18/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox

//func renderCallback(inRefCon:UnsafeMutablePointer<Void>,
//                    ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                    inTimeStamp:UnsafePointer<AudioTimeStamp>,
//                    inBusNumber:UInt32,
//                    inNumberFrames:UInt32,
//                    ioData:UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
//    let delegate = unsafeBitCast(inRefCon, AURenderCallbackDelegate.self)
//    let result = delegate.performRender(ioActionFlags,
//                                        inTimeStamp: inTimeStamp,
//                                        inBusNumber: inBusNumber,
//                                        inNumberFrames: inNumberFrames,
//                                        ioData: ioData)
//    return result
//}
//
//@objc protocol AURenderCallbackDelegate {
//    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
//                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
//                       inBusNumber: UInt32,
//                       inNumberFrames: UInt32,
//                       ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
//}

//class SynncCoreAudioController : SPTCoreAudioController {
//    var myNode : AUNode = AUNode()
//    var myUnit : AudioUnit = nil
//    var graph : AUGraph?
//    var ioUnit : AudioUnit = nil
//    
//    override init() {
//        super.init()
//    }
//    
//    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
//        
//        var a = inTimeStamp.memory
//        if ioActionFlags.memory == .UnitRenderAction_PostRender {
//            
//            var timebaseInfo : mach_timebase_info = mach_timebase_info()
//            if timebaseInfo.denom == 0 {
//                mach_timebase_info(&timebaseInfo)
//            }
//            var time2nsFactor = UInt64(timebaseInfo.numer / timebaseInfo.denom)
//            let x : CGFloat = pow(10, 9)
//            var ts = a.mSampleTime * Float64(time2nsFactor/UInt64(x))
////            ioData.memory.mBuffers
//            
//            var a :  AudioTimeStamp = AudioTimeStamp()
//            
//            
//            var propSize: Int = sizeof(Int64)
//            var propSize32 = UInt32(1024)
//            
//            let eqFrequencies: [UInt32] = [ 32, 250, 500, 1000, 2000, 16000 ]
//            let b = AudioUnitGetProperty(myUnit, kAudioUnitProperty_CurrentPlayTime, AudioUnitScope(kAudioUnitScope_Global), 0, &a, &propSize32)
//        }
//        
//        return noErr
//    }
//    
//    func findCurrentFrame(){
//        
//    }
//    
//    override func connectOutputBus(sourceOutputBusNumber: UInt32, ofNode sourceNode: AUNode, toInputBus destinationInputBusNumber: UInt32, ofNode destinationNode: AUNode, inGraph graph: AUGraph) throws {
//        self.graph = graph
//        
//        try super.connectOutputBus(sourceOutputBusNumber, ofNode: sourceNode, toInputBus: destinationInputBusNumber, ofNode: destinationNode, inGraph: graph)
//    }
//}

class SynncSpotifyPlayer : SPTAudioStreamingController {
    
    var isSynced : Bool = false {
        didSet {
            if isSynced {
                self.setVolume(1, callback: nil)
            } else {
                self.setVolume(0, callback: nil)
            }
        }
    }
    var isSeeking : Bool = false
    let observedKeys : [String] = ["currentPlaybackPosition"]
    
    override init!(clientId: String!, audioController: SPTCoreAudioController!) {
        super.init(clientId: clientId, audioController: audioController)
    }
    override init!(clientId: String!) {
        
        super.init(clientId: clientId)
        self.shuffle = false
        self.setValue(false, forKey: "repeat")
        self.addObserver(self, forKeyPath: "currentPlaybackPosition", options: [], context: nil)
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let item = object as? SynncSpotifyPlayer {
            if StreamPlayerManager.sharedInstance.activePlayer === self {
                StreamPlayerManager.sharedInstance.playerTimeUpdated(CMTimeMakeWithSeconds(self.currentPlaybackPosition, 1000))
//                StreamPlayerManager.sharedInstance.updateControlCenterRate()
            }
            
        }
    }
}

extension StreamPlayerManager : SPTAudioStreamingPlaybackDelegate {
    func audioStreamingDidPopQueue(audioStreaming: SPTAudioStreamingController!) {
        print("DID POP QUEUE")
//        audioStreaming.queueClear(nil)
//        if let size = audioStreaming.queueSize {
//            
//        }
//        print(audioStreaming.queueSize)
        
        if self.endOfPlaylist {
            return
        }
        self.syncManager.needsUpdate = true
    }
    func audioStreamingDidSkipToNextTrack(audioStreaming: SPTAudioStreamingController!) {
        print("DID SKIP TO NEXT")
    }
    func audioStreamingDidSkipToPreviousTrack(audioStreaming: SPTAudioStreamingController!) {
        print("DID SKIP TO PREVIOUS")
    }
    func audioStreamingDidLosePermissionForPlayback(audioStreaming: SPTAudioStreamingController!) {
        print("DID LOSE PERMISSION")
    }
    func audioStreamingDidBecomeActivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        print("DID BECOME ACTIVE DEVICE")
    }
    func audioStreamingDidBecomeInactivePlaybackDevice(audioStreaming: SPTAudioStreamingController!) {
        print("DID BECOME INACTIVE DEVICE")
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
        self.delegate?.playerManager?(self, volumeChanged: Float(volume))
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didFailToPlayTrack trackUri: NSURL!) {
        print("DID FAIL TO PLAY TRACK", trackUri)
//        audioStreaming.queueURI(trackUri) {
//            error in
//            
//            if let err = error {
//                print("ERROR PLAYING URI", err.description)
//                return
//            }
//            print("successfully play track")
//        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: NSURL!) {
        guard let info = self.songInfo(trackUri) else {
            return
        }
        
        if info.index == self.playlist.count - 1 && !(CGFloat(CMTimeGetSeconds(self.currentTime!)) < self.currentItemDuration) {
            endOfPlaylist = true
            self.syncManager.needsUpdate = true
            return
        } else if !(CGFloat(CMTimeGetSeconds(self.currentTime!)) < self.currentItemDuration) {
            switchPlayers(info)
            self.syncManager.needsUpdate = true
            self.loadNextSongForPlayer(info)
        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        print("DID START PLAYING TRACK", trackUri)
        if audioStreaming === self.activePlayer {
            if self.rate == 0 {
                if !audioStreaming.isPlaying {
                    self.play()
//                    audioStreaming.setIsPlaying(true, callback: nil)
                }
            } else {
            }
            updateControlCenterItem()
            updateControlCenterRate()
        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: NSTimeInterval) {
        updateControlCenterItem()
        updateControlCenterRate()
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("DID CHANGE PLAYBACK STATUS", isPlaying)
        
        if audioStreaming === self.activePlayer {
            updateControlCenterRate()
        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if let data = trackMetadata {
            if let uri = data[SPTAudioStreamingMetadataTrackURI] as? String, let ci = self.currentItem as? NSURL where uri == ci.absoluteString {
                if !audioStreaming.isPlaying {
                    self.play()
//                    audioStreaming.setIsPlaying(true, callback: nil)
                }
            }
            self.readyToPlay = true
        } else {
            print("DID BECOME NIL SHIT")
//            audioStreaming.stop(nil)
        }
    }
}

extension StreamPlayerManager : SPTAudioStreamingDelegate {
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        
    }
    func audioStreamingDidLogout(audioStreaming: SPTAudioStreamingController!) {
        
    }
    func audioStreamingDidReconnect(audioStreaming: SPTAudioStreamingController!) {
        
    }
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
        
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        
    }
    func audioStreamingDidEncounterTemporaryConnectionError(audioStreaming: SPTAudioStreamingController!) {
        
    }
}