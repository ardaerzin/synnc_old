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
                            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                                WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Your stream is now Muted, but continues in the background", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                            }
                        }
                        
                    }
                }
            }
        }
    }
}