//
//  Playlist+Synnc.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

extension Playlist {
//    override func awakeFromInsert() {
//        self.createdAt = NSDate()
//    }
//    
//    /**
//    Adds songs to the playlist
//    
//    :param: songArr   Array of songs to be added
//    */
//    func addSongs(songArr: [Song]){
//        if songArr.isEmpty {
//            return
//        }
//        
//        //          var x = NSOrderedSet(array: songArr)
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        var previousLastIndex = arr.count-1
//        arr.addObjectsFromArray(songArr)
//        var indexPaths : [NSIndexPath] = []
//        
//        for _ in songArr {
//            //               self.addSource(song.source)
//            previousLastIndex++
//            indexPaths.append(NSIndexPath(forItem: previousLastIndex, inSection: 0))
//        }
//        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["addedSongs" : ["songs" : songArr, "indexPaths" : indexPaths]])
//    }
//    
//    //     func addSource(source: String) {
//    //          if self.sources == nil {
//    //               self.sources = [source]
//    //          } else {
//    //               if self.sources!.indexOf(source) == nil {
//    //                    self.sources?.append(source)
//    //               }
//    //          }
//    //     }
//    /**
//    Removes songs from the playlist
//    
//    :param: songArr   Array of songs to be removed
//    */
//    func removeSongs(songArr: [Song]){
//        if songArr.isEmpty {
//            return
//        }
//        
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        
//        var indexPaths : [NSIndexPath] = []
//        for song in songArr {
//            let ind = arr.indexOfObject(song)
//            indexPaths.append(NSIndexPath(forItem: ind, inSection: 0))
//        }
//        
//        arr.removeObjectsInArray(songArr)
//        
//        for _ in songArr {
//            //               self.removeSource(song.source)
//        }
//        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : songArr, "indexPaths" : indexPaths]])
//    }
//    /**
//    Removes songs from the playlist
//    
//    :param: indexPaths   Index paths of items to be removed
//    */
//    func removeSongs(atIndexPaths indexPaths: [NSIndexPath]) {
//        if indexPaths.isEmpty {
//            return
//        }
//        
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        let indexes = NSMutableIndexSet()
//        for index in indexPaths {
//            indexes.addIndex(index.item)
//        }
//        let items = arr.objectsAtIndexes(indexes)
//        arr.removeObjectsAtIndexes(indexes)
//        for item in items {
//            //               self.removeSource(item.source)
//        }
//        NSNotificationCenter.defaultCenter().postNotificationName("PlaylistUpdatedSongs", object: self, userInfo: ["removedSongs" : ["songs" : [], "indexPaths" : indexPaths]])
//    }
//    
//    //     func removeSource(source:String) {
//    //          if self.sources != nil {
//    //               let x = (self.songs.array as! [Song]).filter({$0.source == "source"})
//    //
//    //               if x.isEmpty {
//    //                    if let ind = self.sources!.indexOf(source) {
//    //                         self.sources?.removeAtIndex(ind)
//    //                    }
//    //               }
//    //          }
//    //     }
//    /**
//    
//    */
//    func findIndex(song: WildPlayerItem) {
//        print("song: \(song)")
//    }
//    
//    func moveSong(fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath){
//        let arr = self.mutableOrderedSetValueForKey("songs")
//        arr.moveObjectsAtIndexes(NSIndexSet(index: fromIndexPath.item), toIndex: toIndexPath.item)
//    }
//    
//    
//    var needsNotifySocket : Bool = false
//    override func didSave() {
//        super.didSave()
//        
//        if self.managedObjectContext == RadioHunt.moc {
//            print("did save playlist. changed vals: \(self.changedValuesForCurrentEvent())")
//            let msg = self.id == nil ? "create" : "update"
//            
//            if needsNotifySocket {
//                print("***server Message: \(msg)")
//                RadioHunt.socket.emitWithAck("Playlist:\(msg)", self.toJSON(nil, populate: true)) (timeoutAfter: 0) {
//                    ack in
//                    print("ack here")
//                    if let data: AnyObject = ack.first {
//                        let json = JSON(data)
//                        self.parseFromJSON(self.managedObjectContext!, json: json)
//                        self.save()
//                    }
//                }
//            }
//        }
//        
//    }
//    
//    func allSources() -> [String] {
//        var x : [String] = []
//        for song in self.songs.array as! [Song] {
//            let ind = x.indexOf(song.source)
//            if ind == nil {
//                x.append(song.source)
//            }
//        }
//        return x
//    }
//    override func willSave() {
//        if self.managedObjectContext != RadioHunt.moc {
//            super.willSave()
//            return
//        }
//        
//        if !self.changedValues().isEmpty && self.changedValues().keys.indexOf("v") == nil {
//            needsNotifySocket = true
//        } else {
//            needsNotifySocket = false
//        }
//        super.willSave()
//    }
}