//
//  ShareStreamPopup.swift
//  Synnc
//
//  Created by Arda Erzin on 4/9/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop

import FBSDKCoreKit
import FBSDKShareKit
import FBSDKMessengerShareKit
import Cloudinary

//class MessengerSharePopup : UIView {
//    var imageView : UIImageView!
//    var title : UILabel!
//    
//    init(frame: CGRect, image: UIImage!, title: String) {
//        super.init(frame: frame)
//        imageView = UIImageView(frame: frame)
//        imageView.image = image
//        self.addSubview(imageView)
//        
//        var overlay = UIView(frame: frame)
//        overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
//        
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class MessengerSharePopup : ASDisplayNode {
    var imageNode : ASImageNode!
    var titleNode : ASTextNode!
    
    init(image: UIImage, title: String) {
        super.init()
        
        imageNode = ASNetworkImageNode()
        imageNode.image = image
        self.addSubnode(imageNode)
        
        self.backgroundColor = .orangeColor()
        
        
        let attributes = [NSFontAttributeName: UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 88/255, green: 88/255, blue: 88/255, alpha: 1), NSKernAttributeName : 0.5]
        titleNode = ASTextNode()
        titleNode.attributedString = NSAttributedString(string: title, attributes: attributes)
        self.addSubnode(titleNode)
    }
    
    override func displayDidFinish() {
        super.displayDidFinish()
        print("display did finish")
    }
    
    override func layoutDidFinish() {
        print("layout did finish")
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(constrainedSize.max)
        return ASStaticLayoutSpec(children: [imageNode, titleNode])
    }
}

class ShareStreamPopup : WCLPopupViewController {
    
    var screenNode : ShareStreamPopupNode!
    var stream : Stream!
    var image : UIImage!
    
