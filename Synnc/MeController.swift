//
//  MeController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/11/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager
import DeviceKit
import DKImagePickerController
import Cloudinary
import WCLNotificationManager

class MeController : TabItemController {
    
    var editedUsername : String!
    var editedImage : UIImage!
    
    var imagePicker : DKImagePickerController!
    override var identifier : String! {
        return "MeController"
    }
    override var imageName : String! {
        return "user"
    }
    override var editing : Bool {
        didSet {
            if editing != oldValue {
                
                if let meNode = self.screenNode as? MeNode {
                    meNode.editing = editing
                }
                
                if !editing {
                    tryUserUpdate()
                }
            }
        }
    }
    override init(){
        let node = MeNode(user: Synnc.sharedInstance.user)
        super.init(node: node)
        node.underTabbar = true
        node.delegate = self
        self.statusBarDisplayed = false
        node.headerNode.closeButton.alpha = 0
        node.headerNode.closeButton.enabled = false
        node.mainScrollNode.view.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 1500)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userProfileInfoChanged:"), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        
        node.editButton.addTarget(self, action: Selector("toggleEditMode:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.inboxButton.addTarget(self, action: Selector("toggleInbox:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.settingsButton.addTarget(self, action: Selector("toggleSettings:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.usernameNode.delegate = self
        
        node.mainScrollNode.backgroundNode.imageSelector.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
//        (node.mainScrollNode.backgroundNode as! PlaylistBackgroundNode).imageSelector.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    
    func imageTap(sender : ButtonNode){
        imagePicker = SynncImagePicker()
        imagePicker.assetType = .AllPhotos
        imagePicker.showsEmptyAlbums = false
        imagePicker.showsCancelButton = true
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
                
                img.fetchOriginalImageWithCompleteBlock {
                    image, info in
                    if let i = image {
                        self.editedImage = i
                        self.screenNode.fetchData()
                    }
                }
            }
            
            //            if let parent = self.parentViewController as? StreamViewController {
            (self.screenNode as! MeNode).mainScrollNode.scrollViewDidScroll((self.screenNode as! MeNode).mainScrollNode.view)
            //            }
        }
        self.parentViewController?.presentViewController(imagePicker, animated: true) {}
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenNode.backgroundColor = UIColor.whiteColor()
    }
    
    var _inboxController : InboxController!
    var inboxController : InboxController! {
        get {
            if _inboxController == nil {
                _inboxController = InboxController()
            }
            return _inboxController
        }
    }
    var _settingsController : SettingsController!
    var settingsController : SettingsController! {
        get {
            if _settingsController == nil {
                _settingsController = SettingsController(user: Synnc.sharedInstance.user)
            }
            return _settingsController
        }
    }
    var _popContentController : PopController!
    var popContentController : PopController! {
        get {
            if _popContentController == nil {
                _popContentController = PopController()
            }
            return _popContentController
        }
    }
    var selectedPopoverButton : ButtonNode!
    
}

extension MeController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            return false
        }
        return true
    }
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {
        let str = editableTextNode.textView.text
        self.editedUsername = str
    }
}

extension MeController {
    func toggleEditMode(sender : ButtonNode) {
        if let popover = self.selectedPopoverButton where popover.selected {
            popover.selected = !popover.selected
            self.hidePopover()
        }
        
        self.editing = !self.editing
        sender.selected = self.editing
    }
    func toggleSettings(sender : ButtonNode) {
        sender.selected = !sender.selected
        togglePopover(sender, contentController: self.settingsController)
    }
    func toggleInbox(sender : ButtonNode){
        sender.selected = !sender.selected
        togglePopover(sender, contentController: self.inboxController)
    }
    
    func togglePopover(sender : ButtonNode, contentController : PopContentController){
        if sender.selected {
            if let selected = selectedPopoverButton where selected != sender {
                selected.selected = false
            }
            self.selectedPopoverButton = sender
        } else {
            self.selectedPopoverButton = nil
        }
        self.popContentController.screenNode.arrowPosition = sender.position
        
        if sender.selected {
            
            if !self.popContentController.displayed {
                self.addChildViewController(self.popContentController)
                if self.popContentController.view.frame == CGRectZero {
                    self.popContentController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 50 - 30)
                }
                self.popContentController.screenNode.displayAnimation.completionBlock = {
                    anim, finished in
                    self.popContentController.screenNode.pop_removeAnimationForKey("displayAnimation")
                }
                self.screenNode.addSubnode(self.popContentController.screenNode)
                self.popContentController.didMoveToParentViewController(self)
                self.popContentController.screenNode.displayAnimation.toValue = 1
                self.popContentController.displayed = true
            }
            
            self.popContentController.setContent(contentController)
            
        } else {
            hidePopover()
        }
    }
    
    func hidePopover(){
        self.popContentController.screenNode.displayAnimation.completionBlock = {
            anim, finished in
            self.popContentController.willMoveToParentViewController(nil)
            self.popContentController.screenNode.removeFromSupernode()
            self.popContentController.removeFromParentViewController()
            self.popContentController.screenNode.pop_removeAnimationForKey("displayAnimation")
        }
        self.popContentController.screenNode.displayAnimation.toValue = 0
        self.popContentController.displayed = false
    }
}

extension MeController {
    func tryUserUpdate() {
        if let newUsername = self.editedUsername {
//            Synnc.sharedInstance.socket!.emit("user:update", [ "id" : Synnc.sharedInstance.user._id, "username" : newUsername])
        }
        
        if let newImage = self.editedImage {
            Synnc.sharedInstance.imageUploader = CLUploader(_cloudinary, delegate: nil)
            let data = UIImageJPEGRepresentation(newImage, 1)
            let a = CLTransformation()
            a.angle = "exif"
            Synnc.sharedInstance.imageUploader.upload(data, options: ["transformation" : a], withCompletion: {
                [weak self]
                
                (successResult, errorString, code, context)  in
                
                if let _ = errorString {
                    if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                        WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Please try to save your image once again", title: "Couldn't Upload Image", sound: nil, fireDate: nil, showLocalNotification: false, object: nil, id: nil))
                    }
                } else {
                    if let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                        
                        let id = "image/upload/v\(v)/\(publicId).\(format)"
                        self?.editedImage = nil
                        Synnc.sharedInstance.socket!.emit("user:update", [ "id" : Synnc.sharedInstance.user._id, "avatarId" : id])
                    }
                }
                
                }, andProgress: nil)
        }
    }
}

extension MeController : ParallaxNodeDelegate {
    func imageForBackground() -> AnyObject? {
        if let img = self.editedImage {
            return img
        } else {
            if let provider = Synnc.sharedInstance.user.provider, let type = WCLUserLoginType(rawValue: provider), let url = Synnc.sharedInstance.user.avatarURL(type, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width), scale: UIScreen.mainScreen().scale) {
                return url
            }
        }
        return nil
    }
    func gradientImageName() -> String? {
        return "imageGradient"
    }
    func headerButtons() -> [ButtonNode] {
        return []
    }
}

extension MeController {
    func userProfileInfoChanged(notification: NSNotification) {
            if let menode = self.screenNode as? MeNode {
                menode.updateForUser(Synnc.sharedInstance.user)
            }
        
    }
}