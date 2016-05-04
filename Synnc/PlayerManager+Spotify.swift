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


func renderCallback(inRefCon:UnsafeMutablePointer<Void>,
                    ioActionFlags:UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                    inTimeStamp:UnsafePointer<AudioTimeStamp>,
                    inBusNumber:UInt32,
                    inNumberFrames:UInt32,
                    ioData:UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
    let delegate = unsafeBitCast(inRefCon, AURenderCallbackDelegate.self)
    let result = delegate.performRender(ioActionFlags,
                                        inTimeStamp: inTimeStamp,
                                        inBusNumber: inBusNumber,
                                        inNumberFrames: inNumberFrames,
                                        ioData: ioData)
    return result
}

@objc protocol AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                       inTimeStamp: UnsafePointer<AudioTimeStamp>,
                       inBusNumber: UInt32,
                       inNumberFrames: UInt32,
                       ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
}

class SynncCoreAudioController : SPTCoreAudioController, AURenderCallbackDelegate {
    var myNode : AUNode = AUNode()
    var myUnit : AudioUnit = nil
    var graph : AUGraph?
    var ioUnit : AudioUnit = nil
    
    override init() {
        super.init()
    }
//    var currentFrame : 
    
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>, inTimeStamp: UnsafePointer<AudioTimeStamp>, inBusNumber: UInt32, inNumberFrames: UInt32, ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        
//        AudioUnitRenderActionFlags.UnitRenderAction_PreRender
    
    
        
        var a = inTimeStamp.memory
//        a.mHostTime += 1000
        
//        var list = ioData.memory
//        print(list)
//        list.mBuffers[0]
        
//        var count : UInt32 = UInt32()
//        AUGraphGetNodeCount(graph!, &count)
//        
//        var node : AUNode = AUNode()
//        
//        AUGraphGetIndNode(graph!, 0, &node)
        
        if ioActionFlags.memory == .UnitRenderAction_PostRender {
            
            var timebaseInfo : mach_timebase_info = mach_timebase_info()
            if timebaseInfo.denom == 0 {
                mach_timebase_info(&timebaseInfo)
            }
            var time2nsFactor = UInt64(timebaseInfo.numer / timebaseInfo.denom)
            let x : CGFloat = pow(10, 9)
            var ts = a.mSampleTime * Float64(time2nsFactor/UInt64(x))
//            ioData.memory.mBuffers
            
            var a :  AudioTimeStamp = AudioTimeStamp()
            
            
            var propSize: Int = sizeof(Int64)
            var propSize32 = UInt32(1024)
            
            let eqFrequencies: [UInt32] = [ 32, 250, 500, 1000, 2000, 16000 ]
            let b = AudioUnitGetProperty(myUnit, kAudioUnitProperty_CurrentPlayTime, AudioUnitScope(kAudioUnitScope_Global), 0, &a, &propSize32)

            print(b, a)
            
//            let audioBuffers = UnsafeBufferPointer<AudioBuffer>(start: &ioData.memory.mBuffers, count: Int(ioData.memory.mNumberBuffers))
//            print("pre render", a.mHostTime, mach_absolute_time(), CMClockGetHostTimeClock(), a.mSampleTime, a.mSampleTime/44100.0, ts)
//            AVAudioTime(
            
//            kAudioUnitProperty_CurrentPlayTime
            
//            Augra
//            for audioBuffer in audioBuffers {
//                
////                print(audioBuffer)
//                var samples = UnsafeMutableBufferPointer<Float>(start: UnsafeMutablePointer<Float>(audioBuffer.mData), count: Int(audioBuffer.mDataByteSize) / sizeof(Float))
//
//                schedul
                
//                AudioFileId
                
//                AUGraph
                
//                UnsafeMutableBu
//                print("pre render", a.mRateScalar, a.mSampleTime/44100.0, samples)
//                print("!*!*!*!*!*!*!*!*!*!*!*!*!**!", audioBuffer)
                
//                for sample in samples {
//                    // do something with the float sample
//                    print(sample)
//                }
//            }
            
//            let abl = UnsafeMutableAudioBufferListPointer(ioData)
//            
//            for buffer in abl {
//                
//                            print(buffer.mData.memory)
//                //            memset(buffer.mData, 0, 1024)
//                
////                memset
//                
//                            memset(buffer.mData, 0, Int(buffer.mDataByteSize))
//            }
        }
        
//        self.outpu
        
        
        
