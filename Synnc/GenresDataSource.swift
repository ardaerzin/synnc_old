//
//  GenresDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 1/4/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLDataManager
import CoreData
import WCLUserManager
import WCLUtilities

protocol GenresDataSourceDelegate {
    func genresDataSource(addedItem item: Genre, newIndexPath indexPath : NSIndexPath)
    func genresDataSource(removedItem item: Genre, fromIndexPath indexPath : NSIndexPath)
    func genresDataSource(updatedItem item: Genre, atIndexPath indexPath : NSIndexPath)
    func genresDataSource(movedItem item: Genre, fromIndexPath indexPath : NSIndexPath, toIndexPath newIndexPath : NSIndexPath)
}

class GenresDataSource : NSObject {
    
    var oldItems_all : [Genre] = []
    var delegate : GenresDataSourceDelegate?
    var frc: WCLCoreDataFRC!
    var allItems : [Genre] {
        get {
            if let items = frc.controller.fetchedObjects as? [Genre] {
                return items
            } else {
                return []
            }
        }
    }
    
    override init(){
        super.init()
        frc = Genre.finder(inContext: WildDataManager.sharedInstance().coreDataStack.getMainContext()).filter(NSPredicate(format: "id != %@", NSNull())).sort(keys: ["last_update"], ascending: [true]).createFRC(delegate: self)
    }
    
}
extension GenresDataSource : NSFetchedResultsControllerDelegate {
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        guard let genre = anObject as? Genre else {
            return
        }
        
        switch type {
        case .Insert:
            self.delegate?.genresDataSource(addedItem: genre, newIndexPath: newIndexPath!)
            break
        case .Delete:
            self.delegate?.genresDataSource(removedItem: genre, fromIndexPath: indexPath!)
            break
        case .Update:
            self.delegate?.genresDataSource(updatedItem: genre, atIndexPath: indexPath!)
            break
        case .Move:
            self.delegate?.genresDataSource(movedItem: genre, fromIndexPath: indexPath!, toIndexPath: newIndexPath!)
            break
        }
    }
}
let SharedGenresDataSource : GenresDataSource = {
    return GenresDataSource()
    }()