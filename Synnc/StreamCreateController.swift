//
//  StreamCreateController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/3/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLPopupManager
import WCLLocationManager
import WCLNotificationManager

protocol StreamCreateControllerDelegate {
    func resetScrollPosition()
    func updatedData()
    func updatedImage(image : UIImage!)
    func updatedPlaylist(playlist : SynncPlaylist!)
    func createdStream(stream : Stream)
}

class StreamCreateController : NSObject {
    
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("sourceSelectionAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamCreateController).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamCreateController).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("displayAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("displayAnimation")
                }
                x.springBounciness = 0
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "displayAnimation")
                return x
            }
        }
    }
    var displayAnimationProgress : CGFloat = 1 {
        didSet {
            self.contentNode.alpha = displayAnimationProgress
//            self.backgroundNode.startStreamButton.alpha = displayAnimationProgress
//            self.backgroundNode.locationToggle.alpha = displayAnimationProgress
//            self.backgroundNode.genreToggle.alpha = displayAnimationProgress
        }
    }
    
    var delegate : StreamCreateControllerDelegate?
    var playlist : SynncPlaylist!
    var stream : Stream?
    var tempStream : Stream!
    
    var streamCity : String!
    var selectedImage : UIImage!
    var imagePicker : SynncImagePicker!
    var parentController : ASViewController?
    var streamName : String!
    var streamGenres : [Genre] = []
    
    var loadingNode : StreamLoadingNode!
    
    var backgroundNode : StreamBackgroundNode!
    var contentNode : ASDisplayNode! {
        get {
            return playlistSelector.screenNode
        }
    }
    
    var playlistSelector : PlaylistSelectorController = PlaylistSelectorController()
    
    init(backgroundNode : StreamBackgroundNode!){
        super.init()
        self.backgroundNode = backgroundNode
        backgroundNode.state = .Create
        self.playlistSelector.delegate = self
        
        self.backgroundNode.editing = true
        
        self.backgroundNode.imageSelector.addTarget(self, action: Selector("imageSelector:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
//        self.backgroundNode.imageNode.addTarget(self, action: Selector("imageSelector:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.backgroundNode.infoNode.genreToggle.addTarget(self, action: Selector("genreSelector:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.backgroundNode.infoNode.startStreamButton.addTarget(self, action: Selector("createStreamAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.backgroundNode.infoNode.locationToggle.addTarget(self, action: Selector("toggleLocation:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        self.backgroundNode.infoNode.streamTitle.delegate = self
        
        self.tempStream = Stream(user: Synnc.sharedInstance.user)
    }
    
    func genreSelector(sender : ButtonNode) {
        let popup = GenrePicker(size: CGSizeMake(325, 400), genres : self.streamGenres)
        popup.delegate = self
        WCLPopupManager.sharedInstance.newPopup(popup)
    }
    
    func imageSelector(sender : ButtonNode) {
        imagePicker = SynncImagePicker()
        imagePicker.assetType = .AllPhotos
        imagePicker.showsEmptyAlbums = false
        imagePicker.maxSelectableCount = 1
        imagePicker.showsCancelButton = true
        
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
                
                img.fetchFullScreenImageWithCompleteBlock {
                    image, info in
                    if let img = image {
                        self.selectedImage = img
                        self.delegate?.updatedData()
                    }
                }
            }
            
            if let parent = self.parentController as? StreamViewController {
                parent.screenNode.mainScrollNode.scrollViewDidScroll(parent.screenNode.mainScrollNode.view)
            }
        }
        if let parent = self.parentController as? StreamViewController {
            parent.presentViewController(imagePicker, animated: true) {}
        }
    }
    func toggleLocation(sender : ButtonNode) {
        let managerStatus = WCLLocationManager.sharedInstance().locationMngrStatus
        switch managerStatus {
        case -1:
            
            let s = Synnc.sharedInstance
            let controller = s.locationAuthController()
            controller.callback = {
                success in
                if !sender.selected {
                    self.getAddress()
                } else {
                    self.backgroundNode.updateLocation(status: false)
                }
            }
            s.locationManager.requestLocationPermission(controller)
            
            break
        case 0:
            
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Please go to iOS settings and enable location support for Synnc.", title: "Location Error", sound: nil, fireDate: nil, showLocalNotification: false, object: nil, id: nil))
            }
            return
            
        case 1 :
            
//            sender.selected = !sender.selected
            if !sender.selected {
                self.getAddress()
            } else {
                self.backgroundNode.updateLocation(status: false)
            }
            
            break
        default :
            return
        }
    }
    
    func getAddress(){
        let location = WCLLocationManager.sharedInstance().getCurrentLocation()
        WCLLocationManager.sharedInstance().gpsManager.reverseGeocodeLocationUsingGoogleWithCoordinates(location, callback: { (address, error) -> Void in
            if let ad = address {
                self.streamCity = (ad.locality as String).uppercaseString
                
                Async.main {
                    self.backgroundNode.updateLocation(self.streamCity, status: true)
                }
            }
        })
    }

    func createStreamAction(sender : ButtonNode) {
        if self.streamName == nil {
            self.backgroundNode.infoNode.streamTitle.becomeFirstResponder()
            return
        }
        
        if let p = self.parentController as? StreamViewController {
            if let s = p.screenNode.mainScrollNode.view, let z = p.screenNode {
                s.scrollEnabled = false
                loadingNode = StreamLoadingNode()
                z.addSubnode(loadingNode)
                let spec = loadingNode.measureWithSizeRange(ASSizeRangeMake(CGSizeMake(z.calculatedSize.width, 0), CGSizeMake(z.calculatedSize.width, 200)))
                loadingNode.view.frame = CGRect(origin: CGPointMake(z.calculatedSize.width / 2 - (spec.size.width / 2), (z.calculatedSize.height + z.calculatedSize.width) / 2 - (spec.size.height / 2)), size: spec.size)
                
                self.delegate?.resetScrollPosition()
                self.backgroundNode.editing = false
                self.backgroundNode.state = .Hidden
                self.displayAnimation.toValue = 0
            }
        }
        
        if let img = self.selectedImage {
            Synnc.sharedInstance.imageUploader = CLUploader(_cloudinary, delegate: nil)
            let data = UIImageJPEGRepresentation(img, 1)
            let a = CLTransformation()
            a.angle = "exif"
            Synnc.sharedInstance.imageUploader.upload(data, options: ["transformation" : a], withCompletion: {
                [unowned self]
                
                (successResult, errorString, code, context)  in
                
                if let err = errorString {
                    if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                        WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Please try to create your stream once again", title: "Couldn't Upload Stream Image", sound: nil, fireDate: nil, showLocalNotification: false, object: nil, id: nil))
                        print(err)
                    }
                    self.backgroundNode.editing = true
                } else {
                    
                    var info = self.createStreamInfoObject()
                    if let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                        let id = "image/upload/v\(v)/\(publicId).\(format)"
                        info["img"] = id
                    }
                    self.createAndUpdateStream(info)
                }
                
            }, andProgress: nil)
            
        } else {
            createAndUpdateStream(self.createStreamInfoObject())
        }
    }
    
    func createStreamInfoObject() -> [String : AnyObject]{
        var info : [String : AnyObject] = [String : AnyObject]()
        
        if let url = self.playlist.cover_id {
            info["img"] = url
        }
        if let name = self.streamName {
            info["name"] = name
        }
        if let plist = self.playlist {
            info["playlist"] = plist
        }
        if let city = self.streamCity {
            info["city"] = city
        }
        
        info["genres"] = self.streamGenres
        info["lat"] = 0
        info["lon"] = 0
        
        return info
    }
    
    func createAndUpdateStream(info : [String : AnyObject]){
        tempStream.update(info)
        tempStream.createCallback = {
            success in
            if let anim = self.pop_animationForKey("displayAnimation") as? POPSpringAnimation {
                anim.completionBlock = {
                    anim, finished in
                    self.createdStream()
                }
            } else {
                self.createdStream()
            }
            
        }
        Synnc.sharedInstance.streamManager.userStream = tempStream
    }
    
    func createdStream(){
        let animation = POPSpringAnimation(propertyNamed: kPOPViewAlpha)
        animation.completionBlock = {
            animation, finished in
            self.delegate?.createdStream(self.tempStream)
        }
        self.loadingNode.view.pop_addAnimation(animation, forKey: "alpha")
        animation.toValue = 0
    }
}

extension StreamCreateController : GenrePickerDelegate {
    func didCancel() {
        
    }
    func pickedGenres(genres: [Genre]) {
        self.streamGenres = genres
        self.backgroundNode.updateGenres(genres)
    }
}

extension StreamCreateController : PlaylistSelectorDelegate {
    func didSelectPlaylist(playlist: SynncPlaylist) {
        self.playlist = playlist
        self.delegate?.updatedData()
    }
}

extension StreamCreateController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            return false
        }
        if let fieldStr = editableTextNode.textView.text {
            var str = (fieldStr as NSString).stringByReplacingCharactersInRange(range, withString: text)
            str = (str as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.streamName = str
        }
        return true
    }
}