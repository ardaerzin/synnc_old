//
//  SettingsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/28/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import BFPaperCheckbox
import pop
import SafariServices
import WCLNotificationManager
import WCLPopupManager
import SwiftyJSON
import WCLUtilities

class SettingsInputAccessoryNode : ASDisplayNode {
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    
    override init() {
        super.init()
        
        yesButton = ButtonNode()
        let a = NSAttributedString(string: "Send", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 140/255, green: 185/255, blue: 189/255, alpha: 1)])
        yesButton.setAttributedTitle(a, forState: .Normal)
        
        noButton = ButtonNode()
        let b = NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 140/255, green: 185/255, blue: 189/255, alpha: 1)])
        noButton.setAttributedTitle(b, forState: .Normal)
        
        backgroundColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)
        
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

class SettingsController : ASViewController, PagerSubcontroller {
    
    var _inputAccessoryNode : SettingsInputAccessoryNode!
    override var inputAccessoryView : UIView! {
        get {
            
            if self.screenNode.settingsNode.feedbackNode.feedbackArea.isFirstResponder() {
                
                if _inputAccessoryNode == nil {
                    _inputAccessoryNode = SettingsInputAccessoryNode()
                    _inputAccessoryNode.yesButton.addTarget(self, action: #selector(SettingsController.sendFeedback(_:)), forControlEvents: .TouchUpInside)
                    _inputAccessoryNode.noButton.addTarget(self, action: #selector(SettingsController.cancelFeedback(_:)), forControlEvents: .TouchUpInside)
                }
                
                _inputAccessoryNode.frame = CGRectMake(0,0,self.view.frame.width,40)
                _inputAccessoryNode.measureWithSizeRange(ASSizeRangeMakeExactSize(CGSize(width: self.view.frame.width,height: 40)))
                return _inputAccessoryNode.view
            } else {
                return nil
            }
            
        }
    }
    
    lazy var _leftHeaderIcon : ASControlNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "magnifier")
        x.contentMode = .Center
        return nil
    }()
    var leftHeaderIcon : ASControlNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASControlNode! = {
        return nil
    }()
    var rightHeaderIcon : ASControlNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Settings", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5])
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
    
    
    var screenNode : SettingsHolder!
    var keyboardTranslation : CGFloat! = 0
    
