//
//  Playlist.swift
//
//
//  Created by Arda Erzin on 8/25/15.
//
//

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

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
    
    func canPlay() -> (status: Bool, reasonDict : [String : AnyObject]?) {
        
        var reasonDict = [String : AnyObject]()
        
        
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
        
        for source in SynncPremiumSources {
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
}
