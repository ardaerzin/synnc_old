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

enum SynncExternalSource : String {
    case Soundcloud = "Soundcloud"
    case Spotify = "Spotify"
}

@objc (SynncTrack)
class SynncTrack: NSManagedObject {

    @NSManaged var artwork_url: String?
    @NSManaged var waveform_url: String?
    @NSManaged var source: String
    @NSManaged var id: String
    @NSManaged var song_id: String
    @NSManaged var info: AnyObject
    @NSManaged var playlists: NSOrderedSet
    @NSManaged var name: String?
    @NSManaged var artists : [SynncArtist]!
    @NSManaged var streamUrl : String!
    
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
    class func create(data: AnyObject, source : SynncExternalSource) -> SynncTrack {
        let song = SynncTrack.create(inContext: Synnc.sharedInstance.moc) as! SynncTrack
        switch source {
        case .Spotify:
            song.createSpotifySong(data)
        case .Soundcloud:
            song.createSoundcloudSong(data)
        }
        return song
    }
    override func toJSON(keyArr: [String]!, populate: Bool) -> [String : AnyObject] {
        var keys = self.propertyNames()
        if let ind = keys.indexOf("playlists") {
            keys.removeAtIndex(ind)
        }
        return super.toJSON(keys, populate: populate)
    }
}
