//
//  StreamManager.swift
//  RadioHunt
//
//  Created by Arda Erzin on 9/8/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import WCLUtilities
import SwiftyJSON
import WCLNotificationManager
import Dollar
import Async
import WCLUIKit

class StreamManager : NSObject, StreamDelegate {
    
    var userFeed : [Stream] = [] {
        didSet {
            Async.main {
                NSNotificationCenter.defaultCenter().postNotificationName("UpdatedUserFeed", object: self.userStream, userInfo: nil)
            }
        }
    }
    var streams : [Stream] = [] {
        didSet {
            
        }
        willSet {
            
        }
    }
    var userStream : Stream? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("DidSetUserStream", object: userStream, userInfo: nil)
        }
    }
    var activeStream : Stream? {
        didSet {
            if oldValue == activeStream {
                return
            }
            let needsLoad = activeStream == self.userStream
            print("active stream", activeStream)
            NSNotificationCenter.defaultCenter().postNotificationName("DidSetActiveStream", object: activeStream, userInfo: ["loadTracks" : needsLoad])
            self.playerManager.didSetActiveStream(activeStream, userStream: needsLoad)
            
        }
    }
    
    var playerManager: StreamPlayerManager!
    
    class var sharedInstance : StreamManager {
        struct Singleton {
            static let instance = StreamManager()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
        
        playerManager = StreamPlayerManager.sharedInstance
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamManager.loginStatusChanged(_:)), name: "userLoginStatusChanged", object: nil)
    }
    
    func loginStatusChanged(notification: NSNotification){
        if let user = notification.object as? MainUser where user == Synnc.sharedInstance.user {
            if let stream = self.activeStream where !user.status {
                self.stopStream(stream, completion: nil)
            }
        }
    }
}

extension StreamManager {
    
    class func isActiveStream(stream: Stream) -> Bool {
        return stream == sharedInstance.activeStream
    }
    class func canSetActiveStream(stream: Stream) -> Bool {
        if let oldStream = sharedInstance.activeStream {
            if oldStream != stream {
                return false
            }
        }
        return true
    }
    class func setActiveStream(stream: Stream) {
        sharedInstance.activeStream = stream
    }
    class func playStream(stream: Stream) {
        
        if isActiveStream(stream) {
            
            Synnc.sharedInstance.socket.emitWithAck("Stream:start", stream.o_id)(timeoutAfter: 0) {
                data in
                
                if let d = data.first {
                    let json = JSON(d)
                    stream.fromJSON(json)
                }
//                stream.update(["status" : true])
//                sharedInstance.playerManager.play()
            }
        }
    }
}

extension StreamManager {
    func findStream(id : String?) -> Stream? {
        if id == nil {
            return nil
        }
        var filteredStreams = streams.filter({($0.o_id) == id!})
        if filteredStreams.count == 0 {
            return nil
        } else {
            return filteredStreams[0]
        }
    }
}

extension StreamManager {
    
    func createStreamWindow(playlist: SynncSharedPlaylist) -> WCLWindow {
        let stream = Stream(user: Synnc.sharedInstance.user)
        stream.playlist = playlist
        stream.lat = 0
        stream.lon = 0
        Synnc.sharedInstance.streamManager.userStream = stream
        let vc = StreamVC(stream: stream)
        
        let opts = WCLWindowOptions(link: false, draggable: true, limit: UIScreen.mainScreen().bounds.height, dismissable: true)
        let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
        a.delegate = vc
        a.panRecognizer.delegate = vc
        a.clipsToBounds = false
        stream.createCallback = {
            created in
            if StreamManager.canSetActiveStream(stream) {
                if stream == StreamManager.sharedInstance.userStream {
                    StreamManager.setActiveStream(stream)
                    StreamManager.playStream(stream)
                }
            }
        }
        stream.update([NSObject : AnyObject]())
        return a
    }
    
    func stopStream(stream: Stream, completion : ((status: Bool) -> Void)?) {
        if stream != self.activeStream {
            return
        }
        self.activeStream = nil
        
        if stream == self.userStream {
            Synnc.sharedInstance.socket.emitWithAck("Stream:stop", stream.o_id)(timeoutAfter: 0) {
                [weak self]
                data in
                
                if self == nil {
                    return
                }
                
                completion?(status: true)
                
                if let d = data.first {
                    let json = JSON(d)
                    stream.fromJSON(json)
                }
                
                AnalyticsEvent.new(category: "StreamAction", action: "stop", label: nil, value: nil)
            }
        } else {
            self.leaveStream(stream, completion: completion)
        }
    }
    
