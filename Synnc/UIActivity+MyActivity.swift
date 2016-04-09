//
//  UIActivity+MyActivity.swift
//  Synnc
//
//  Created by Arda Erzin on 4/9/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKMessengerShareKit
import Cloudinary

class SynncFacebookActivity : UIActivity{
    
    override init() {
        super.init()
    }
    
    var info : (title: String, url : NSURL, description : String, image : NSURL!)!
    
    override func activityType()-> String {
        return NSStringFromClass(self.classForCoder)
    }
    
    override func activityImage()-> UIImage
    {
        return UIImage(named: "facebook-logo")!
    }
    
    override func activityTitle() -> String
    {
        return "Facebook";
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Share
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for activityItem in activityItems
        {
            if (activityItem.isKindOfClass(NSString))
            {
                return true
            } else if activityItem.isKindOfClass(NSURL) {
            }
        }
        return false;
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        for activityItem in activityItems{
            if activityItem.isKindOfClass(Stream){
                self.info = configure(activityItem as! Stream)
            }
        }
    }
    
    override func performActivity() {
        let content = FBSDKShareLinkContent()
        content.contentTitle = info.title
        content.contentURL = info.url
        content.imageURL = info.image
        content.contentDescription = info.description
        
        let dialog = FBSDKShareDialog()
        dialog.delegate = self
        dialog.mode = FBSDKShareDialogMode.Native
        dialog.shareContent = content
        dialog.show()
    }
    
    func configure(stream: Stream) -> (title: String, url : NSURL, description : String, image : NSURL!) {
        let shareTitle = stream.name
        let shareUrl = NSURL(string: "https://silver-sister.codio.io:9500")!
        let shareDescription = "I'm listening to \(stream.user.username)'s stream, '\(stream.name)'"
        
        let transformation = CLTransformation()
        
        transformation.width = 400 * UIScreen.mainScreen().scale
        transformation.height = 400 * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        var shareImg : NSURL!
        if let str = stream.img, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            shareImg = url
        }
        
        return (shareTitle, shareUrl, shareDescription, shareImg)
    }
}

extension SynncFacebookActivity : FBSDKSharingDelegate {
    func sharerDidCancel(sharer: FBSDKSharing!) {
        self.activityDidFinish(false)
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        self.activityDidFinish(false)
    }
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        self.activityDidFinish(true)
    }
}