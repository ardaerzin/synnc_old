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
import WCLLocationManager
import WCLNotificationManager

protocol StreamCreateControllerDelegate {
    func updatedData()
    func updatedImage(image : UIImage!)
    func updatedPlaylist(playlist : SynncPlaylist!)
}

class StreamCreateController : NSObject {
    
    var delegate : StreamCreateControllerDelegate?
    var playlist : SynncPlaylist!
    var stream : Stream?
    var tempStream : Stream!
    
    var selectedImage : UIImage!
    var imagePicker : SynncImagePicker!
    var parentController : ASViewController?
    var streamName : String!
    
    var backgroundNode : StreamCreateBackgroundNode!
    var contentNode : ASDisplayNode! {
        get {
            return playlistSelector.screenNode
        }
    }
    
    var playlistSelector : PlaylistSelectorController = PlaylistSelectorController()
    
    override init(){
        super.init()
        self.backgroundNode = StreamCreateBackgroundNode()
        self.playlistSelector.delegate = self
        
        self.backgroundNode.imageNode.userInteractionEnabled = true
        self.backgroundNode.imageNode.enabled = true
        self.backgroundNode.imageNode.addTarget(self, action: Selector("imageSelector:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.backgroundNode.startStreamButton.addTarget(self, action: Selector("createStreamAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.backgroundNode.locationToggle.addTarget(self, action: Selector("toggleLocation:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        self.backgroundNode.streamTitle.delegate = self
        
        self.tempStream = Stream(user: Synnc.sharedInstance.user)
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
                    i in
                    if let img = i {
                        self.selectedImage = img
                        self.delegate?.updatedData()
                    }
                }
            }
        }
        self.parentController?.presentViewController(imagePicker, animated: true) {}
    }
    func toggleLocation(sender : ButtonNode) {
        print("Toggle location")
        
        let managerStatus = WCLLocationManager.sharedInstance().locationMngrStatus
        switch managerStatus {
        case -1:
            
            let s = Synnc.sharedInstance
            let controller = s.locationAuthController()
            controller.callback = {
                success in
                sender.selected = success
            }
            s.locationManager.requestLocationPermission(controller)
            
            break
        case 0:
            
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Please go to iOS settings and enable location support for Synnc.", title: "Location Error", sound: nil, fireDate: nil, showLocalNotification: false, object: nil, id: nil))
            }
            return
            
        case 1 :
            
            sender.selected = !sender.selected
            
            break
        default :
            return
        }
    }
    
    func createStreamAction(sender : ButtonNode) {
        if self.streamName == nil {
            self.backgroundNode.streamTitle.becomeFirstResponder()
            return
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
                } else {
                    //                    if let url = successResult["secure_url"] as? String, let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                    //
                    //                        let id = "image/upload/v\(v)/\(publicId).\(format)"
                    //
                    //                    }
                }
                
                }, andProgress: nil)
            
        } else {
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
            info["lat"] = 0
            info["lon"] = 0
            tempStream.update(info)
            Synnc.sharedInstance.streamManager.userStream = tempStream
            
            print("create stream directly")
        }
    }
}

extension StreamCreateController : PlaylistSelectorDelegate {
    func didSelectPlaylist(playlist: SynncPlaylist) {
        self.playlist = playlist
        self.delegate?.updatedData()
    }
}

extension StreamCreateController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
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