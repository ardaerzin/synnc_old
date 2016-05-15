//
//  PlayerManager+SoundSession.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUtilities
import WCLNotificationManager
import MediaPlayer
import Async

extension StreamPlayerManager {
    func checkActiveSession() {
        if !self.isActiveSession {
            setActiveAudioSession()
        }
    }
    func setActiveAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                self.isActiveSession = true
                updateControlCenterControls()
                
//                if let player = self.players[.AppleMusicPlayer] as? MPMusicPlayerController {
//                    player.play()
//                }
            } catch let error as NSError {
                print(error)
                self.isActiveSession = false
            }
        } catch let error as NSError {
            print(error)
            self.isActiveSession = false
        }
    }
    func audioRouteChanged(notification: NSNotification) {
        
        if let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] where (reason as! UInt) == AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue {
            
            if let st = self.stream where st.status {
                AnalyticsEvent.new(category: "StreamPlayer", action: "audioRouteChanged", label: "\(reason)", value: nil)
                if self.rate == 0 {
                    self.play()
                    
                    let oldVolume = self.volume
                    self.volume = 0
                    
                    Async.main {
                        
                        if oldVolume > 0 {
                            
                            WCLNotification(body: ("Your stream is now muted, but continues in the background", "muted"), image: "notification-warning", showLocalNotification: true).addToQueue()
                        }
                        
                    }
                }
            }
        }
    }
}