        return noErr
    }
    
    func findCurrentFrame(){
        
//        var a :  AudioTimeStamp = AudioTimeStamp()
//        
//        
//        var propSize: Int = sizeof(Int64)
//        var propSize32 = UInt32(1024)
//        
//        let eqFrequencies: [UInt32] = [ 32, 250, 500, 1000, 2000, 16000 ]
//        let b = AudioUnitGetProperty(myUnit, kaudiounitpropertytime, AudioUnitScope(kAudioUnitScope_Global), 0, &a, &propSize32)
        
//        AudioUnitSetProperty(myUnit, kAudioUnitProperty_CurrentPlayTime, AudioUnitScope(kAudioUnitScope_Global), 0, a, propSize32)
        
//        print(a, b)
//        AudioUnitSetParameter(<#T##inUnit: AudioUnit##AudioUnit#>, kAudioUnitProperty_CurrentPlayTime, 0, <#T##inElement: AudioUnitElement##AudioUnitElement#>, <#T##inValue: AudioUnitParameterValue##AudioUnitParameterValue#>, inBufferOffsetInFrames: UInt32)
        
//        var propSize: Int = sizeof(Int64)
//        var propSize32 = UInt32(propSize)
//        if let g = graph {
//            AUGraphUpdate(<#T##inGraph: AUGraph##AUGraph#>, <#T##outIsUpdated: UnsafeMutablePointer<DarwinBoolean>##UnsafeMutablePointer<DarwinBoolean>#>)
//            
//            var desc : AudioComponentDescription
//            AUGraphNodeInfo(graph, myNode, <#T##outDescription: UnsafeMutablePointer<AudioComponentDescription>##UnsafeMutablePointer<AudioComponentDescription>#>, <#T##outAudioUnit: UnsafeMutablePointer<AudioUnit>##UnsafeMutablePointer<AudioUnit>#>)
//            AUGrap
//        }
    }
    
    override func connectOutputBus(sourceOutputBusNumber: UInt32, ofNode sourceNode: AUNode, toInputBus destinationInputBusNumber: UInt32, ofNode destinationNode: AUNode, inGraph graph: AUGraph) throws {
        print("connect output bus", sourceNode, destinationNode, graph)
    
        self.graph = graph
//        AudioUnitGetProperty(audio.filePlayerAU, AudioUnitPropertyID(kAudioUnitProperty_CurrentPlayTime), AudioUnitScope(kAudioUnitScope_Global), 0, &audio.currentFrame, &propSize32)
        
        
        
//        AudioUnitGetProperty(<#T##inUnit: AudioUnit##AudioUnit#>, <#T##inID: AudioUnitPropertyID##AudioUnitPropertyID#>, <#T##inScope: AudioUnitScope##AudioUnitScope#>, <#T##inElement: AudioUnitElement##AudioUnitElement#>, <#T##outData: UnsafeMutablePointer<Void>##UnsafeMutablePointer<Void>#>, <#T##ioDataSize: UnsafeMutablePointer<UInt32>##UnsafeMutablePointer<UInt32>#>)
//        var type = AudioComponentDescription(componentType: kAudioUnitType_Effect, componentSubType: kAudioUnitSubType_Reverb2, componentManufacturer: kAudioUnitManufacturer_Apple, componentFlags: 0, componentFlagsMask: 0)
//        
//        AUGraphAddNode(graph, &type, &myNode)
        
//        AUGraphNodeInfo(<#T##inGraph: AUGraph##AUGraph#>, <#T##inNode: AUNode##AUNode#>, <#T##outDescription: UnsafeMutablePointer<AudioComponentDescription>##UnsafeMutablePointer<AudioComponentDescription>#>, <#T##outAudioUnit: UnsafeMutablePointer<AudioUnit>##UnsafeMutablePointer<AudioUnit>#>)
//        AUGraphNodeInfo(graph, destinationNode, nil, &myUnit)
        
//        AudioUnitAddRenderNotify(myUnit, renderCallback, UnsafeMutablePointer(unsafeAddressOf(self)))
        
//        AudioUnitSetParameter(<#T##inUnit: AudioUnit##AudioUnit#>, kAudioUnitProperty_CurrentPlayTime, 0, <#T##inElement: AudioUnitElement##AudioUnitElement#>, <#T##inValue: AudioUnitParameterValue##AudioUnitParameterValue#>, <#T##inBufferOffsetInFrames: UInt32##UInt32#>)
        
//        Audiofile
//        ScheduledAudioFileRegion(mTimeStamp: timeStamp, mCompletionProc: nil,
//                                 mCompletionProcUserData: nil, mAudioFile: fileID,
//                                 mLoopCount: 0, mStartFrame: currentFrame,
//                                 mFramesToPlay: UInt32.max)
//        
//        AudioUnitInitialize(myUnit)
//        AudioUnitSetParameter(myUnit, kAudioUnitScope_Global, 0, kReverb2Param_DryWetMix, 100, 0)
//        
//        AUGraphConnectNodeInput(graph, sourceNode, sourceOutputBusNumber, myNode, 0)
//        AUGraphConnectNodeInput(graph, myNode, 0, destinationNode, destinationInputBusNumber)
//        
//        
//        AudioUnit

//        AUGraphNodeInfo(graph, myNode, <#T##outDescription: UnsafeMutablePointer<AudioComponentDescription>##UnsafeMutablePointer<AudioComponentDescription>#>, <#T##outAudioUnit: UnsafeMutablePointer<AudioUnit>##UnsafeMutablePointer<AudioUnit>#>)
//        CMAudioClockCreate(<#T##allocator: CFAllocator?##CFAllocator?#>, <#T##clockOut: UnsafeMutablePointer<CMClock?>##UnsafeMutablePointer<CMClock?>#>)
        //        sourceNode
        
        
        
                try super.connectOutputBus(sourceOutputBusNumber, ofNode: sourceNode, toInputBus: destinationInputBusNumber, ofNode: destinationNode, inGraph: graph)
    }
