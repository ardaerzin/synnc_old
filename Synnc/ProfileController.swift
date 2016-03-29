//
//  ProfileController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/20/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUserManager
import DKImagePickerController
import WCLUIKit
import pop
import WCLNotificationManager
import Cloudinary

class ProfileInputAccessoryNode : ASDisplayNode {
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    
    override init() {
        super.init()
        
        yesButton = ButtonNode()
        let a = NSAttributedString(string: "Save", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)])
        yesButton.setAttributedTitle(a, forState: .Normal)
        
        noButton = ButtonNode()
        let b = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)])
        noButton.setAttributedTitle(b, forState: .Normal)
        
        backgroundColor = .lightGrayColor()
        
        self.addSubnode(yesButton)
        self.addSubnode(noButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let stack = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [noButton, spacer, yesButton])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 40, 0, 40), child: stack)
    }
}

class ProfileController : ASViewController, PagerSubcontroller {
    
    var _inputAccessoryNode : ProfileInputAccessoryNode!
    override var inputAccessoryView : UIView! {
        get {
            
            if self.screenNode.profile.profileCard.usernameNode.isFirstResponder() {
                
                if _inputAccessoryNode == nil {
                    _inputAccessoryNode = ProfileInputAccessoryNode()
                    _inputAccessoryNode.yesButton.addTarget(self, action: #selector(ProfileController.saveUsername(_:)), forControlEvents: .TouchUpInside)
                    _inputAccessoryNode.noButton.addTarget(self, action: #selector(ProfileController.cancelUsername(_:)), forControlEvents: .TouchUpInside)
                }
                _inputAccessoryNode.frame = CGRectMake(0,0,self.view.frame.width,40)
                _inputAccessoryNode.measureWithSizeRange(ASSizeRangeMakeExactSize(CGSize(width: self.view.frame.width,height: 40)))
                return _inputAccessoryNode.view
            } else {
                return nil
            }
            
        }
    }
    
    lazy var _leftHeaderIcon : ASImageNode = {
        let x = ASImageNode()
        x.image = UIImage(named: "magnifier")
        x.contentMode = .Center
        return x
    }()
    var leftHeaderIcon : ASImageNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASImageNode! = {
        return nil
    }()
    var rightHeaderIcon : ASImageNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Profile", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)]
        }
    }
    
    var keyboardTranslation : CGFloat! = 0
    var imagePicker : DKImagePickerController!
    var screenNode : ProfileHolder!
    var editedImage : UIImage! {
        didSet {
            saveImage()
        }
    }
    
