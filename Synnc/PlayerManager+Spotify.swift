//
//  PlayerManager+Spotify.swift
//  Synnc
//
//  Created by Arda Erzin on 4/18/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

class SpotifyPlayerList : NSObject, SPTTrackProvider {
    
    var uris :[NSURL] = []
//    var currentIndex : Int = 0
    
    init(uriStrings : [String]) {
        super.init()
        
        for str in uriStrings {
            if let uri = NSURL(string: str) {
                self.uris.append(uri)
            }
        }
    }
    func tracksForPlayback() -> [AnyObject]! {
        print("tracks for playback",  uris)
        return nil
    }
    func playableUri() -> NSURL! {
//        print("playable uri", uris[currentIndex])
        return nil
    }
}

class SynncSpotifyPlayer : SPTAudioStreamingController {
    
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
            StreamPlayerManager.sharedInstance.playerTimeUpdated(CMTimeMakeWithSeconds(self.currentPlaybackPosition, 1000))
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
        print("DID CHANGE VOLUME")
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
        print("DID STOP PLAYING TRACK", trackUri)
//        self.
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        print("DID START PLAYING TRACK", trackUri)
        if audioStreaming === self.activePlayer {
            if self.rate == 0 {
                print("sEctor")
            } else {
                print("nooope")
            }
        }
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didSeekToOffset offset: NSTimeInterval) {
        print("DID SEEK TO OFFSET")
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("DID CHANGE PLAYBACK STATUS", isPlaying)
    }
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangeToTrack trackMetadata: [NSObject : AnyObject]!) {
        if let data = trackMetadata {
            print("DID CHANGE TO TRACK", trackMetadata[SPTAudioStreamingMetadataTrackName])
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