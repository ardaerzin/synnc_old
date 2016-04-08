//
//  ShareController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKMessengerShareKit
import Cloudinary
import Twitter

class ShareController : ASViewController {
    
    internal var shareTitle : String!
    internal var shareImg : NSURL!
    internal var shareUrl : NSURL!
    internal var shareDescription : String!
    
    var screenNode : ASDisplayNode!
    
    init(){
        let node = ShareNode()
        super.init(node: node)
        self.screenNode = node
        
        node.facebookShareButton.addTarget(self, action: #selector(ShareController.facebookShare(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.twitterShareButton.addTarget(self, action: #selector(ShareController.twitterShare(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.smsShareButton.addTarget(self, action: #selector(ShareController.smsShare(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(stream: Stream) {
        shareTitle = stream.name
        shareUrl = NSURL(string: "https://silver-sister.codio.io:9500")!
        shareDescription = "I'm listening to \(stream.user.name)'s stream, '\(stream.name)'"
        
        let transformation = CLTransformation()
        
        transformation.width = 400 * UIScreen.mainScreen().scale
        transformation.height = 400 * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        
        if let str = stream.img, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            shareImg = url
        }
    }
}

extension ShareController {
    func facebookShare(sender : ASButtonNode!){
        let content = FBSDKShareLinkContent()
        content.contentTitle = self.shareTitle
        content.contentURL = self.shareUrl
        content.imageURL = self.shareImg
        content.contentDescription = self.shareDescription
        
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.Native
        dialog.shareContent = content
        
        dialog.fromViewController = self
        dialog.show()
        
        AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: "facebook", value: nil)
    }
    func twitterShare(sender : ASButtonNode!){
        let tweetComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        tweetComposeViewController.setInitialText(self.shareDescription)
        tweetComposeViewController.addURL(self.shareUrl)
        
        self.presentViewController(tweetComposeViewController, animated: true, completion: nil)
        
        AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: "twitter", value: nil)
    }
    func smsShare(sender : ASButtonNode!){
        AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: "SMS", value: nil)
    }
}