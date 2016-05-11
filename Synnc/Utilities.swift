//
//  Utilities.swift
//  Synnc
//
//  Created by Arda Erzin on 12/4/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

// MARK: - Version Checker
extension String {
    
    func fixAppleMusic() -> String {
        return self.stringByReplacingOccurrencesOfString(SynncExternalSource.AppleMusic.rawValue, withString: "Apple Music")
    }
    
    func versionToInt() -> [Int] {
        return self.componentsSeparatedByString(".")
            .map {
                Int.init($0) ?? 0
        }
    }
    func compareToMinRequiredVersion(version: String) -> Int {
        var a = self.versionToInt()
        var b = version.versionToInt()
        
        var c = b
        
        var status : Int = 0
        for (ind, val) in a.enumerate(){
            if val < b[ind] {
                status = -1
                break
            }
            if val > b[ind] {
                status = 1
                break
            }
            a.removeAtIndex(0)
            c.removeAtIndex(0)
        }
        
        if c.count > a.count {
            status = -1
        }
        return status
    }
}


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
        return UIColor(red: 234/255, green: 119/255, blue: 35/255, alpha: 1)
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

extension UIImage {
    func resizeForUpload() -> UIImage? {
        let cgImage = self.CGImage
        
        var s = self.size
        let iw = s.width
        let ih = s.height
        
        var nh : CGFloat
        var nw : CGFloat
        
        var height : Int
        var width : Int
        
        let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
        let bytesPerRow = CGImageGetBytesPerRow(cgImage)
        let colorSpace = CGImageGetColorSpace(cgImage)
        let bitmapInfo = CGImageGetBitmapInfo(cgImage)
        
        var context : CGContextRef
        
        if self.imageOrientation == .Up || self.imageOrientation == .Down {
            print(bitsPerComponent)
        
            if iw > 1125 || ih > 1125 {
                if iw > ih {
                    nh = 1125
                    nw = nh * (iw/ih)
                } else {
                    nw = 1125
                    nh = nw * (ih/iw)
                }
                s = CGSizeMake(nw, nh)
            } else {
                return self
            }
            
            print("size before resize:", self.size, s)
            
            width = Int(s.width)
            height = Int(s.height)
            
            context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, 0, colorSpace, bitmapInfo.rawValue)!
        } else {
            
            if iw > 1125 || ih > 1125 {
                if iw > ih {
                    nh = 1125
                    nw = nh * (ih/ih)
                } else {
                    nw = 1125
                    nh = nw * (ih/iw)
                }
                s = CGSizeMake(nh, nw)
            } else {
                return self
            }
            
            print("size before resize:", self.size, s)
            
            width = Int(s.width)
            height = Int(s.height)
            
            context = CGBitmapContextCreate(nil, height, width, bitsPerComponent, 0, colorSpace, bitmapInfo.rawValue)!
        }
        
        switch self.imageOrientation {
        case .Left :
            CGContextRotateCTM(context, radians(90))
            CGContextTranslateCTM(context, 0, CGFloat(-height))
            break
        case .Right:
            CGContextRotateCTM(context, radians(-90))
            CGContextTranslateCTM(context, CGFloat(-width), 0)
            break
        case .Up:
            break
        case .Down:
            CGContextTranslateCTM(context, CGFloat(width), CGFloat(height))
            CGContextRotateCTM(context, radians(-180))
            break
        default:
            break
        }
        
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), cgImage)
        
        let scaledImage = CGBitmapContextCreateImage(context).flatMap { UIImage(CGImage: $0) }
        
        return scaledImage
    }
    
    func radians(degree: Double) -> CGFloat {
        return CGFloat(degree * M_PI / 180)
    }
}

func radians(degree: Double) -> CGFloat {
    return CGFloat(degree * M_PI / 180)
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