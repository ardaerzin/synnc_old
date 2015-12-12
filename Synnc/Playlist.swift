//
//  Playlist.swift
//
//
//  Created by Arda Erzin on 8/25/15.
//
//

import Foundation
import CoreData
import SocketSync
import WCLUtilities
import SwiftyJSON

@objc protocol PlaylistDelegate {
     optional func didUpdateSongs()
     optional func willChangeCurrentIndex(index: Int)
}

@objc (Playlist)

class Playlist: NSManagedObject {
     
     @NSManaged var id: String?
     @NSManaged var v: NSNumber?
     @NSManaged var createdAt: NSDate?
     @NSManaged var name: String?
     @NSManaged var user: String?
     @NSManaged var source: String?
     @NSManaged var sources: [String]?
     @NSManaged var last_update: NSDate?
     @NSManaged var songs: NSOrderedSet
     
     var delegate : PlaylistDelegate?
     var currentIndex : Int = 0 {
          didSet {
               
          }
          willSet {
               self.delegate?.willChangeCurrentIndex?(newValue)
          }
     }
     var coverImageURL : String! {
          get {
               if let song = self.songs.firstObject as? Song {
                    if song.source == SongSource.Soundcloud.rawValue {
                         if let url = song.artwork_url {
                              return url.stringByReplacingOccurrencesOfString("large", withString: "t500x500", options: [], range: nil)
                         }
                    } else {
                         return song.artwork_url
                    }
               }
               return nil
          }
     }
}
