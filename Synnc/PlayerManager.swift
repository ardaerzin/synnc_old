//
//  PlayerManager.swift
//  Synnc
//
//  Created by Arda Erzin on 4/14/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AVFoundation
import WCLUtilities
import SwiftyJSON
import SocketIOClientSwift
import MediaPlayer
import CoreMedia
import WCLNotificationManager
import AsyncDisplayKit
import WCLUserManager

enum PlayerManagerPlayer : String {
    case URLPlayerOdd = "Player1"
    case URLPlayerEven = "Player2"
    case SpotifyPlayer = "Player3"
}

class StreamPlayerManager : NSObject {
    
    class var sharedInstance : StreamPlayerManager {
        
        struct Static {
            static let instance : StreamPlayerManager = StreamPlayerManager()
        }
        
        return Static.instance
    }
    var isSyncing : Bool = false {
        didSet {
            if isSyncing != oldValue {
                self.delegate?.playerManager?(self, isSyncing: isSyncing)
            }
        }
    }
    var readyToPlay : Bool = false {
        willSet {
            self.delegate?.playerManager?(self, readyToPlay: readyToPlay)
        }
    }
    var endOfPlaylist : Bool = false {
        willSet {
            if newValue && newValue != endOfPlaylist {
                
                if newValue {
                    
                    if let s = self.stream {
                        StreamManager.sharedInstance.finishedStream(s, completion: nil)
                    }
                }
            }
        }
    }
    var currentIndex : Int {
        get {
            if let x = self.currentItem {
                print("current item", self.currentItem, self.songInfo(x))
            }
            guard let item = self.currentItem, let info = self.songInfo(item) else {
                return -1
            }
            return info.index
        }
    }
    var needsPlay = false
    
    
    /// Players
    let observedItemKeys : [String] = ["status", "loadedTimeRanges", "playbackBufferFull", "playbackBufferEmpty", "playbackLikelyToKeepUp", "timedMetadata"]
    var activePlayer : AnyObject! {
        didSet {
            if activePlayer !== oldValue {
//                if let old = oldValue {
//                    old.rate = 0
//                }
                if let player = activePlayer {
                    var playerType : PlayerManagerPlayer!
                    for (type,p) in self.players {
                        if p === player {
                            playerType = type
                            break
                        }
                    }
                    print("PlayerManager:", "DidSetActivePlayer", playerType)
                }
                updateControlCenterItem()
            }
        }
    }
    var players : [PlayerManagerPlayer : AnyObject] = [PlayerManagerPlayer : AnyObject]()
    var playerObservers : [AnyObject] = []
    var syncManager : WildPlayerSyncManager!
    var delegate : PlayerManagerDelegate!
    
    
    var playlist : [SynncTrack] = []
    var playerIndexedPlaylist : [SynncTrack : TrackPlayerInfo] = [SynncTrack : TrackPlayerInfo]()
        var stream : Stream? {
        willSet {
            if newValue != nil {
//                self.endOfPlaylist = false
                self.syncManager.needsUpdate = true
            }
        }
    }
    
    var nowPlayingInfo : [String : AnyObject] = [String : AnyObject]()
    var isActiveSession : Bool = false
    var fadeDuration = 1.0
    var fadeoutObserver : AnyObject!

