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
            self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            aCoder.encodeObject(self.valueForKey(key), forKey: key)
        }
    }
    
    class func id(fromData data: AnyObject, type : SynncExternalSource) -> String {
        var id : String = ""
        switch type {
        case .Soundcloud:
            id = soundcloudIdFromData(data)
        case .Spotify:
//            id = spotifyIdFromData(data)
            id = ""
        default:
            return ""
        }
        
        return id
    }
    class func create(data : AnyObject, source : SynncExternalSource) -> SynncArtist {
        let artist = SynncArtist()
        SynncTrackStore.sharedInstance.artists.append(artist)
        
        switch source {
        case .Spotify:
//            artist.parseSpotify(data)
            break
        case .Soundcloud:
            artist.parseSoundcloud(data)
        default:
            break
        }
        return artist
    }
}
