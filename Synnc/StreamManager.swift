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
import Dollar

@objc protocol StreamManagerDelegate {
    
    /**
    
    Triggered when manager batch updates its streams
    
    */
    optional func updatedStreams(manager: StreamManager)
    optional func streamManager(manager: StreamManager, updatedStream stream: Stream, withKeys keys: [String])
    optional func streamManager(manager: StreamManager, updatedActiveStream stream: Stream)
    optional func streamManager(manager: StreamManager, updatedActiveStream stream: Stream, withKeys keys: [String])
    optional func streamManager(manager: StreamManager, didSetActiveStream stream: Stream?)
    
}

class BatchStreamSaver {
    
    var savedStreams : [Stream] = []
    var completionBlock : ((streams : [Stream])->Void)?
    init(streamsData data: [JSON], completionBlock : ((streams : [Stream])->Void)?) {
        self.completionBlock = completionBlock
        
        self.saveOne(data)
    }
    
    func saveOne(var batch : [JSON]){
        
        if let data = batch.first {
            let _ = Stream(json: data, delegate: StreamManager.sharedInstance, completionBlock: {
                stream in
                
                StreamManager.sharedInstance.streams.append(stream)
                self.savedStreams.append(stream)
                
                batch.removeFirst()
                if batch.isEmpty {
                    self.completionBlock?(streams: self.savedStreams)
                } else {
                    self.saveOne(batch)
                }
            })
        }
    }
}

class StreamManager : NSObject, StreamDelegate {
    
    var userFeed : [Stream] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("UpdatedUserFeed", object: userStream, userInfo: nil)
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
        willSet {
//            if let initiator = StreamWindowManager.sharedInstance.streamInitiator {
//                initiator.reset()
//                StreamWindowManager.sharedInstance.streamInitiator = nil
//            }
        }
    }
    var activeStream : Stream? {
        didSet {
            if oldValue == activeStream {
                return
            }
            NSNotificationCenter.defaultCenter().postNotificationName("DidSetActiveStream", object: activeStream, userInfo: nil)
        }
        willSet {
            if let stream = newValue {
                self.player.loadStream(stream, loadTracks : newValue == self.userStream)
            }
        }
    }
    var player : StreamPlayer!
    
    class var sharedInstance : StreamManager {
        struct Singleton {
            static let instance = StreamManager()
        }
        return Singleton.instance
    }
    
    override init() {
        super.init()
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
                
                sharedInstance.player.play()
            }
        }
    }
    func pauseStream() {
        //        stream.status = false
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
    
    //    func updatedStream(stream: Stream, changedKey key: String?) {
    //        if stream.o_id != nil && stream == self.userStream && key != "users" && key != "likes" {
    //            var x = stream.toJSON([key!])
    //            println("tojson: \(x)")
    ////            RadioHunt.socket.emit("Stream:update", stream.toJSON(key))
    //        }
    //    }
    
    func stopStream(stream: Stream, completion : ((status: Bool) -> Void)?) {
        if stream != self.activeStream {
            return
        }
        
        Synnc.sharedInstance.socket.emitWithAck("Stream:stop", stream.o_id)(timeoutAfter: 0) {
            [weak self]
            data in
            
            if self == nil {
                return
            }
            
            if !data.isEmpty {
                if stream == self?.activeStream {
                    let a = self?.activeStream
                    self?.activeStream = nil
                    self?.player.resetPlayer()
                    let json = JSON(data)
                    a?.fromJSON(json)
                }
                completion?(status: true)
            } else {
                completion?(status: false)
            }
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
                self?.player.isSyncing = true
                
                if stream.isUserStream {
                } else {
                }
            } else {
                completion?(status: false)
            }
            
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
                        self.userStream?.fromJSON(json)
                        self.userStream?.createCallback?(status: true)
                        if $.find(self.streams, callback: {$0 == self.userStream!}) == nil {
                            self.streams.append(self.userStream!)
                        }
                    } else {
                        self.userStream?.createCallback?(status: false)
                    }
                }
            }
            
        } else {
            stream.toJSON(keys) {
                result in
                Synnc.sharedInstance.socket.emit("Stream:update", result)
            }
            
        }
    }
    func updatedStreamFromServer(stream: Stream, changedKeys keys: [String]?) {
        let changedKeys = keys == nil ? [] : keys!
        let notification = NSNotification(name: "UpdatedStream", object: stream, userInfo: ["updatedKeys" : changedKeys])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
}

extension StreamManager {
    func updateUserFeed(){
        Synnc.sharedInstance.socket.emitWithAck("Stream", [])(timeoutAfter: 0) {
            ack in
            Async.background {
                if let jsonArr = JSON(ack.first!).array {
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
        var arr : [Stream] = []
        var needsBatchSaving : [JSON] = []
        for json in serverData {
            if let stream = self.findStream(json["_id"].string) {
                arr.append(stream)
            } else {
                needsBatchSaving.append(json)
            }
        }
        
        let _ = BatchStreamSaver(streamsData: needsBatchSaving, completionBlock: {
            streams in
            
            let allData = $.union(arr, streams)
            completionBlock?(streams: allData)
        })
    }
}

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
                
                let x : String = $0.name
                let y : String = $1.name
                
                let range = Range<String.Index>(start: x.startIndex, end: x.endIndex)
                let res = x.compare(y, options: comparisonOptions, range: range, locale: nil)
                return res == NSComparisonResult.OrderedAscending
            })
        
        return filtered
    }
    
}

extension StreamManager {
    
    func setSocket(socket: SocketIOClient) {
        self.player = StreamPlayer(socket: socket)
        
        socket.on("Streams", callback: refreshStreamsCallback())
        socket.on("Stream:save", callback: streamSaveCallback())
        socket.on("Stream:delete", callback: streamDeleteCallback())
    }
    func streamDeleteCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            if let data = dataArr.first {
                var json = JSON(data)
                let stream = self.findStream(json["_id"].string)
                if stream != nil {
                    stream!.delegate = nil
                    if stream == self.activeStream {
                        self.activeStream = nil
                    }
                    self.streams.removeAtIndex(self.streams.indexOf(stream!)!)
                    
                    let notification = NSNotification(name: "RemovedStream", object: stream, userInfo: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
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
                    oldStream!.fromJSON(json)
                } else {
                    let newStream = Stream(json: json, delegate: self)
                    if $.find(self.streams, callback: {$0 == newStream}) == nil {
                        self.streams.append(newStream)
                    }
                    let notification = NSNotification(name: "NewStream", object: newStream, userInfo: nil)
                    NSNotificationCenter.defaultCenter().postNotification(notification)
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
                
                for item in json.array! {
                    let id = item["_id"].string
                    let oldStream = self.findStream(id)
                    if oldStream == nil {
                        let newStream = Stream(json: item, delegate: self)
                        if $.find(self.streams, callback: {$0 == newStream}) == nil {
                            self.streams.append(newStream)
                        }
                        let notification = NSNotification(name: "NewStream", object: newStream, userInfo: nil)
                        NSNotificationCenter.defaultCenter().postNotification(notification)
                    } else {
                        oldStream!.fromJSON(item)
                    }
                }
            }
        }
    }
    
}