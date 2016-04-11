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

@objc (SynncPlaylist)

class SynncPlaylist: NSManagedObject {
    
    @NSManaged var cover_id: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var id: String?
    @NSManaged var last_update: NSDate?
    @NSManaged var name: String?
    @NSManaged var songs: [SynncTrack]
    @NSManaged var source: String?
    @NSManaged var sources: [String]?
    @NSManaged var user: String?
    @NSManaged var v: NSNumber?
    @NSManaged var location: String?
    @NSManaged var genres: Set<Genre>
    
    var delegate : PlaylistDelegate?
    var needsNotifySocket : Bool = false
    var socketCallback : ((playlist : SynncPlaylist) -> Void)?
    var isDeleting : Bool = false
    
    /// Computed Properties
    internal var _coverImage : UIImage!
    var coverImage : UIImage! {
        get {
            if let id = cover_id where id != "" {
                return nil
            } else {
                return _coverImage
            }
        }
        set {
            _coverImage = newValue
        }
    }
    var currentIndex : Int = 0 {
        didSet {
            
        }
        willSet {
            self.delegate?.willChangeCurrentIndex?(newValue)
        }
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
}
