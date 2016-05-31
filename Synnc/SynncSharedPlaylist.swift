//
//  SynncSharedPlaylist.swift
//  Synnc
//
//  Created by Arda Erzin on 5/30/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUtilities
import WCLUserManager
import SwiftyJSON
import WCLDataManager

func ==(left: SynncSharedPlaylist?, right: SynncPersistentPlaylist?) -> Bool {
    guard let l = left, r = right else {
        return false
    }
    return l.id == r.id
}
func ==(left: SynncPersistentPlaylist?, right: SynncSharedPlaylist?) -> Bool {
    guard let l = left, r = right else {
        return false
    }
    return l.id == r.id
}
//func !=(left: CustomClass, right: CustomClass) -> Bool {
//    return !(left == right)
//}

class SynncSharedPlaylist {
    var cover_id: String?
    var createdAt: NSDate?
    var id: String?
    var name: String?
    var songs: [SynncTrack] = []
    var sources: [String]?
    var user: String?
    var v: NSNumber?
    var location: String?
    var genres: [Genre] = []
    
    init?(json: JSON? = nil) {
        print("**********init shared with json")
        guard let j = json else {
            return nil
        }
        self.fromJSON(j)
    }
    
    init(playlist : SynncPersistentPlaylist) {
        self.cover_id = playlist.cover_id
        self.createdAt = playlist.createdAt
        self.id = playlist.id
        self.name = playlist.name
        self.songs = playlist.songs
        self.sources = playlist.sources
        self.user = playlist.user
        self.v = playlist.v
        self.location = playlist.location
        self.genres = Array(playlist.genres)
    }
    
    func canPlay() -> (status: Bool, reasonDict : [String : AnyObject]?) {
        
        let infoDict = self.validateInfo()
        let sourceDict = self.checkSources()
        
        let status = infoDict.status && sourceDict.status
        
        var dict = infoDict.reasonDict!
        dict.merge(sourceDict.reasonDict!)
        
        return (status: status, reasonDict: dict)
    }
    
    internal func validateInfo() -> (status: Bool, reasonDict : [String : AnyObject]?) {
        
        var status = true
        var missingKeys : [String] = []
        
        if self.songs.isEmpty {
            status = false
            missingKeys.append("songs")
        }
        
        if self.name == nil || self.name == "" {
            status = false
            missingKeys.append("name")
        }
        
        return (status: status, reasonDict: ["missingInfo" : missingKeys])
    }
    
    internal func checkSources() -> (status: Bool, reasonDict : [String : AnyObject]?) {
        
        let sources = allSources()
        var missingSources : [String] = []
        
        for source in SynncExternalSource.premiumSources {
            let x = source.rawValue
            if let _ = sources.indexOf(x) {
                guard let user = Synnc.sharedInstance.user, let type = WCLUserLoginType(rawValue: x.lowercaseString), let ext = user.userExtension(type), let status = ext.loginStatus where status else {
                    
                    missingSources.append(x)
                    continue
                }
            }
        }
        
        return (status: missingSources.isEmpty, reasonDict: ["missingSources" : missingSources])
    }
    
    func allSources() -> [String] {
        var x : [String] = []
        for song in self.songs {
            let ind = x.indexOf(song.source)
            if ind == nil {
                x.append(song.source)
            }
        }
        return x
    }
    
    func fromJSON(json : JSON) {
        if let x = json["cover_id"].string {
            self.cover_id = x
        }
        if let x = json["createdAt"].double {
            self.createdAt = NSDate(timeIntervalSince1970: x)
        }
        if let x = json["id"].string {
            self.id = x
        }
        if let x = json["name"].string {
            self.name = x
        }
        if let x = json["user"].string {
            self.user = x
        }
        if let x = json["v"].number {
            self.v = x
        }
        if let x = json["location"].string {
            self.location = x
        }
        if let x = json["sources"].array {
            var sources : [String] = []
            for item in x {
                if let str = item.string {
                    sources.append(str)
                }
            }
            self.sources = sources
        }
        
        if let x = json["genres"].array {
            self.genres = []
            for entity in x {
                let predicate = NSPredicate(format: "id == %@", entity["_id"].string!)
                
                Genre.findOne(inStack: nil, predicate: predicate) {
                    objects, context in
                    var genre : Genre
                    if objects.count > 0 {
                        let y = objects[0] as! Genre
                        y.parseFromJSON(context, json: entity)
                        genre = y
                    } else {
                        genre = Genre.create(inContext: context, fromJSON : entity) as! Genre
                    }
                    
                    self.genres.append(genre)
                }
            }
        }
        if let x = json["songs"].array {
            var tracks : [SynncTrack] = []
            for t in x {
                let track = SynncTrack()
                track.fromJSON(t)
                tracks.append(track)
            }
            self.songs = tracks
        }
    }
    
    func toJSON() -> [String : AnyObject] {
      
        var a = [String : AnyObject]()
        a["name"] = self.name
        a["id"] = self.id
        a["cover_id"] = self.cover_id
        a["user"] = self.user
        a["v"] = self.v
        a["location"] = self.location
        a["sources"] = self.sources
        a["createdAt"] = self.createdAt?.timeIntervalSince1970
        
        var genres : [[String : AnyObject]] = []
        for g in self.genres {
            let x = g.toJSON(nil)
            genres.append(x)
        }
        a["genres"] = genres
        
        var ts : [[String : AnyObject]] = []
        for s in self.songs {
            let x = s.toJSON(nil)
            ts.append(x)
        }
        a["songs"] = ts
        
        return a
    }
}

class SynncPlaylistBase : SynncPlaylistProtocol {
    func indexOf(track: SynncTrack) -> Int? {
        return nil
    }
}