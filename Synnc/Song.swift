//
//  Song.swift
//  
//
//  Created by Arda Erzin on 8/25/15.
//
//

import Foundation
import CoreData
import WCLSoundCloudKit
import WCLUtilities
import SocketSync
import SwiftyJSON

enum SongSource : String {
    case Soundcloud = "Soundcloud"
    case Spotify = "Spotify"
}

class SCUser : Serializable {
    var name : String!
    var id : String!
    var avatar : String!
    
    init(data: AnyObject?) {
        super.init()
        
//        if let sptUser = data as? SPTPartialArtist {
//            parseFromSpotify(sptUser)
//        } else if data != nil {
//            var json = JSON(data!)
//            if json != nil && json.null == nil {
//                self.parseSoundcloud(json)
//            }
//        }
    }
//    
//    func parseSoundcloud(user: JSON) {
//        let id = user["id"].int
//        self.id = "\(id)"
//        self.name = user["username"].string
//        self.avatar = user["avatar_url"].string
//    }
//    
//    func parseFromSpotify(user: SPTPartialArtist) {
//        self.id = user.identifier
//        self.name = user.name
//    }
//    
//    override init() {
//        super.init()
//    }
//    required init(coder aDecoder: NSCoder) {
//        super.init()
//        let keys = self.propertyNames(classForCoder)
//        for key in keys {
//            self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
//        }
//    }
//    func encodeWithCoder(aCoder: NSCoder) {
//        let keys = self.propertyNames(classForCoder)
//        for key in keys {
//            aCoder.encodeObject(self.valueForKey(key), forKey: key)
//        }
//    }
}

@objc (Song)

class Song: NSManagedObject {

    @NSManaged var artwork_url: String?
    @NSManaged var waveform_url: String?
    @NSManaged var source: String
    @NSManaged var id: String
    @NSManaged var song_id: String
    @NSManaged var info: AnyObject
    @NSManaged var playlists: NSOrderedSet
    @NSManaged var name: String?
    @NSManaged var user : SCUser!
    @NSManaged var streamUrl : String!
    
    
    override func awakeFromInsert() {
        if self.user == nil {
//            self.user = SCUser()
        }
//        super.awakeFromInsert()
    }
    var artwork_url_large : String? {
        get {
            
            if let url = self.artwork_url {
                return url.stringByReplacingOccurrencesOfString("large", withString: "t500x500", options: [], range: nil)
            }
            return nil
        }
    }
//    class func id(fromData data: AnyObject, type : SongSource) -> String {
//        var id : String = ""
//        switch type {
//        case .Soundcloud:
//            if let x = JSON(data)["id"].number {
//                id = "\(x)"
//            }
//            break
//        case .Spotify:
//            if let sptsong = data as? SPTPartialTrack {
//                id = sptsong.identifier
//            }
//            break
//        }
//        return id
//    }
//    
//    class func create(data: AnyObject, source : SongSource) -> Song {
//        
//        let song = Song.create(inContext: RadioHunt.moc) as! Song
//        
//        if let spotifySong = data as? SPTPartialTrack {
//            song.createSpotifySong(spotifySong)
//        } else {
//            var json = JSON(data)
//            if json != nil && json.null == nil {
//                song.createFromJSON(source, data: json)
//            }
//        }
//        
//        return song
//    }
//    
//    private func createFromJSON(source: SongSource, data: JSON) {
//        switch source {
//        case .Soundcloud:
//            self.createSoundcloudSong(data)
//            break
//        case .Spotify:
//            break
//        }
//    }
//    
//    private func createSpotifySong(track: SPTPartialTrack) {
//        self.source = SongSource.Spotify.rawValue
//        self.name = track.name
//        self.song_id = track.identifier
//        
//        if let artist = track.artists.first as? SPTPartialArtist {
//            self.user = SCUser(data: artist)
//        }
//        self.artwork_url = track.album.largestCover?.imageURL.absoluteString
//    }
//    
//    private func createSoundcloudSong(data: JSON) {
//        self.name = data["title"].string
//        let x = data["id"].number!
//        self.song_id = "\(x)"
//        self.source = SongSource.Soundcloud.rawValue
//        
//        var u = data["user"]
//        if u.null == nil {
//            self.user = SCUser(data: u.object)
//        }
//        if let waveform = data["waveform_url"].string {
//            self.waveform_url = WildSoundCloud.appendAccessToken(waveform)
//        }
//        if let artwork = data["artwork_url"].string {
//            self.artwork_url = WildSoundCloud.appendAccessToken(artwork)
//        }
//        if let url = data["stream_url"].string {
//            let urlString = WildSoundCloud.appendAccessToken(url)
//            self.streamUrl = urlString
//        }
//    }
//    override func toJSON(keyArr: [String]!, populate: Bool) -> [String : AnyObject] {
//        var keys = self.propertyNames()
//        if let ind = keys.indexOf("playlists") {
//            keys.removeAtIndex(ind)
//        }
//        return super.toJSON(keys, populate: populate)
//    }
}