    func finishedStream(stream: Stream, completion : ((status: Bool) -> Void)?) {
        
        if self.activeStream == nil {
            
            SynncNotification(body: ("Your active stream ended", "ended"), image: "notification-warning", showLocalNotification: true).addToQueue()
            
        } else {
            
            self.activeStream = nil
            var notificationMsg : (String, String)?
            
            if stream == StreamManager.sharedInstance.userStream {
                notificationMsg = ("You have reached the end of your stream", "reached the end")
            } else {
                notificationMsg = ("The stream you'd been listening to has just ended", "just ended")
            }
            
            if let msg = notificationMsg {
                Async.main {
                    SynncNotification(body: msg, showLocalNotification: true, image: "notification-warning").addToQueue()
                }
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("EndedActiveStream", object: stream, userInfo: nil)
        
        completion?(status: true)
        
        if stream == self.userStream {
            
            self.userStream = nil
            Synnc.sharedInstance.socket.emitWithAck("Stream:stop", stream.o_id)(timeoutAfter: 0) {
                [weak self]
                data in
                
                if self == nil {
                    return
                }
                
                if let d = data.first {
                    let json = JSON(d)
                    stream.fromJSON(json)
                }
            }
            
        } else {
            self.leaveStream(stream, completion: nil)
        }
    }
    
    func leaveStream(stream: Stream, completion : ((status: Bool) -> Void)?) {
        Synnc.sharedInstance.socket.emitWithAck("Stream:leave", stream.o_id)(timeoutAfter: 0) {
            
            [weak self]
            data in
            
            if self == nil {
                return
            }
            
            if let ind = stream.users.indexOf(Synnc.sharedInstance.user) {
                stream.users.removeAtIndex(ind)
                self?.updatedStreamFromServer(stream, changedKeys: ["users"])
            }
            AnalyticsEvent.new(category: "StreamAction", action: "leave", label: nil, value: nil)
        }
    }
    
    func joinStream(stream: Stream, completion : ((status: Bool) -> Void)? ) {
        Synnc.sharedInstance.socket.emitWithAck("Stream:join", stream.o_id)(timeoutAfter: 0) {
            
            [weak self]
            data in
            
            if self == nil {
                return
            }
            
            if !data.isEmpty {
                
                completion?(status: true)
                
                self?.activeStream = stream
//                self?.playerManager.isSyncing = true
                if let _ = stream.timestamp {
//                    self?.playerManager.syncManager.timestamp = stream.timestamp
//                    self?.playerManager.checkActiveSession()
                }
            } else {
                completion?(status: false)
            }
            
            AnalyticsEvent.new(category: "StreamAction", action: "join", label: nil, value: nil)
        }
    }
    
    func updatedStreamLocally(stream: Stream, changedKeys keys: [String]?) {
        if stream.o_id == nil {
            stream.toJSON() {
                result in
                Synnc.sharedInstance.socket.emitWithAck("Stream:create", result) (timeoutAfter: 0) {
                    ack in
                    if let data = ack.first {
                        let json = JSON(data)
                        self.userStream?.fromJSON(json) {
                            stream in
                            stream.createCallback?(status: true)
                            if $.find(self.streams, callback: {$0 == stream}) == nil {
                                self.streams.append(stream)
                            }
                        }
                    } else {
                        self.userStream?.createCallback?(status: false)
                    }
                    AnalyticsEvent.new(category: "StreamAction", action: "create", label: nil, value: nil)
                }
            }
            
        } else {
            stream.toJSON(keys) {
                result in
                Synnc.sharedInstance.socket.emit("Stream:update", result)
            }
        }
        
        if let k = keys {
            let notification = NSNotification(name: "UpdatedStreamLocally", object: stream, userInfo: ["updatedKeys" : k])
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    func updatedStreamFromServer(stream: Stream, changedKeys keys: [String]?) {
        
        let changedKeys = keys == nil ? [] : keys!
        let notification = NSNotification(name: "UpdatedStream", object: stream, userInfo: ["updatedKeys" : changedKeys])
        
        if let _ = keys?.indexOf("timestamp") where stream == self.activeStream {
            self.playerManager.syncManager.timestamp = stream.timestamp
        }
        
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}

// MARK: - Song Favorite
extension StreamManager {
    func toggleTrackFavStatus(track: SynncTrack, callback : ((status:Bool) -> Void )?){
        
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist.hasTrack(track) {
            //remove
            self.removeSongFromFavorites(track) {
                status in
                
                if status {
                    callback?(status: false)
                    
//                    NSNotificationCenter.defaultCenter().postNotificationName("UpdatedFavPlaylist", object: nil, userInfo: nil)
                    
                }
            }
        } else {
            //add
            self.addSongToFavorites(track) {
                status in
                
                if status {
                    callback?(status: true)
                    
//                    NSNotificationCenter.defaultCenter().postNotificationName("UpdatedFavPlaylist", object: nil, userInfo: nil)
                    
//                    self.player.updateControlCenterItem()
                }
            }
        }
        
    }
    
    func addSongToFavorites(song: SynncTrack, handler: ((status: Bool)->Void)?){
        SharedPlaylistDataSource.getUserFavoritesPlaylist() {
            playlist in
            
            if let plist = playlist {
                plist.addSongs([song])
                plist.save()
                
                handler?(status: true)
            } else {
                handler?(status: false)
            }
        }
    }
    func removeSongFromFavorites(song: SynncTrack, handler: ((status: Bool)->Void)?) {
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist(), let favInd = plist.indexOf(song) {
            plist.removeSong(atIndexPath: NSIndexPath(forItem: favInd, inSection: 0))
            plist.save()
            
            handler?(status: true)
        }
    }

}

// MARK: - USER FEED RELATED

extension StreamManager {
    func updateUserFeed(){
        Synnc.sharedInstance.socket.emitWithAck("Stream", [])(timeoutAfter: 0) {
            ack in
            Async.background {
                if let jsonArr = JSON(ack.first!).array where !jsonArr.isEmpty {
                    self.findOrCreateFromData(jsonArr, completionBlock: {
                        streams in
                        let newItems = $.difference(streams, self.userFeed)
                        for item in newItems {
                            if let id = item.user._id {
                                Synnc.sharedInstance.user.joinUserRoom(id, callback: nil)
                            }
                        }
                        self.userFeed = $.union(self.userFeed, streams)
                    })
                }
            }
        }
    }
    
    internal func findOrCreateFromData(serverData : [JSON], completionBlock : ((streams: [Stream]) -> Void)?) {
        let batch : StreamSaveBatch = (serverData, completionBlock)
        BatchStreamSaver.sharedInstance.batches.append(batch)
    }
}

// MARK: - STREAM SEARCH

extension StreamManager {
    typealias StreamSearchCallback = (searchString: String, genres: [Genre], timeStamp: NSTimeInterval, objects: [Stream]) -> Void
    
    func findRemoteStreams(string: String? = "", genres: [Genre]? = [], callback: StreamSearchCallback?){
        let timeStamp = NSDate().timeIntervalSince1970
        
        var dict : [String : AnyObject] = [String : AnyObject]()
        if string! == "" {
            let x : [String] = genres!.map({
                genre in
                return genre.id
            })
            dict = ["genres" : ["$all" : x] ]
        } else if genres!.isEmpty {
            dict = [ "name" : ["$regex" : ".*(?i)\(string!).*"] ]
        } else {
            let x : [String] = genres!.map({
                genre in
                return genre.id
            })
            dict = [ "$and" :
                [
                    [ "name" : ["$regex" : ".*(?i)\(string!).*"]],
                    ["genres" : ["$all" : x]
                    ]
                ] ]
        }
        
        
        Synnc.sharedInstance.socket.emitWithAck("stream:search", dict)(timeoutAfter: 0, callback: {
            ack in
            Async.background {
                if let jsonArr = JSON(ack.first!).array {
                    
                    self.findOrCreateFromData(jsonArr, completionBlock: {
                        streams in
                        callback?(searchString: string!, genres: genres!, timeStamp: timeStamp, objects: streams)
                    })
                }
            }
        })
    }
    
    func findStreams(searchString : String? = "", genres: [Genre]? = [], callback: StreamSearchCallback?) -> [Stream] {
        let cachedStreams = self.findLocalStreams(searchString, genres: genres, callback: callback)
        self.findRemoteStreams(searchString, genres: genres, callback: callback)
        return cachedStreams
    }
    
    func findLocalStreams(searchString : String? = "", genres: [Genre]? = [], callback: StreamSearchCallback?) -> [Stream] {
        
        let comparisonOptions : NSStringCompareOptions = [NSStringCompareOptions.CaseInsensitiveSearch, NSStringCompareOptions.NumericSearch, NSStringCompareOptions.WidthInsensitiveSearch, NSStringCompareOptions.ForcedOrderingSearch]
        
        let strPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchString!)
        let genrePredicate = NSPredicate(format: "ALL %@ IN genres", genres!)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [strPredicate, genrePredicate])
        let filtered = self.streams.filter {
            return compoundPredicate.evaluateWithObject($0)
            }.sort({
                
                let name1 = $0.playlist.name == nil ? "Untitled" : $0.playlist.name!
                let name2 = $1.playlist.name == nil ? "Untitled" : $1.playlist.name!
                
                let x : String = name1
                let y : String = name2
                
                let range = x.startIndex..<x.endIndex
                let res = x.compare(y, options: comparisonOptions, range: range, locale: nil)
                return res == NSComparisonResult.OrderedAscending
            })
        
        return filtered
    }
    
}

// MARK: - Socket Callbacks

extension StreamManager {
    
    func setSocket(socket: SocketIOClient) {
//        self.playerManager = StreamPlayer(socket: socket)
        
        socket.on("Streams", callback: refreshStreamsCallback())
        socket.on("Stream:save", callback: streamSaveCallback())
        socket.on("Stream:delete", callback: streamDeleteCallback())
        socket.on("Stream:end", callback: streamEndCallback())
    }
    func streamEndCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            if let data = dataArr.first {
                var json = JSON(data)
                let stream = self.findStream(json["_id"].string)
                
                print("received stream end")
                if stream != nil {
                    stream!.delegate = nil
                    if stream == self.activeStream {
                        self.activeStream = nil
                    }
                    self.streams.removeAtIndex(self.streams.indexOf(stream!)!)
                    
                    let notification = NSNotification(name: "RemovedStream", object: stream, userInfo: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    if let ind = self.userFeed.indexOf(stream!) {
                        self.userFeed.removeAtIndex(ind)
                    }
                }
            }
        }
    }
    func streamDeleteCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            print("ananen")
            if let data = dataArr.first {
                var json = JSON(data)
                let stream = self.findStream(json["_id"].string)
                if stream != nil {
                    stream?.fromJSON(json, callback: {
                        stream in
                        
                        stream.delegate = nil
                        if stream == self.activeStream {
                            self.activeStream = nil
                        }
                        if let ind = self.streams.indexOf(stream) {
                            self.streams.removeAtIndex(ind)
                        }
                        let notification = NSNotification(name: "RemovedStream", object: stream, userInfo: nil)
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                        
                        if let ind = self.userFeed.indexOf(stream) {
                            self.userFeed.removeAtIndex(ind)
                            print("remove item at index")
                        }
                    })
                }
            }
        }
    }
    func streamSaveCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            if let data = dataArr.first {
                
                var json = JSON(data)
                let id = json["_id"].string
                let oldStream = self.findStream(id)
                if oldStream != nil {
                    oldStream!.fromJSON(json) {
                        stream in
                        if stream.status {
                            if self.userFeed.indexOf(stream) == nil && stream != self.userStream {
                                self.userFeed.append(stream)
                            }
                        } else {
                            if let ind = self.userFeed.indexOf(stream) {
                                self.userFeed.removeAtIndex(ind)
                            }
                        }
                    }
                } else {
                    
                    self.findOrCreateFromData([json], completionBlock: {
                        streams in
                        
                        self.userFeed = $.union(self.userFeed, streams)
                        
                    })
                    
                }
            }
        }
    }
    func refreshStreamsCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            if let data = dataArr.first {
                let json = JSON(data)
                if let _ = json.null {
                    return
                }
                
//                for item in json.array! {
//                    let id = item["_id"].string
//                    let oldStream = self.findStream(id)
//                    if oldStream == nil {
//                        let newStream = Stream(json: item, delegate: self)
//                        if $.find(self.streams, callback: {$0 == newStream}) == nil {
//                            self.streams.append(newStream)
//                        }
//                        let notification = NSNotification(name: "NewStream", object: newStream, userInfo: nil)
//                        NSNotificationCenter.defaultCenter().postNotification(notification)
//                    } else {
//                        oldStream!.fromJSON(item)
//                    }
//                }
            }
        }
    }
    
}