//
//  TrackTransformer.swift
//  Synnc
//
//  Created by Arda Erzin on 12/21/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import UIKit

@objc(TrackTransformer)
class TrackTransformer: NSValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        print("REVERSE TRANSFORMED VALUE :", value)
        return nil
    }
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        print(value)
        guard let type = value as? AnyClass else { return nil }
        return NSStringFromClass(type)
    }
}
