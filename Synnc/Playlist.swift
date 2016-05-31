//
//  Playlist.swift
//
//
//  Created by Arda Erzin on 8/25/15.
//
//

//extension Dictionary {
//    mutating func merge<K, V>(dict: [K: V]){
//        for (k, v) in dict {
//            self.updateValue(v as! Value, forKey: k as! Key)
//        }
//    }
//}

import Foundation
import CoreData
import SocketSync
import WCLUtilities
import SwiftyJSON
import WCLUserManager

@objc protocol PlaylistDelegate {
    optional func didUpdateSongs()
    optional func willChangeCurrentIndex(index: Int)
}

@objc (SynncPersistentPlaylist)

class SynncPersistentPlaylist: NSManagedObject {
    
    @NSManaged var cover_id: String?
    @NSManaged var createdAt: NSDate?
    @NSManaged var id: String?
    @NSManaged var last_update: NSDate?
    @NSManaged var name: String?
    @NSManaged var songs: [SynncTrack]
    @NSManaged var sources: [String]?
    @NSManaged var user: String?
    @NSManaged var v: NSNumber?
    @NSManaged var location: String?
    @NSManaged var genres: Set<Genre>
    
    var delegate : PlaylistDelegate?
    var needsNotifySocket : Bool = false
    var socketCallback : ((playlist : SynncPersistentPlaylist) -> Void)?
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
    
    override class func getClassName() -> String{
        return "SynncPlaylist"
    }
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.createdAt = NSDate()
    }
    
    func sharedPlaylist() -> SynncSharedPlaylist {
        let a = SynncSharedPlaylist(playlist: self)
        return a
    }
}
