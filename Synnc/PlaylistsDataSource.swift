//
//  PlaylistsDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLDataManager
import CoreData
import WCLUserManager
import WCLUtilities

protocol PlaylistsDataSourceDelegate {
    func playlistsDataSource(addedItem item: SynncPlaylist, newIndexPath indexPath : NSIndexPath)
    func playlistsDataSource(removedItem item: SynncPlaylist, fromIndexPath indexPath : NSIndexPath)
    func playlistsDataSource(updatedItem item: SynncPlaylist, atIndexPath indexPath : NSIndexPath)
    func playlistsDataSource(movedItem item: SynncPlaylist, fromIndexPath indexPath : NSIndexPath, toIndexPath newIndexPath : NSIndexPath)
}

class PlaylistsDataSource : NSObject {
    
    var oldItems_all : [SynncPlaylist] = []
    var playableItems_all : [SynncPlaylist] = []
    
    var delegate : PlaylistsDataSourceDelegate?
    var availableItemsDelegate : PlaylistsDataSourceDelegate?
    
    var frc: WCLCoreDataFRC!
    var availableSources : [String] {
        get {
            //check spotify availability:
            var x : [String] = [SynncExternalSource.Soundcloud.rawValue]
            
            if Synnc.sharedInstance.user.isLoggedIn(.Spotify) != nil && Synnc.sharedInstance.user.isLoggedIn(.Spotify)! == true  {
                x.append(SynncExternalSource.Spotify.rawValue)
            }
            return x
        }
    }
    var allItems : [SynncPlaylist] {
        get {
            if let items = frc.controller.fetchedObjects as? [SynncPlaylist] {
                return items
            } else {
                return []
            }
        }
    }
    var availablePlaylistPredicate : NSPredicate!
    var playableItems : [SynncPlaylist] {
        get {
            return self.allItems.filter({ self.availablePlaylistPredicate.evaluateWithObject($0) })
        }
    }
    
    override init(){
        super.init()
        self.availablePlaylistPredicate = NSPredicate { (obj, _) in
            if let playlist = obj as? SynncPlaylist {
                if playlist.allSources().isEmpty {
                    return false
                }
                return !playlist.allSources().map({
                    return self.availableSources.contains($0)
                }).contains(false)
            } else {
                return false
            }
        }
        frc = SynncPlaylist.finder(inContext: WildDataManager.sharedInstance().coreDataStack.getMainContext()).filter(NSPredicate(format: "user == %@ AND id != %@", Synnc.sharedInstance.user._id, NSNull())).sort(keys: ["last_update"], ascending: [true]).createFRC(delegate: self)
        
        self.playableItems_all = self.playableItems.map({return $0})
    }
    
}
extension PlaylistsDataSource : NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard let playlist = anObject as? SynncPlaylist else {
            return
        }

        switch type {
        case .Insert:
            self.delegate?.playlistsDataSource(addedItem: playlist, newIndexPath: newIndexPath!)
            checkPlayableChange(forItem: playlist)
            break
        case .Delete:
            self.delegate?.playlistsDataSource(removedItem: playlist, fromIndexPath: indexPath!)
            self.availableItemsDelegate?.playlistsDataSource(removedItem: playlist, fromIndexPath: indexPath!)
            break
        case .Update:
            self.delegate?.playlistsDataSource(updatedItem: playlist, atIndexPath: indexPath!)
            checkPlayableChange(forItem: playlist)
            break
        case .Move:
            self.delegate?.playlistsDataSource(movedItem: playlist, fromIndexPath: indexPath!, toIndexPath: newIndexPath!)
            checkPlayableChange(forItem: playlist)
            break
        }
    }
    func checkPlayableChange(forItem item: SynncPlaylist){
        let oldItems = self.playableItems_all
        let newItems = self.playableItems
        
        let newIndex = newItems.indexOf(item)
        let oldIndex = oldItems.indexOf(item)
        if let ni = newIndex, let oi = oldIndex {
            //updated
            if newIndex == oldIndex {
                self.availableItemsDelegate?.playlistsDataSource(updatedItem: item, atIndexPath: NSIndexPath(forItem: ni, inSection: 0))
            } else {
                self.availableItemsDelegate?.playlistsDataSource(movedItem: item, fromIndexPath: NSIndexPath(forItem: oi, inSection: 0), toIndexPath: NSIndexPath(forItem: ni, inSection: 0))
            }
            
        } else if let ni = newIndex {
            self.availableItemsDelegate?.playlistsDataSource(addedItem: item, newIndexPath: NSIndexPath(forItem: ni, inSection: 0))
            
        } else if let oi = oldIndex {
            self.availableItemsDelegate?.playlistsDataSource(removedItem: item, fromIndexPath: NSIndexPath(forItem: oi, inSection: 0))
        }
        self.playableItems_all = []
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.playableItems_all = self.playableItems.map({return $0})
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
}
let SharedPlaylistDataSource : PlaylistsDataSource = {
    return PlaylistsDataSource()
}()