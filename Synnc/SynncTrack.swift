//
//  SynncTrack.swift
//  Synnc
//
//  Created by Arda Erzin on 12/15/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import CoreData
import WCLSoundCloudKit
import WCLUtilities
import SocketSync
import SwiftyJSON

enum SynncExternalSource : String {
    case Soundcloud = "Soundcloud"
    case Spotify = "Spotify"
}

class SynncTrackStore {
    
    var artists : [SynncArtist] = []
    var tracks : [SynncTrack] = []
    
    class var sharedInstance : SynncTrackStore {
        get {
            return _sharedTrackStore
        }
    }
}

let _sharedTrackStore: SynncTrackStore = { SynncTrackStore() }()
class SynncTrack: Serializable {
    
    var artwork_url: String?
    var source: String!
    var id: String!
    var song_id: String!
    var info: AnyObject!
//    var playlists: NSOrderedSet
    var name: String!
    var artists : [SynncArtist]! = []
    var streamUrl : String!
    
    required init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            if key != "artwork_url_large" {
                self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
            }
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            if key != "artwork_url_large" {
                aCoder.encodeObject(self.valueForKey(key), forKey: key)
            }
        }
    }
    
    /// Computed Properties
    var artwork_url_large : String? {
        get {
            if let url = self.artwork_url {
                return url.stringByReplacingOccurrencesOfString("large", withString: "t500x500", options: [], range: nil)
            }
            return nil
        }
    }
    class func id(fromData data: AnyObject, type : SynncExternalSource) -> String {
        var id : String = ""
        switch type {
        case .Soundcloud:
            id = soundcloudIdFromData(data)
        case .Spotify:
            id = spotifyIdFromData(data)
        }
        return id
    }
    class func source(fromData data: JSON) -> SynncExternalSource? {
        var source : SynncExternalSource!
        if let srcStr = data["source"].string, let src = SynncExternalSource(rawValue: srcStr) {
            return src
        } else {
            return nil
        }
    }
    override func propertyNames(c: AnyClass) -> [String] {
        if c != self.classForCoder {
            return super.propertyNames(c)
        } else {
            var a = self.propertyList()
            if let ind = a.indexOf("artwork_url_large") {
                a.removeAtIndex(ind)
            }
            return a
        }
    }
    
    class func create(data: AnyObject, source : SynncExternalSource) -> SynncTrack {
//        let filtered = SynncTrackStore.sharedInstance.tracks.filter({
//            track in
//            
//            return track.source == source.rawValue && track.song_id == id(fromData: data, type : source)
//        })
//        
//        if let item = filtered.first {
//            return item
//        }
        
        let track = SynncTrack()
        
        
        switch source {
        case .Spotify:
            track.createSpotifySong(data)
        case .Soundcloud:
            track.createSoundcloudSong(data)
        }
        
        SynncTrackStore.sharedInstance.tracks.append(track)
        return track
    }
  
    
    override func fromJSON(json: JSON) -> [String] {
        let x = super.fromJSON(json)
        
        if let artistsArr = json["artists"].array {
            var artists : [SynncArtist] = []
            for item in artistsArr {
                let x = SynncArtist()
                x.fromJSON(item)
//                print(item)
//                let x = SynncArtist.create(item.object, source: SynncExternalSource(rawValue: self.source)!)
//                print(x)
                artists.append(x)
//                print(x.name)
            }
            self.artists = artists
        }
        return x
    }
//    override func toJSON(keyArr: [String]!, populate: Bool) -> [String : AnyObject] {
//        var keys = self.propertyNames()
//        if let ind = keys.indexOf("playlists") {
//            keys.removeAtIndex(ind)
//        }
//        return super.toJSON(keys, populate: populate)
//    }
}