//    override func attemptToDeliverAudioFrames(audioFrames: UnsafePointer<Void>, ofCount frameCount: Int, streamDescription audioDescription: AudioStreamBasicDescription) -> Int {
//        let a = super.attemptToDeliverAudioFrames(audioFrames, ofCount: frameCount, streamDescription: audioDescription)
////                print("attemptToDeliverAudioFrames", audioDescription, audioFrames, frameCount)
//        return a
//    }
    
}

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
    var audioController : SynncCoreAudioController!
    
    override init!(clientId: String!, audioController: SPTCoreAudioController!) {
        super.init(clientId: clientId, audioController: audioController)
    }
    override init!(clientId: String!) {
        let audioController = SynncCoreAudioController()
        
        super.init(clientId: clientId, audioController: audioController)
        
        self.audioController = audioController
//        self.audioController.delegate = self
        
        self.shuffle = false
        self.setValue(false, forKey: "repeat")
        self.addObserver(self, forKeyPath: "currentPlaybackPosition", options: [], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let item = object as? SynncSpotifyPlayer {
            self.audioController.findCurrentFrame()
            
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
        print(audioStreaming.queueSize)
        
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
        if info.index == self.playlist.count - 1 {
            endOfPlaylist = true
            return
        } else {
            switchPlayers(info)
            self.loadNextSongForPlayer(info)
        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        print("DID START PLAYING TRACK", trackUri)
        if audioStreaming === self.activePlayer {
            if self.rate == 0 {
                print("sEctor")
            } else {
                print("nooope")
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
                    audioStreaming.setIsPlaying(true, callback: nil)
                }
            }
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