    init(){
        let node = SettingsHolder()
        super.init(node: node)
        
        self.screenNode = node
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenNode.settingsNode.aboutNode.infoButton.addTarget(self, action: #selector(SettingsController.infoButtonAction(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.settingsNode.aboutNode.termsAndConditionsButton.addTarget(self, action: #selector(SettingsController.termsButtonAction(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.settingsNode.aboutNode.librariesButton.addTarget(self, action: #selector(SettingsController.librariesButtonAction(_:)), forControlEvents: .TouchUpInside)
        
        self.screenNode.settingsNode.feedbackNode.feedbackArea.delegate = self
        
        self.screenNode.settingsNode.loginSourcesNode.youtubeButton.addTarget(self, action: #selector(SettingsController.toggleSocialLogin(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.settingsNode.loginSourcesNode.spotifyButton.addTarget(self, action: #selector(SettingsController.toggleSocialLogin(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.settingsNode.loginSourcesNode.scButton.addTarget(self, action: #selector(SettingsController.toggleSocialLogin(_:)), forControlEvents: .TouchUpInside)
        
        self.screenNode.settingsNode.disconnectButton.addTarget(self, action: #selector(SettingsController.disconnect(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
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
        
        if isDisplayed && self.screenNode.settingsNode.feedbackNode.feedbackArea.isFirstResponder() {
            POPLayerSetTranslationY(self.screenNode.layer, -translation)
        } else {
            POPLayerSetTranslationY(self.screenNode.layer, 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsController {
    func infoButtonAction(sender: ButtonNode) {
        self.openURL("https://synnc.live")
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "About Us", value: nil)
    }
    func termsButtonAction(sender: ButtonNode) {
        self.openURL("https://synnc.live/terms")
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Terms", value: nil)
    }
    func librariesButtonAction(sender: ButtonNode) {
        self.openURL("https://synnc.live/libraries")
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Libraries", value: nil)
    }
    func openURL(string: String) {
        if let url = NSURL(string: string) {
            let x = SFSafariViewController(URL: url)
            x.modalPresentationStyle = .OverCurrentContext
            x.delegate = self
            self.presentViewController(x, animated: true, completion: {
                completed in
                
                AnalyticsManager.sharedInstance.newScreen("settingsWebview")
            })
            
            if let pvc = self.parentViewController as? RootWindowController {
                pvc.toggleFeed(false)
            }
        }
    }
    
    func toggleSocialLogin(sender: SourceLoginButtonNode) {
        
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: sender.source.rawValue + " Login", value: nil)
        
        if sender.source == .Soundcloud {
            toggleSoundcloudLogin(sender)
        } else {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                
                let info = WCLNotificationInfo(defaultActionName: "", body: "\(sender.source.rawValue) Login is not available yet.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil)
                WCLNotificationManager.sharedInstance().newNotification(a, info: info)
            }
        }
    }
    
    func toggleSoundcloudLogin(sender : SourceButton) {
        if !sender.selected {
            if let u = Synnc.sharedInstance.user.soundcloud {
                let rect = CGRectInset(UIScreen.mainScreen().bounds, 25, 100)
                u.setLoginViewController(SynncSCLoginController(size: rect.size))
            }
            Synnc.sharedInstance.user.socialLogin(.Soundcloud)
        } else {
            Synnc.sharedInstance.user.socialLogout(.Soundcloud)
        }
        
    }
    
    func disconnect(sender : ButtonNode) {
        print("disconnect now")
        
        let x = LogoutPopup(size: CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200))
        WCLPopupManager.sharedInstance.newPopup(x)
        
//        Synnc.sharedInstance.user.socialLogout(.Facebook)

        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Disconnect", value: nil)
    }
}

extension SettingsController {
    func sendFeedback(sender : ButtonNode) {
        self.screenNode.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
        AnalyticsEvent.new(category: "ui_action", action: "button_tap", label: "sendFeedback", value: nil)
        
        if let feedbackMsg = self.screenNode.settingsNode.feedbackNode.feedbackArea.attributedText?.string {
            
            self.screenNode.settingsNode.feedbackNode.feedbackArea.attributedText = NSAttributedString(string: "")
            editableTextNodeDidUpdateText(self.screenNode.settingsNode.feedbackNode.feedbackArea)
            
            var dict : [String : AnyObject] = [String : AnyObject]()
            dict["user"] = Synnc.sharedInstance.user._id
            dict["version"] = Synnc.sharedInstance.version
            dict["timestamp"] = NSDate().timeIntervalSince1970
            dict["feedback"] = feedbackMsg
            
            Synnc.sharedInstance.socket.emitWithAck("Feedback:create", dict)(timeoutAfter: 0, callback: {
                (dataArr) in
                if let status = dataArr.first, let stat = JSON(status).bool where stat {
                    Async.main {
                        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                            WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "We're on it! Thank you very much for your feedback.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                        }
                    }
                }
            })
        }
    }
    func cancelFeedback(sender : ButtonNode) {
        self.screenNode.settingsNode.feedbackNode.feedbackArea.resignFirstResponder()
        AnalyticsEvent.new(category: "ui_action", action: "button_tap", label: "cancelFeedback", value: nil)
    }
}

extension SettingsController : ASEditableTextNodeDelegate {
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {

        self.screenNode.settingsNode.feedbackNode.feedbackArea.measureWithSizeRange(ASSizeRangeMake(CGSizeMake(editableTextNode.calculatedSize.width, 100), CGSizeMake(editableTextNode.calculatedSize.width, CGFloat.max)))
        self.screenNode.settingsNode.feedbackNode.setNeedsLayout()
        
        let y = 65 + 20 + self.screenNode.settingsNode.disconnectButton.calculatedSize.height
        self.screenNode.settingsNode.view.setContentOffset(CGPointMake(0, max(0,(self.screenNode.settingsNode.view.contentSize.height - y) - self.screenNode.calculatedSize.height)), animated: false)
    }
    func editableTextNodeDidBeginEditing(editableTextNode: ASEditableTextNode) {
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.screenNode.pager.view.scrollEnabled = false
        }
        
        let y = 65 + 20 + self.screenNode.settingsNode.disconnectButton.calculatedSize.height
        self.screenNode.settingsNode.view.setContentOffset(CGPointMake(0, max(0,(self.screenNode.settingsNode.view.contentSize.height - y) - self.screenNode.calculatedSize.height)), animated: true)
    }
    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.screenNode.pager.view.scrollEnabled = true
        }
        
        self.screenNode.settingsNode.view.setContentOffset(CGPointMake(0, max(0,(self.screenNode.settingsNode.view.contentSize.height - self.screenNode.settingsNode.view.bounds.height))), animated: true)
    }
}
extension SettingsController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        if let pvc = self.parentViewController as? RootWindowController {
            pvc.toggleFeed(true)
        }
    }
}