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
    
    /**
    Adds songs to the playlist
    
    :param: songArr   Array of songs to be added
    */
    func addSongs(songArr: [SynncTrack]){
        if songArr.isEmpty {
            return
        }
        
        let arr = self.mutableOrderedSetValueForKey("songs")
        var previousLastIndex = arr.count-1
        arr.addObjectsFromArray(songArr)
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
        let arr = self.mutableOrderedSetValueForKey("songs")
        var indexPaths : [NSIndexPath] = []
        for song in songArr {
            let ind = arr.indexOfObject(song)
            indexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
        }
        
        self.removeSongs(atIndexPaths: indexPaths)
    }
    
    /**
    Removes songs from the playlist
    
    :param: indexPaths   Index paths of items to be removed
    */
    func removeSongs(atIndexPaths indexPaths: [NSIndexPath]) {
        if indexPaths.isEmpty {
            return
        }
    
        let indexes = NSMutableIndexSet()
        for index in indexPaths {
            indexes.addIndex(index.item)
        }
        
        self.removeSongs(indexes, indexPaths: indexPaths)
    }
    
    internal func removeSongs(indexSet : NSMutableIndexSet, indexPaths: [NSIndexPath]){
        let arr = self.mutableOrderedSetValueForKey("songs")
        arr.removeObjectsAtIndexes(indexSet)
        
        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
    }
    
    /**
    Changes track index in a playlist
    
    :param: fromIndexPath   Original index path of the track before the change
    :param: toIndexPath   Target index path of the track after the change
    */
    func moveSong(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath){
        let arr = self.mutableOrderedSetValueForKey("songs")
        arr.moveObjectsAtIndexes(NSIndexSet(index: fromIndexPath.item), toIndex: toIndexPath.item)
    }
    
    
    override func didSave() {
        super.didSave()
        
        if self.managedObjectContext == Synnc.sharedInstance.moc {
            print("did save playlist. changed vals: \(self.changedValuesForCurrentEvent())")
            let msg = self.id == nil ? "create" : "update"
            
            if needsNotifySocket {
                Synnc.sharedInstance.socket.emitWithAck("Playlist:\(msg)", self.toJSON(nil, populate: true)) (timeoutAfter: 0) {
                    ack in
                    print("playlist \(msg) message ack")
                    if let data: AnyObject = ack.first {
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