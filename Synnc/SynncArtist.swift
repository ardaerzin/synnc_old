//
//  SynncArtist.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import CoreData
import WCLSoundCloudKit
import WCLUtilities
import SocketSync
import SwiftyJSON

class SynncArtist : Serializable {
    var name : String!
    var id : String!
    var avatar : String!
    var source : String!

    required init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        let keys = self.propertyNames(classForCoder)
        for key in keys {
//            if key == "source" {
//                if let srcStr = aDecoder.decodeObjectForKey(key) as? String {
//                    self.source = SynncExternalSource(rawValue: srcStr)
//                }
//            } else {
                self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
//            }
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let keys = self.propertyNames(classForCoder)
        for key in keys {
//            if key == "source" {
//                aCoder.encodeObject(self.source.rawValue, forKey: key)
//            } else {
                aCoder.encodeObject(self.valueForKey(key), forKey: key)
//            }
        }
    }
    
    class func id(fromData data: AnyObject, type : SynncExternalSource) -> String {
        var id : String = ""
        switch type {
        case .Soundcloud:
            id = soundcloudIdFromData(data)
        case .Spotify:
            id = spotifyIdFromData(data)
        default:
            return ""
        }
        
        return id
    }
    class func create(data : AnyObject, source : SynncExternalSource) -> SynncArtist {
//        let filtered = SynncTrackStore.sharedInstance.artists.filter({
//            artist in
//            return artist.source! == source && artist.id! == id(fromData: data, type : source)
//        })
//        
//        if let item = filtered.first {
//            return item
//        }
        
        let artist = SynncArtist()
        SynncTrackStore.sharedInstance.artists.append(artist)
        
        switch source {
        case .Spotify:
            artist.parseSpotify(data)
        case .Soundcloud:
            artist.parseSoundcloud(data)
        default:
            break
        }
        return artist
    }
    
//    override func fromJSON(json: JSON) -> [String] {
//        let x = super.fromJSON(json)
//        if let s = json["source"].string {
//            print(self.name)
//            if let s = SynncExternalSource(rawValue: s) {
//                self.source = s
//            }
//        }
//        return x
//    }
//    override func toJSON() -> [String : AnyObject] {
//        print(self.name)
//        print(self.source)
//        var x = super.toJSON()
//        print(self.source)
//        x["source"] = self.source.rawValue
//        return x
//    }
}
