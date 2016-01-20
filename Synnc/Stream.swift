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

@objc protocol StreamDelegate {
    optional func updatedStreamLocally(stream: Stream, changedKeys keys: [String]?)
    optional func updatedStreamFromServer(stream: Stream, changedKeys keys: [String]?)
    optional func updatedStream(stream: Stream, changedKey key: String?)
    optional func createdStream(stream: Stream)
    optional func removedStream(stream: Stream)
}

//class UserStream : Serializable {
//
//}

class Stream : Serializable {
    
    /**
    
    Active status of stream, set by the Master Stream
    
    */
    var status: ObjCBool = false {
        didSet {
            
        }
    }
    
    var delegate : StreamDelegate? = Synnc.sharedInstance.streamManager {
        didSet {
            //Notify delegate
            //            self.delegate?.createdStream?(self)
        }
    }
    var genres : [Genre] = []
    dynamic var name: String!
    var img: NSString!
    var lat: NSNumber!
    var lon: NSNumber!
    var user: WCLUser!
    var userid: String!
    var city : NSString!
    dynamic var currentSongIndex : NSNumber! = 0
    var info : String = ""
    dynamic var playlist : SynncPlaylist!
    
    var createCallback : ((status : Bool) -> Void)?
    var isActiveStream : Bool {
        get {
            return self === Synnc.sharedInstance.streamManager.activeStream
        }
    }
    var isUserStream : Bool {
        get {
            return self === Synnc.sharedInstance.streamManager.userStream
        }
    }
    dynamic var songIds : [NSNumber] = []
    var users : [WCLUser] = []
    internal func keys() -> [String] {
        return self.propertyNames(Stream)
    }
    deinit {
        self.delegate?.removedStream?(self)
        
        //        for key in self.keys() {
        //            self.removeObserver(self, forKeyPath: key)
        //        }
        //
    }
    required init() {
        super.init()
        self.last_update = NSDate(timeIntervalSince1970: NSTimeInterval(0))
        
        //        for key in self.keys() {
        //            self.addObserver(self, forKeyPath: key, options: NSKeyValueObservingOptions.New, context: nil)
        //        }
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
    convenience init(json: JSON){
        self.init()
        self.fromJSON(json)
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
        
        var userInd, usersInd, playlistInd, genresInd : Int?
        
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
        if let gInd = prop.indexOf("genres") {
            genresInd = gInd
            prop.removeAtIndex(gInd)
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
            dict["playlist"] = self.playlist.id
            //                self.playlist.toJSON(nil, populate: true)
        }
        if !self.users.isEmpty, let _ = usersInd {
            var x : [String] = []
            for item in self.users {
                x.append(item._id)
            }
            dict["genres"] = x
        }
        if !self.genres.isEmpty, let _ = genresInd {
            var x : [String] = []
            for item in self.genres {
                x.append(item.id)
            }
            dict["genres"] = x
        }
        if self.user != nil, let _ = userInd {
            dict["user"] = self.user._id
        }
        
        return dict
    }
    override func fromJSON(json: JSON) -> [String] {
        return self.fromJSON(json, callback: nil)
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
                let genresInfo = shit["genres"].object.copy()
                
                let x = JSON(shit.object.copy())
                if var j = x.dictionary {
                    j.removeValueForKey("playlist")
                    j.removeValueForKey("user")
                    j.removeValueForKey("genres")
                    j.removeValueForKey("users")
                    json = JSON(j)
                }
                
                var keys = super.fromJSON(json)
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
                    if let plist = SynncPlaylist.finder(inContext: Synnc.sharedInstance.moc).filter(NSPredicate(format: "id == %@", JSON(plistInfo)["_id"].stringValue)).sort(keys: ["id"], ascending: [true]).find()?.first as? SynncPlaylist {
                        self.playlist = plist
                    } else {
                        let newPlaylist = SynncPlaylist.create(inContext: Synnc.sharedInstance.moc, fromJSON: JSON(plistInfo)) as! SynncPlaylist
                        self.playlist = newPlaylist
                    }
                } else if JSON(plistInfo).dictionary != nil{
                    if self.playlist.v != JSON(plistInfo)["__v"].intValue {
                        self.playlist.parseFromJSON(Synnc.sharedInstance.moc, json: JSON(plistInfo))
                        keys.append("playlist")
                    }
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
                
                
                let genresJSON = JSON(genresInfo)
                if let arr = genresJSON.array {
                    var genresArr : [Genre] = []
                    for item in arr {
                        var genre : Genre!
                        if let id = item["_id"].string {
                            
                            if let g = Genre.finder(inContext: Synnc.sharedInstance.moc).filter(NSPredicate(format: "id == %@", id)).sort(keys: ["id"], ascending: [true]).find()?.first as? Genre {
                                genre = g
                            } else {
                                //                        g = Genre.
                                //                        genre =
                                //                            WildUserManager.sharedInstance().newUser(fromJSON: item)
                            }
                        }
                        genresArr.append(genre)
                    }
                    
                    let oldGenresSet = Set(self.genres)
                    let newGenresSet = Set(genresArr)
                    let newGenres = newGenresSet.subtract(oldGenresSet)
                    let oldGenres = oldGenresSet.subtract(newGenresSet)
                    
                    if oldGenres.count > 0 || newGenres.count > 0 {
                        keys.append("genres")
                    }
                    
                    self.genres = genresArr
                    
                    
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