//
//  Genre.swift
//  
//
//  Created by Arda Erzin on 6/22/15.
//
//

import Foundation
import CoreData

@objc (Genre)

class Genre: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var last_update: NSDate
    @NSManaged var v: NSNumber
    @NSManaged var name: String
    @NSManaged var playlists: NSSet?
}
