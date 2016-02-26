//
//  Playlist+Synnc.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON
import SocketSync

extension SynncPlaylist {
    override func awakeFromInsert() {
        self.createdAt = NSDate()
    }
    
    func indexOf(track : SynncTrack) -> Int? {
        let x = self.songs.filter{
            t in
            return t.source == track.source && t.song_id == track.song_id
        }
        
        if let t = x.first {
            return self.songs.indexOf(t)
        } else {
            return nil
        }
    }

    func hasTrack(track : SynncTrack) -> Bool {
        let x = self.songs.filter{
            t in
            return t.source == track.source && t.song_id == track.song_id
        }
        return !x.isEmpty
    }
    
    /**
    Adds songs to the playlist
    
    :param: songArr   Array of songs to be added
    */
    func addSongs(songArr: [SynncTrack]){
        if songArr.isEmpty {
            return
        }
    
        var previousLastIndex = self.songs.count-1
        
        self.songs += songArr
        var indexPaths : [NSIndexPath] = []
        
        for _ in songArr {
            previousLastIndex++
            indexPaths.append(NSIndexPath(forItem: previousLastIndex, inSection: 0))
        }
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["addedSongs" : ["songs" : songArr, "indexPaths" : indexPaths]])
    }
    
    /**
    Removes songs from the playlist
    
    :param: songArr   Array of songs to be removed
    */
    func removeSongs(songArr: [SynncTrack]){
        if songArr.isEmpty {
            return
        }
        
        var indexPaths : [NSIndexPath] = []
        for song in songArr {
            if let ind = self.indexOf(song) {
                self.songs.removeAtIndex(ind)
                indexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
    }
    
    /**
    Removes songs from the playlist
    
    :param: indexPaths   Index paths of items to be removed
    */
    func removeSong(atIndexPath indexPath : NSIndexPath) {
        self.songs.removeAtIndex(indexPath.item)
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : [indexPath]]])
    }
    
    /**
    Changes track index in a playlist
    
    :param: fromIndexPath   Original index path of the track before the change
    :param: toIndexPath   Target index path of the track after the change
    */
    func moveSong(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath){
        
        
        let song = self.songs.removeAtIndex(fromIndexPath.item)
        self.songs.insert(song, atIndex: toIndexPath.item)
    }
    
    
    override func didSave() {
        super.didSave()
        
        if self.managedObjectContext == Synnc.sharedInstance.moc {
            let msg = self.id == nil ? "create" : "update"
            if needsNotifySocket {
                Synnc.sharedInstance.socket.emitWithAck("SynncPlaylist:\(msg)", self.toJSON(nil, populate: true)) (timeoutAfter: 0) {
                    ack in
                    if msg == "update" {
                        return
                    }
                    if let data: AnyObject = ack.last {
                        let json = JSON(data)
                        self.parseFromJSON(self.managedObjectContext!, json: json)
                        self.save()
                        
                        if let cb = self.socketCallback {
                            cb(playlist: self)
                        }
                    }
                }
            }
        }
        
    }
    
    override func propertyNames() -> [String] {
        var x = super.propertyNames()
        if let ind = x.indexOf("delegate") {
            x.removeAtIndex(ind)
        }
        if let ind = x.indexOf("needsNotifySocket") {
            x.removeAtIndex(ind)
        }
        if let ind = x.indexOf("socketCallback") {
            x.removeAtIndex(ind)
        }
        if let ind = x.indexOf("_coverImage") {
            x.removeAtIndex(ind)
        }
        if let ind = x.indexOf("coverImage") {
            x.removeAtIndex(ind)
        }
        
        return x
    }
    
    override func willSave() {
        if self.managedObjectContext != Synnc.sharedInstance.moc {
            super.willSave()
            return
        }
        
        if !self.changedValues().isEmpty && self.changedValues().keys.indexOf("v") == nil {
            needsNotifySocket = true
        } else {
            needsNotifySocket = false
        }
        
        if let plist = SharedPlaylistDataSource.findUserFavoritesPlaylist() where plist == self {
            NSNotificationCenter.defaultCenter().postNotificationName("UpdatedFavPlaylist", object: nil, userInfo: nil)
        }
        
        super.willSave()
    }
}