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
    case YouTube = "Youtube"
    case Grooveshark = "Grooveshark"
    case GooglePlay = "Googleplay"
    case AppleMusic = "Applemusic"
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
    var duration : NSNumber!
    var name: String!
    var artists : [SynncArtist]! = []
    var uri: String! = ""
    
    var streamUrl : String! {
        get {
            if let id = self.song_id where self.source == SynncExternalSource.Soundcloud.rawValue {
                let x = WildSoundCloud.sharedInstance().getStreamUrlString(id)
                return x
            } else {
                return nil
            }
        }
    }
    
    required init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            if key != "artwork_url_large" || key != "stream_url" {
                self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
            }
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            if key != "artwork_url_large" || key != "stream_url" {
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
        case .AppleMusic:
            id = appleMusicIdFromData(data)
        default:
            return ""
        }
        return id
    }
    class func source(fromData data: JSON) -> SynncExternalSource? {
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
            } else if let ind = a.indexOf("stream_url") {
                a.removeAtIndex(ind)
            }
            return a
        }
    }
    
    class func create(data: AnyObject, source : SynncExternalSource) -> SynncTrack {
        let track = SynncTrack()
        
        switch source {
        case .Spotify:
            track.createSpotifySong(data)
            break
        case .Soundcloud:
            track.createSoundcloudSong(data)
        case .AppleMusic:
            track.createAppleMusicSong(data)
            break
        default:
            break
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
                artists.append(x)
            }
            self.artists = artists
        }
        return x
    }
}