    var usernameTimeStamp : NSDate!
    var canSetUsername : Bool? {
        didSet {
            
        }
    }
    var editedUsername : String! {
        didSet {
            
            self.screenNode.profile.profileCard.ghostLabel.attributedString = NSMutableAttributedString(string: editedUsername, attributes: (self.screenNode.profile.profileCard.usernameNode.typingAttributes as [String : AnyObject]!))
            
            let size = self.screenNode.profile.profileCard.ghostLabel.measure(self.screenNode.profile.profileCard.usernameNode.calculatedSize)
            
            self.screenNode.profile.profileCard.usernameBorder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(size.width, 2))
            self.screenNode.profile.profileCard.usernameBorder.setNeedsLayout()

            let date = NSDate()
            usernameTimeStamp = date
            canSetUsername = nil

            Synnc.sharedInstance.socket.emitWithAck("user:check", editedUsername) (timeoutAfter: 0, callback: {
                (dataArr) in
                
                if date.compare(self.usernameTimeStamp) != NSComparisonResult.OrderedSame {
                    return
                }
                
                if let status = dataArr.first as? Bool where status || self.editedUsername == Synnc.sharedInstance.user.username {
                    self.screenNode.profile.profileCard.usernameBorder.backgroundColor = UIColor.greenColor()
                    self.canSetUsername = true
                } else {
                    self.screenNode.profile.profileCard.usernameBorder.backgroundColor = UIColor.redColor()
                    self.canSetUsername = false
                }
                
                self.screenNode.profile.profileCard.usernameNode.setNeedsLayout()
            })
        }
    }
    
    
    init(){
        let node = ProfileHolder()
        super.init(node: node)
        self.screenNode = node
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileController.userProfileInfoChanged(_:)), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
        
        self.screenNode.profile.profileCard.imageNode.addTarget(self, action: #selector(ProfileController.imageTapAction(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.profile.profileCard.usernameNode.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let u = Synnc.sharedInstance.user {
            self.screenNode.profile.profileCard.updateForUser(u)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    func keyboardWillChangeFrame(notification : NSNotification){
        
        let a = KeyboardAnimationInfo(dict: notification.userInfo!)
        
        var isDisplayed : Bool = false
        if CGRectGetMinY(a.finalFrame) - self.node.calculatedSize.height == 0 {
            isDisplayed = false
        } else {
            isDisplayed = true
        }
        let translation = CGRectGetHeight(a.finalFrame)
        
        self.keyboardTranslation = translation
        
        if isDisplayed && self.screenNode.profile.profileCard.usernameNode.isFirstResponder() {
            
            let shit = self.screenNode.profile.profileCard.usernameNode.view.convertRect(self.screenNode.profile.profileCard.usernameNode.view.frame, toView: self.navigationController!.view)

            let intersection = CGRectIntersection(shit, a.finalFrame)
            if intersection != CGRectZero {
                POPLayerSetTranslationY(self.screenNode.layer, -(intersection.height + 25))
            }
        } else {
            POPLayerSetTranslationY(self.screenNode.layer, 0)
        }
    }
    
    func userProfileInfoChanged(notification : NSNotification) {
        self.screenNode.profile.profileCard.updateForUser(Synnc.sharedInstance.user)
    }
    
    func imageTapAction(sender: ASImageNode) {
        
        AnalyticsEvent.new(category : "ui_action", action: "image_tap", label: "My Profile", value: nil)
        
        imagePicker = DKImagePickerController()
        imagePicker.assetType = .AllPhotos
        imagePicker.showsEmptyAlbums = false
        imagePicker.showsCancelButton = true
        imagePicker.singleSelect = true
        
        imagePicker.didCancel = {
            if let pvc = self.parentViewController as? RootWindowController {
                pvc.toggleFeed(true)
            }
        }
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
                
                img.fetchOriginalImageWithCompleteBlock {
                    image, info in
                    if let i = image {
                        self.editedImage = i
                        self.screenNode.profile.profileCard.imageNode.image = i
                    }
                }
            }
            if let pvc = self.parentViewController as? RootWindowController {
                pvc.toggleFeed(true)
            }
        }
        
        self.navigationController?.presentViewController(imagePicker, animated: true) {}
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.toggleFeed(false)
        }
    }
}

extension ProfileController : ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {
        if let str = editableTextNode.attributedText?.string {
            self.editedUsername = str
        }
    }
    func editableTextNodeDidBeginEditing(editableTextNode: ASEditableTextNode) {
        
        AnalyticsEvent.new(category : "ui_action", action: "text_tap", label: "My Username", value: nil)
        
        if self.screenNode.profile.profileCard.usernameBorder.calculatedSize == CGSizeZero {
            self.screenNode.profile.profileCard.usernameBorder.setNeedsLayout()
            let size = self.screenNode.profile.profileCard.ghostLabel.measure(self.screenNode.profile.profileCard.usernameNode.calculatedSize)
            
            self.screenNode.profile.profileCard.usernameBorder.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(size.width, 2))
            self.screenNode.profile.profileCard.usernameBorder.setNeedsLayout()
        }
        
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.screenNode.pager.view.scrollEnabled = false
        }
        
        self.screenNode.profile.profileCard.displayUsernameBorder()
    }
    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
        self.screenNode.profile.profileCard.hideUsernameBorder()
        
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.screenNode.pager.view.scrollEnabled = true
        }
    }
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let _ = text.rangeOfString("\n") {
            return false
        }
        return true
    }
}

extension ProfileController {
    func saveImage(){
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
    
    func saveUsername(sender : ButtonNode) {
        if let newUsername = self.editedUsername, let x = canSetUsername where x {
            Synnc.sharedInstance.socket.emitWithAck("user:check", newUsername) (timeoutAfter: 0, callback: {
                (dataArr) in
                
                if let status = dataArr.first as? Bool where status {
                    Synnc.sharedInstance.socket!.emit("user:update", [ "id" : Synnc.sharedInstance.user._id, "username" : newUsername])
                } else {
                    if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                        WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Can't set this username. Please type another one.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                    }
                    
                    self.screenNode.profile.profileCard.usernameNode.attributedText = NSAttributedString(string: Synnc.sharedInstance.user.username, attributes: self.screenNode.profile.profileCard.usernameNode.typingAttributes)
                }
            })
        }
        self.screenNode.profile.profileCard.usernameNode.resignFirstResponder()
    }
    func cancelUsername(sender : ButtonNode) {
        self.screenNode.profile.profileCard.usernameNode.resignFirstResponder()
        self.screenNode.profile.profileCard.usernameNode.attributedText = NSAttributedString(string: Synnc.sharedInstance.user.username, attributes: self.screenNode.profile.profileCard.usernameNode.typingAttributes)
    }
}