    override init() {
        super.init()
        
        self.syncManager = WildPlayerSyncManager()
        
        if let user = Synnc.sharedInstance.user.userExtension(.Spotify) {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.loginStatusChanged(_:)), name: "\(WCLUserLoginType.Spotify.rawValue)ProfileInfoChanged", object: user)
        }
        
        Async.background {
            let player1 = AVPlayer()
            
            player1.addObserver(self, forKeyPath: "status", options: [], context: nil)
            player1.addObserver(self, forKeyPath: "currentItem", options: [], context: nil)
            player1.addObserver(self, forKeyPath: "rate", options: [], context: nil)
            player1.addObserver(self, forKeyPath: "volume", options: [], context: nil)
            let playbackPeriodicObserver = player1.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1.0/5.0 , 100), queue: nil, usingBlock: {
                
                [unowned self]
                time in
                
                if self.currentItem == nil {
                    return
                }
                
                self.playerTimeUpdated(time)
            })
            self.players[.URLPlayerOdd] = player1
            self.playerObservers.append(playbackPeriodicObserver)
            
            let player2 = AVPlayer()
            player2.addObserver(self, forKeyPath: "status", options: [], context: nil)
            player2.addObserver(self, forKeyPath: "currentItem", options: [], context: nil)
            player2.addObserver(self, forKeyPath: "rate", options: [], context: nil)
            player2.addObserver(self, forKeyPath: "volume", options: [], context: nil)
            let playbackPeriodicObserver2 = player2.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(1.0/5.0 , 100), queue: nil, usingBlock: {
                
                [unowned self]
                time in
                
                if self.currentItem == nil {
                    return
                }
                self.playerTimeUpdated(time)
            })
            self.players[.URLPlayerEven] = player2
            self.playerObservers.append(playbackPeriodicObserver2)
            
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.userFavPlaylistUpdated(_:)), name: "UpdatedFavPlaylist", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.audioRouteChanged(_:)), name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    func loginStatusChanged(notification: NSNotification) {
        if let user = notification.object as? WildSpotifyUser {
            if let session = SPTAuth.defaultInstance().session, let status = user.loginStatus, let info = user.profileInfo as? SPTUser where status && info.product == .Premium {
                Async.main {
                    let a = SynncSpotifyPlayer(clientId: SPTAuth.defaultInstance().clientID)
                    self.players[.SpotifyPlayer] = a
                    a.delegate = self
                    a.playbackDelegate = self
                    
                    print("Create player")
                    a.loginWithSession(session) {
                        error in
                        if let e = error {
                            print("ERROR WITH PLAYER", PlayerManagerPlayer.SpotifyPlayer)
                            return
                        }
                        print("CREATED PLAYER")
                    }
                    
                    
                }
                
                print("user Spotify login status is TRUE", user.profileInfo)
            } else {
                print("user Spotify login status is FALSE")
            }
        }
    }
    
    // MARK: Key Value Observer
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer, let path = keyPath {
            
            switch path {
                
            case "status" :
                playerStatusChanged(player)
            case "currentItem" :
                currentItemChanged(player)
            case "rate" :
                playerRateChanged(player)
            case "volume" :
                playerVolumeChanged(player)
            default:
                return
                
            }
        } else if let item = object as? AVPlayerItem {
            if keyPath == "timedMetadata" {
                self.playerItem(metadataUpdatedForItem: item)
            } else if keyPath == "status" {
                self.playerItem(itemStatusChangedForItem: item)
            } else if keyPath == "loadedTimeRanges" {
                self.playerItem(loadedItemTimeRangesForItem: item)
            } else if keyPath == "playbackBufferFull" {
                self.playerItem(playbackBufferFullForItem: item)
            } else if keyPath == "playbackBufferEmpty" {
                self.playerItem(playbackBufferEmptyForItem: item)
            } else if keyPath == "playbackLikelyToKeepUp" {
                self.playerItem(playbackLikelyToKeepUpForItem: item)
            }
        }
    }
    
    func playerTimeUpdated(time: CMTime){
        self.delegate?.playerManager?(self, updatedToPosition: CGFloat(CMTimeGetSeconds(time)) / CGFloat(self.currentItemDuration))
        
        var infoDict : [String : AnyObject]?
        if let st = stream where st.isUserStream {
            infoDict = [String : AnyObject]()
            infoDict?["id"] = st.o_id
            infoDict?["currentIndex"] = self.currentIndex
            infoDict?["stream"] = st
        }
        self.syncManager.playerTimeUpdated(time, infoDict: infoDict)
    }
    
    func resetPlayer(){
        self.rate = 0
        
        for (_,player) in players {
            if let avplayer = player as? AVPlayer {
                avplayer.replaceCurrentItemWithPlayerItem(nil)
            }
        }
        for (track, info) in self.playerIndexedPlaylist {
            if let item = info.item {
                for key in observedItemKeys {
                    item.removeObserver(self, forKeyPath: key)
                }
            }
        }
        self.activePlayer = nil
        playerIndexedPlaylist = [SynncTrack : TrackPlayerInfo]()
        self.stream = nil
        endOfPlaylist = false
    }
    
    func reload(){
        
    }
    
    func didSetActiveStream(stream: Stream?, userStream : Bool) {
        
        print("PlayerManager:","Did set active stream")
        
        resetPlayer()
        
            if let st = stream {
                
                
                self.stream = st
                self.playlist = st.playlist.songs
                
                Async.background {
                
                    self.playerIndexedPlaylist = self.assignTracksToPlayers(st.playlist.songs)
                
                    for (_,info) in self.playerIndexedPlaylist {
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.playerDidPlayToEnd(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: info.item)
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamPlayerManager.itemPlaybackStalled(_:)), name: AVPlayerItemPlaybackStalledNotification, object: info.item)
                        
                        for key in self.observedItemKeys {
                            if let i = info.item {
                                i.addObserver(self, forKeyPath: key, options: [], context: nil)
                            }
                        }
                    }
                    
                    if userStream {
                        
                        let a = (st.currentSongIndex as Int)...((st.currentSongIndex as Int)+1)
                        
                        for i in a {
                            self.loadSong(i)
                            if i < self.playlist.count && i == st.currentSongIndex as Int {
                                let track = self.playlist[i]
                                if let info = self.playerIndexedPlaylist[track], let player = self.players[info.player] {
                                    
                                    self.activePlayer = player
                                }
                            }
                        }
                        self.play()
                    } else {
                        self.syncManager.timestamp = st.timestamp
                    }
                }
            }
        
        
    }
}

