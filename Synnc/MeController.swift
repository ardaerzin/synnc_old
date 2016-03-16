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
import WCLUserManager
import DKImagePickerController
import Cloudinary
import WCLNotificationManager

class MeController : TabItemController {
    
    
    var usernameTimeStamp : NSDate!
    var canSetUsername : Bool?
    var editedUsername : String! {
        didSet {
            
            (self.screenNode as! MeNode).ghostLabel.attributedString = NSMutableAttributedString(string: editedUsername, attributes: ((self.screenNode as! MeNode).usernameNode.typingAttributes as [String : AnyObject]!))
            
            
            let size = (self.screenNode as! MeNode).ghostLabel.measure((self.screenNode as! MeNode).usernameNode.calculatedSize)
            
            (self.screenNode as! MeNode).usernameBorder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(size.width, 2))
            (self.screenNode as! MeNode).usernameBorder.setNeedsLayout()
            
            let date = NSDate()
            usernameTimeStamp = date
            canSetUsername = nil
            
            Synnc.sharedInstance.socket.emitWithAck("user:check", editedUsername) (timeoutAfter: 0, callback: {
                (dataArr) in
                
                if date.compare(self.usernameTimeStamp) != NSComparisonResult.OrderedSame {
                    return
                }
                
                if let status = dataArr.first as? Bool where status || self.editedUsername == Synnc.sharedInstance.user.username {
                    (self.screenNode as! MeNode).usernameBorder.backgroundColor = UIColor.greenColor()
                    self.canSetUsername = true
                } else {
                    (self.screenNode as! MeNode).usernameBorder.backgroundColor = UIColor.redColor()
                    self.canSetUsername = false
                }
                
                (self.screenNode as! MeNode).usernameNode.setNeedsLayout()
            })
        }
    }
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
        node.settingsButton.addTarget(self, action: Selector("toggleSettings:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.usernameNode.delegate = self
        
        node.mainScrollNode.backgroundNode.imageSelector.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
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
                _popContentController.delegate = self
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
    func editableTextNodeDidBeginEditing(editableTextNode: ASEditableTextNode) {
        if (self.screenNode as! MeNode).usernameBorder.calculatedSize == CGSizeZero {
            (self.screenNode as! MeNode).usernameBorder.setNeedsLayout()
            let size = (self.screenNode as! MeNode).ghostLabel.measure((self.screenNode as! MeNode).usernameNode.calculatedSize)
            
            (self.screenNode as! MeNode).usernameBorder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(size.width, 2))
            (self.screenNode as! MeNode).usernameBorder.setNeedsLayout()
        }
        
        (self.screenNode as! MeNode).displayUsernameBorder()
    }
    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
        (self.screenNode as! MeNode).hideUsernameBorder()
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
            self.popContentController.hidePopover(self)
        }
        
        self.editing = !self.editing
        sender.selected = self.editing
    }
    func toggleSettings(sender : ButtonNode) {
        sender.selected = !sender.selected
        togglePopover(sender, contentController: self.settingsController)
    }
    
    func togglePopover(sender : ButtonNode, contentController : PopContentController!){
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
            
//            if !self.popContentController.displayed {
                self.addChildViewController(self.popContentController)
                self.popContentController.setContent(contentController)
                let x = contentController.screenNode.measureWithSizeRange(ASSizeRangeMake(CGSizeMake(self.view.frame.width, 0), CGSizeMake(self.view.frame.width, self.view.frame.height - 50 - 30)))
                
                self.popContentController.constrainedSize = ASSizeRangeMakeExactSize(CGSizeMake(self.view.frame.width, self.view.frame.height - 50 - 30))
            
        
                if self.popContentController.view.bounds.height != self.view.frame.height - 50 - 30 {
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
//            }
        } else {
            self.popContentController.hidePopover(nil)
        }
    }
}

extension MeController {
    func tryUserUpdate() {
        
        if let newUsername = self.editedUsername {
            
            if let unameRdy = canSetUsername where !unameRdy {
                if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                    WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Can't set this username. Please type another one.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                }
            } else {
                
                Synnc.sharedInstance.socket.emitWithAck("user:check", newUsername) (timeoutAfter: 0, callback: {
                    (dataArr) in
                
                    if let status = dataArr.first as? Bool where status {
                        Synnc.sharedInstance.socket!.emit("user:update", [ "id" : Synnc.sharedInstance.user._id, "username" : newUsername])
                    } else {
                        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Can't set this username. Please type another one.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                        }
                    }
                })
            }
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
    func imageForBackground() -> (image: AnyObject?, viewMode: UIViewContentMode?) {
        if let img = self.editedImage {
            return (image: img, viewMode: nil)
        } else {
            if let provider = Synnc.sharedInstance.user.provider, let type = WCLUserLoginType(rawValue: provider), let url = Synnc.sharedInstance.user.avatarURL(type, frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width), scale: UIScreen.mainScreen().scale) {
                return (image: url, viewMode: UIViewContentMode.ScaleAspectFill)
            }
        }
        return (image: nil, viewMode: nil)
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

extension MeController : PopControllerDelegate {
    func hidePopController() {
        selectedPopoverButton.selected = false
        self.togglePopover(self.selectedPopoverButton, contentController: nil)
        //        self.selectedPopoverButton.selected = false
        //        self.selectedPopoverButton = nil
    }
}