    init(size: CGSize, stream: Stream, image : UIImage!) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Bottom), withShadow: true)
        
        self.stream = stream
        self.image = image
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        self.draggable = true
        self.dismissable = true
        
        let node = ShareStreamPopupNode()
        self.screenNode = node
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
        
        node.facebookShareButton.addTarget(self, action: #selector(ShareStreamPopup.facebookShare(_:)), forControlEvents: .TouchUpInside)
        node.messengerShareButton.addTarget(self, action: #selector(ShareStreamPopup.messengerShare(_:)), forControlEvents: .TouchUpInside)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            let x = n.measureWithSizeRange(ASSizeRangeMake(CGSizeZero, self.view.frame.size))
            if x.size != self.size {
                self.size = x.size
                screenNode.view.frame = CGRect(origin: CGPointZero, size: self.size)
                self.configureView()
            }
        }
    }
    
    
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: screenNode)
    }
    override func didHide() {
        super.didHide()
        if oldScreen != nil {
            AnalyticsManager.sharedInstance.newScreen(oldScreen)
        }
    }
    
    func goToAppStore(sender: AnyObject) {
        if let customAppUrl = NSURL(string: "itms-beta://") {
            if UIApplication.sharedApplication().canOpenURL(customAppUrl) {
                if let url = NSURL(string: "https://beta.itunes.apple.com/v1/app/1065504357") {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
    }
    
    func facebookShare(sender : ASButtonNode!){
        
        let info = self.configure(stream)
        let content = FBSDKShareLinkContent()
        content.contentTitle = info.title
        content.contentURL = info.url
        content.imageURL = info.image
        content.contentDescription = info.description
        
        let dialog = FBSDKShareDialog()
        dialog.mode = FBSDKShareDialogMode.Native
        dialog.shareContent = content
        
        dialog.fromViewController = self
        dialog.show()
        
        AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: "facebook", value: nil)
    }
    func messengerShare(sender : ASButtonNode!){
        //        let content = FBSDKShareLinkContent()
        //        content.contentTitle = self.shareTitle
        //        content.contentURL = self.shareUrl
        //        content.imageURL = self.shareImg
        //        content.contentDescription = self.shareDescription
        //
        //        let dialog = FBSDKShareDialog()
        //        dialog.mode = FBSDKShareDialogMode.Native
        //        dialog.shareContent = content
        //
        //        dialog.fromViewController = self
        //        dialog.show()
        //
        //        AnalyticsEvent.new(category: "StreamSubsection", action: "share", label: "facebook", value: nil)
        
//        FBSDKMessengerSharer.shareImage(<#T##image: UIImage!##UIImage!#>, withOptions: nil)
        
//        let node : 
        
//        frame: CGRect(origin: CGPointZero, size: CGSizeMake(400, 400))
        let node = MessengerSharePopup(image: self.image, title: "Wadap son??")
//        self.view.addSubview(node.view)
        var size = node.measureWithSizeRange(ASSizeRangeMakeExactSize(CGSizeMake(400, 400)))
        node.layout()
        
        node.view.frame = CGRect(origin: CGPointZero, size: size.size)
//        let a = node.view.snapshotViewAfterScreenUpdates(false)
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(400, 400), true, 0)
        node.view.drawViewHierarchyInRect(CGRect(origin: CGPointZero, size: CGSizeMake(400, 400)), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("did draw")
        
//        FBSDKMessengerSharer.shareImage(image, withOptions: nil)
    }
    
    func configure(stream: Stream) -> (title: String, url : NSURL, description : String, image : NSURL!) {
        
        var name : String
        if let n = stream.playlist.name {
            name = n
        } else {
            name = "Untitled"
        }
        let shareTitle = name
        let shareUrl = NSURL(string: "https://silver-sister.codio.io:9500")!
        let shareDescription = "I'm listening to \(stream.user.username)'s stream, '\(name)'"
        
        let transformation = CLTransformation()
        
        transformation.width = 400 * UIScreen.mainScreen().scale
        transformation.height = 400 * UIScreen.mainScreen().scale
        transformation.crop = "fill"
        var shareImg : NSURL!
        if let str = stream.playlist.cover_id, let x = _cloudinary.url(str as String, options: ["transformation" : transformation]), let url = NSURL(string: x) {
            shareImg = url
        }
        
        return (shareTitle, shareUrl, shareDescription, shareImg)
    }
}

class ShareButton : ButtonNode {
 
    init(title : String, image: String) {
        super.init()
        
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor(red: 88/255, green: 88/255, blue: 88/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : pStyle]
        let title = NSAttributedString(string: title, attributes: attributes)
        self.setAttributedTitle(title, forState: .Normal)
        self.setImage(UIImage(named: image), forState: .Normal)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 5, justifyContent: .Center, alignItems: .Center, children: [imageNode, titleNode])
    }
    
}

class ShareButtonHolder : ASDisplayNode {
    var button : ButtonNode!
    init(button : ButtonNode){
        super.init()
        self.button = button
        self.addSubnode(button)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: button)
    }
}

class ShareStreamPopupNode : ASDisplayNode, TrackedView {
    
    var title: String! = "Stream Share View"
    var buttonHolders : [ShareButtonHolder] = []
    var facebookShareButton : ButtonNode!
    var messengerShareButton : ButtonNode!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.whiteColor()
        
        facebookShareButton = ShareButton(title: "Share on\nFacebook", image: "facebook-logo")
        let holder = ShareButtonHolder(button: facebookShareButton)
        self.addSubnode(holder)
        buttonHolders.append(holder)
        
        messengerShareButton = ShareButton(title: "Share on\nMessenger", image: "messenger")
        let holder2 = ShareButtonHolder(button: messengerShareButton)
        self.addSubnode(holder2)
        buttonHolders.append(holder2)
    }
   
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let spacer1 = ASLayoutSpec()
        spacer1.flexGrow = true
        let spacer2 = ASLayoutSpec()
        spacer2.flexGrow = true

        var specs : [ASLayoutSpec] = []
        for holder in buttonHolders {
            holder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeSize(ASRelativeSizeMake(ASRelativeDimension(type: .Points, value: constrainedSize.max.width/CGFloat(buttonHolders.count)), ASRelativeDimension(type: .Points, value: 200)))
            let spec = ASStaticLayoutSpec(children: [holder])
            specs.append(spec)
        }
        
        return ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: specs)
    }
}