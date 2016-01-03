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
//
//    func findTrack(track : SynncTrack) -> SynncTrack {
//        let x = self.songs.filter{
//            t in
//            return t.source == track.source && t.song_id == track.song_id
//        }
//        return x.first
//    }
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
        
        var songsToDelete : [SynncTrack] = []
        var indexPaths : [NSIndexPath] = []
        for song in songArr {
            if let ind = self.indexOf(song) {
                self.songs.removeAtIndex(ind)
                indexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
            }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
//        self.removeSongs(atIndexPaths: indexPaths)
    }
    
    /**
    Removes songs from the playlist
    
    :param: indexPaths   Index paths of items to be removed
    */
    func removeSong(atIndexPath indexPath : NSIndexPath) {
        self.songs.removeAtIndex(indexPath.item)
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : [indexPath]]])
    }
    
    func removeSongs(atIndexPaths indexPaths: [NSIndexPath]) {
        if indexPaths.isEmpty {
            return
        }
        
//        self.songs.removeAtIndex(<#T##index: Int##Int#>)
    
        let indexes = NSMutableIndexSet()
        for index in indexPaths {
//            indexes.addIndex(index.item)
        }
        
//        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
//        self.removeSongs(indexes, indexPaths: indexPaths)
    }
    
//    internal func removeSongs(indexSet : NSMutableIndexSet, indexPaths: [NSIndexPath]){
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        arr.removeObjectsAtIndexes(indexSet)
//        
////        self.songs.remo
//        
//        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
//    }
    
    /**
    Changes track index in a playlist
    
    :param: fromIndexPath   Original index path of the track before the change
    :param: toIndexPath   Target index path of the track after the change
    */
    func moveSong(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath){
        
        
        let song = self.songs.removeAtIndex(fromIndexPath.item)
        self.songs.insert(song, atIndex: toIndexPath.item)
//        self.songs.
//        self.songs.
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        arr.moveObjectsAtIndexes(NSIndexSet(index: fromIndexPath.item), toIndex: toIndexPath.item)
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
                    }
                }
            }
        }
        
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
        super.willSave()
    }
}