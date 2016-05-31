//
//  Stream.swift
//  Music App
//
//  Created by Arda Erzin on 4/21/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLSoundCloudKit
import WCLUserManager
import WCLUtilities
import CoreData
import WCLDataManager
import SwiftyJSON
import Async

@objc protocol StreamDelegate {
    optional func updatedStreamLocally(stream: Stream, changedKeys keys: [String]?)
    optional func updatedStreamFromServer(stream: Stream, changedKeys keys: [String]?)
    optional func updatedStream(stream: Stream, changedKey key: String?)
    optional func createdStream(stream: Stream)
    optional func removedStream(stream: Stream)
}

class StreamTimeStamp : Serializable {
    var stream_id : String!
    var player_time : NSNumber!
    var timeStamp : NSNumber!
    var playlist_index : NSNumber!
    
    override func fromJSON(json: JSON) -> [String] {
        let a = super.fromJSON(json)
        return a
    }
}

class Stream : Serializable {
    
    /**
    
    Active status of stream, set by the Master Stream
    
    */
    var status: ObjCBool = false {
        didSet {
        }
    }
    var delegate : StreamDelegate? = Synnc.sharedInstance.streamManager
    var timestamp : StreamTimeStamp?
    var lat: NSNumber!
    var lon: NSNumber!
    var user: WCLUser!
    var userid: String!
    var currentSongIndex : NSNumber! = 0
    var info : String = ""
    var playlist : SynncSharedPlaylist!
    var users : [WCLUser] = []
    
    var createCallback : ((status : Bool) -> Void)?
    var isActiveStream : Bool {
        get {
            return self === Synnc.sharedInstance.streamManager.activeStream
        }
    }
    var isUserStream : Bool {
        get {
            let a = self === Synnc.sharedInstance.streamManager.userStream
            return a
        }
    }
    
    class func create(playlist : SynncPersistentPlaylist, callback : ((status : Bool) -> Void)?) -> Stream {
        
        let stream = Stream(user: Synnc.sharedInstance.user)
        stream.createCallback = callback
        
        var info : [String : AnyObject] = [String : AnyObject]()
        info["playlist"] = playlist
        info["lat"] = 0
        info["lon"] = 0

        stream.update(info)
        Synnc.sharedInstance.streamManager.userStream = stream
        
        return stream
    }
    
    internal func keys() -> [String] {
        return self.propertyNames(Stream)
    }
    
    deinit {
        self.delegate?.removedStream?(self)
    }
    required init() {
        super.init()
        self.last_update = NSDate(timeIntervalSince1970: NSTimeInterval(0))
    }
    convenience init(json: JSON, delegate : StreamDelegate?){
        self.init()
        self.fromJSON(json, callback: {
            stream in
            
            stream.delegate = delegate
            stream.delegate?.createdStream?(self)
        })
    }
    convenience init(json: JSON, delegate : StreamDelegate?, completionBlock : ( (stream:Stream) -> Void )?) {
        self.init()
        self.fromJSON(json, callback: {
            stream in
            
            completionBlock?(stream: stream)
            stream.delegate = delegate
            stream.delegate?.createdStream?(self)
        })
    }
    convenience init(user: MainUser) {
        self.init()
        
        self.lat = 0
        self.lon = 0
        self.userid = user._id
        self.user = user
    }
    
    func update(values: [NSObject : AnyObject]){
        var keys: [String] = []
        for (key,value) in values {
            keys.append(key as! String)
            self.setValue(value, forKey: key as! String)
        }
        
        self.delegate?.updatedStreamLocally?(self, changedKeys : keys)
    }
    
    override func fromJSON(json: JSON) -> [String] {
        return self.fromJSON(json, callback: nil)
    }
}


// MARK: - From & To JSON

extension Stream {
    //modify createJSON to loop songs
    func toJSON(properties: [String]? = nil, callback: ((result : [String : AnyObject])->Void)?) {
        Async.background {
            let x = self.toJSON(properties)
            Async.main {
                callback?(result: x)
            }
        }
    }
    override func toJSON(properties: [String]?) -> [String : AnyObject] {
        
        var prop = properties == nil ? self.propertyNames(Stream) : properties!
        
        var userInd, usersInd, playlistInd : Int?
        
        if let ind = prop.indexOf("__v") {
            prop.removeAtIndex(ind)
        }
        
        if let ind = prop.indexOf("user") {
            userInd = ind
            prop.removeAtIndex(ind)
        }
        if let plistInd = prop.indexOf("playlist") {
            playlistInd = plistInd
            prop.removeAtIndex(plistInd)
        }
        if let dInd = prop.indexOf("delegate") {
            prop.removeAtIndex(dInd)
        }
        if let usInd = prop.indexOf("users") {
            usersInd = usInd
            prop.removeAtIndex(usInd)
        }
        
        if let shit = prop.indexOf("createCallback") {
            prop.removeAtIndex(shit)
        }
        
        var dict = super.toJSON(prop)
        
        if self.playlist != nil, let _ = playlistInd {
            //dodo
            dict["playlist"] = self.playlist.toJSON()
            
//            dict["playlist"] = self.playlist.id
            //                self.playlist.toJSON(nil, populate: true)
        }
        if !self.users.isEmpty, let _ = usersInd {
            var x : [String] = []
            for item in self.users {
                x.append(item._id)
            }
            dict["users"] = x
        }
        if self.user != nil, let _ = userInd {
            dict["user"] = self.user._id
        }
        
        return dict
    }
    
