//
//  SynncArtist.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import CoreData
import WCLSoundCloudKit
import WCLUtilities
import SocketSync
import SwiftyJSON

class SynncArtist : Serializable {
    var name : String!
    var id : String!
    var avatar : String!
    var source : SynncExternalSource!

    override init() {
        super.init()
    }
    required init(coder aDecoder: NSCoder) {
        super.init()
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            self.setValue(aDecoder.decodeObjectForKey(key), forKey: key)
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        let keys = self.propertyNames(classForCoder)
        for key in keys {
            aCoder.encodeObject(self.valueForKey(key), forKey: key)
        }
    }
}
