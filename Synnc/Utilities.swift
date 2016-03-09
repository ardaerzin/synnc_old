//
//  Utilities.swift
//  Synnc
//
//  Created by Arda Erzin on 12/4/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

extension String {
    func NSRangeFromRange(range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.startIndex, within: utf16view)
        let to = String.UTF16View.Index(range.endIndex, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
    }
}

extension UIColor {
    class func SynncColor() -> UIColor {
        return UIColor(red: 236/255, green: 102/255, blue: 88/255, alpha: 1)
    }
}

protocol WildAnimated {
    var animator : WildTransitioning! { get set }
    var displayStatusBar : Bool! { get set }
}

extension UIColor {
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

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