    func fromJSON(shit: JSON, callback: ((stream : Stream) -> Void)? ) -> [String] {
        
        Async.background {
            if shit["__v"].intValue < self.__v {
            } else {
                
                self.__v = shit["__v"].intValue
                
                var json : JSON!
                let plistInfo = shit["playlist"].object.copy()
                let userInfo = shit["user"].object.copy()
                let listenersInfo = shit["users"].object.copy()
                var tsInfo : AnyObject?
                
                
                if let _ = shit["timestamp"].null {
                } else {
                    tsInfo = shit["timestamp"].object.copy()
                }
                
                let x = JSON(shit.object.copy())
                if var j = x.dictionary {
                    j.removeValueForKey("playlist")
                    j.removeValueForKey("user")
                    j.removeValueForKey("users")
                    j.removeValueForKey("timestamp")
                    json = JSON(j)
                }
                
                var keys = super.fromJSON(json)
                
                if let tsi = tsInfo {
                    let tsJSON = JSON(tsi)
                    let ts = StreamTimeStamp()
                    ts.fromJSON(tsJSON)
                    
                    if let os = self.timestamp {
                        if os.timeStamp.compare(ts.timeStamp) == .OrderedAscending {
                            keys.append("timestamp")
                            self.timestamp = ts
                        }
                    } else {
                        keys.append("timestamp")
                        self.timestamp = ts
                    }
                }
                
                let listenersJSON = JSON(listenersInfo)
                if let arr = listenersJSON.array {
                    
                    
                    var usersArr : [WCLUser] = []
                    
                    for item in arr {
                        var user : WCLUser!
                        
                        if let id = item["_id"].string {
                            if let u = WCLUserManager.sharedInstance.findUser(id) {
                                user = u
                            } else {
                                user = WCLUserManager.sharedInstance.newUser(fromJSON: item)
                            }
                        }
                        usersArr.append(user)
                    }
                    
                    let oldUsersSet = Set(self.users)
                    let newUsersSet = Set(usersArr)
                    let newUsers = newUsersSet.subtract(oldUsersSet)
                    let oldUsers = oldUsersSet.subtract(newUsersSet)
                    
                    if oldUsers.count > 0 || newUsers.count > 0 {
                        keys.append("users")
                    }
                    
                    self.users = usersArr
                    
                }
                
                if self.playlist == nil && JSON(plistInfo).null == nil {
//                    let plist = SynncSharedPlaylist()
                    
                    let plist = SynncSharedPlaylist(json: JSON(plistInfo))
                    self.playlist = plist
                    
//                    if let plist = SynncPersistentPlaylist.finder(inContext: Synnc.sharedInstance.moc).filter(NSPredicate(format: "id == %@", JSON(plistInfo)["_id"].stringValue)).sort(keys: ["id"], ascending: [true]).find()?.first as? SynncPersistentPlaylist {
//                        self.playlist = plist
//                    } else {
//                        let newPlaylist = SynncPersistentPlaylist.create(inContext: Synnc.sharedInstance.moc, fromJSON: JSON(plistInfo)) as! SynncPersistentPlaylist
//                        self.playlist = newPlaylist
//                    }
                } else if JSON(plistInfo).dictionary != nil {
                    
                    self.playlist.fromJSON(JSON(plistInfo))
                    
//                    if self.playlist.v != JSON(plistInfo)["__v"].intValue {
//                        self.playlist.parseFromJSON(Synnc.sharedInstance.moc, json: JSON(plistInfo))
//                        keys.append("playlist")
//                    }
                }
                
                if let _ = self.user {
                } else {
                    let json = JSON(userInfo)
                    var user : WCLUser!
                    if let id = json["_id"].string {
                        if let u = WCLUserManager.sharedInstance.findUser(id) {
                            user = u
                        } else {
                            user = WCLUserManager.sharedInstance.newUser(fromJSON: json)
                        }
                    }
                    
                    self.user = user
                    
                    keys.append("user")
                }

                Async.main {
                    self.delegate?.updatedStreamFromServer?(self, changedKeys: keys)
                    callback?(stream: self)
                }
            }
        }
        
        return []
    }
}