extension StreamPlayerManager {
    func currentItemChanged(player: AVPlayer){
        
        var playerType : PlayerManagerPlayer!
        for (type,p) in self.players {
            if p === player {
                playerType = type
                break
            }
        }
        
        print("PlayerManager:","CurrentItemChanged for player:", playerType, player.currentItem)
        
        if self.currentItem == nil {
            return
        }
    
    }
    func playerVolumeChanged(player: AVPlayer) {
        if player !== self.activePlayer {
            return
        }
        self.delegate?.playerManager?(self, volumeChanged: self.volume)
    }
    func itemPlaybackStalled(notification : NSNotification) {
        if let item = notification.object as? AVPlayerItem {
            self.playerItem(playbackStalledForItem: item)
        }
    }
    func playerDidPlayToEnd(notification : NSNotification) {
        print("PlayerManager:", "DID PLAY A TRACK TO END")
        
        if let item = notification.object as? AVPlayerItem {
            
            guard let info = self.songInfo(item) else {
                return
            }
            if info.index == self.playlist.count - 1 {
                endOfPlaylist = true
                return
            }
            Async.background {
                self.switchPlayers(info)
                self.loadNextSongForPlayer(info)
            }
            self.syncManager.needsUpdate = true
        }
    }
    
    internal func songInfo(item: AnyObject) -> TrackPlayerInfo? {
        var i : TrackPlayerInfo!
        for (index, playlistItem) in self.playlist.enumerate() {
            if let info = self.playerIndexedPlaylist[playlistItem] {
//                print(info, item)
                if let currentUrl = item as? NSURL, let y = info.item as? NSURL where currentUrl.absoluteString == y.absoluteString {
                    i = info
                    break
                } else if info.item === item {
                    i = info
                    break
                }
            }
        }
        return i
    }
    
    internal func loadSong(index: Int){
        if index >= playlist.count {
            return
        }
        let nextSong = self.playlist[index]
        if let nextSongInfo = self.playerIndexedPlaylist[nextSong], let player = self.players[nextSongInfo.player] where player !== activePlayer {
            if let avplayer = player as? AVPlayer, let item = nextSongInfo.item as? AVPlayerItem {
                avplayer.replaceCurrentItemWithPlayerItem(item)
            } else if let spotifyPlayer = player as? SPTAudioStreamingController {
//                print("load song")
//                if let spotifyItem = nextSongInfo.item as? SpotifyPlayerItem {
//                    Async.main {
//                        spotifyPlayer.queueTrackProvider(spotifyItem, clearQueue: true) {
//                            error in
//                            if let err = error {
//                                print("error loading spotify song:", err.description)
//                                return
//                            }
//                            print("successfully queued uri")
//                        }
//                    }
//                }
            }
            
        }
    }
    internal func loadNextSongForPlayer(info : TrackPlayerInfo) {
        let ind = info.index + 2
        if ind >= self.playlist.count {
            //no more
            return
        }
        loadSong(ind)
    }
    
    internal func switchPlayers(info : TrackPlayerInfo?) {
        let ind = info != nil ? info!.index + 1 : 0
        
        if ind >= self.playlist.count {
            //end of playlist
            return
        }
        
        let nextSong = self.playlist[ind]
        if let nextSongInfo = self.playerIndexedPlaylist[nextSong] {
            if let p = players[nextSongInfo.player] {
                print("PlayerManager:", "Switch to player", nextSongInfo.player)
                
                let a = self.activePlayer
                a.replaceCurrentItemWithPlayerItem(nil)
                
                self.activePlayer = p
                
                self.play()
            }
        }
    }
    
    func playerRateChanged(player: AVPlayer) {
        
        
        if player.rate == 1 {
            self.activePlayer = player
        }
        
        if player !== self.activePlayer {
            return
        }
        updateControlCenterRate()
        self.delegate?.playerManager?(self, updatedRate: player.rate)
    }
    func playerStatusChanged(player: AVPlayer){
        
        var playerType : PlayerManagerPlayer!
        for (type,p) in self.players {
            if p === player {
                playerType = type
                break
            }
        }
        
        print("PlayerManager:","Player status changed", playerType, player.status.rawValue)
        switch player.status {
        case .Failed:
            print("failed")
            break
        case .ReadyToPlay:
            self.readyToPlay = true
            if let s = self.stream where !s.isUserStream {
                self.syncManager.checkTimeSync()
            }
            break
        default:
            print("other")
            break
        }
    }
}