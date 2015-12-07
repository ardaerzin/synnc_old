//
//  Utilities.swift
//  Synnc
//
//  Created by Arda Erzin on 12/4/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

struct KeyboardAnimationInfo {
    var initialFrame: CGRect!
    var finalFrame: CGRect!
    var duration: NSTimeInterval
    var curve : UIViewAnimationCurve!
    var isDiplayed: Bool = true
    
    init(dict: [NSObject : AnyObject]) {
        
        self.initialFrame = (dict[UIKeyboardFrameBeginUserInfoKey]! as! NSValue).CGRectValue()
        self.finalFrame = (dict[UIKeyboardFrameEndUserInfoKey]! as! NSValue).CGRectValue()
        self.duration = dict[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        self.curve = UIViewAnimationCurve(rawValue: dict[UIKeyboardAnimationCurveUserInfoKey]!.integerValue)
        if CGRectGetMaxY(finalFrame) != CGRectGetMaxY(UIScreen.mainScreen().bounds) {
            isDiplayed = false
        }
    }
}