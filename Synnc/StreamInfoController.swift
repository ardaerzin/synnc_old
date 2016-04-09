//
//  StreamInfoController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLPopupManager
import WCLLocationManager
import WCLNotificationManager
import Cloudinary
import DKImagePickerController
import WCLUserManager

class StreamInfoController : ASViewController, PagerSubcontroller {
    
    var stream : Stream? {
        get {
            if let parent = self.parentViewController as? StreamVC, let st = parent.stream {
                return st
            } else {
                return nil
            }
        }
    }
    
    lazy var _leftHeaderIcon : ASImageNode! = {
        return nil
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
        x.attributedString = NSAttributedString(string: "Stream Info", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return nil
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    var screenNode : StreamInfoHolder!
    var listenersController : StreamListenersController! = StreamListenersController()
    
    init(){
        let n = StreamInfoHolder(usersSection: listenersController.screenNode)
        super.init(node: n)
        self.screenNode = n
        
        self.addChildViewController(self.listenersController)
        self.screenNode.infoNode.view.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenNode.infoNode.topSection.joinButton.addTarget(self, action: #selector(StreamInfoController.joinStream(_:)), forControlEvents: .TouchUpInside)
        self.screenNode.infoNode.topSection.userArea.addTarget(self, action: #selector(StreamInfoController.tappedOnUserArea(_:)), forControlEvents: .TouchUpInside)
    }
    
    func tappedOnUserArea(sender : TappableUserArea) {
        self.displayUserPopup(sender.userId)
    }
    func displayUserPopup(userId : String) {
        if let user = WCLUserManager.sharedInstance.findUser(userId) {
            let size = CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200)
            let x = UserProfilePopup(size: size, user: user)
            WCLPopupManager.sharedInstance.newPopup(x)
        }
    }
    
    
    func joinStream(sender : AnyObject){
        
        if let pvc = self.parentViewController as? StreamVC {
            pvc.joinStream(sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(stream : Stream) {
        self.listenersController.update(stream)
        self.screenNode.infoNode.configure(stream)
    }
}

extension StreamInfoController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let pvc = self.parentViewController as?  StreamVC {
            pvc.updateScrollPosition(scrollView.contentOffset.y)
        }
        
        if let s = (self.screenNode).infoNode.view {
            if s.contentOffset.y  < -(self.node.calculatedSize.width - 100) {
                s.programaticScrollEnabled = false
                s.panGestureRecognizer.enabled = false
                s.programaticScrollEnabled = true
                
                let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
                s.pop_addAnimation(animation, forKey: "offsetAnim")
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
            } else {
                s.panGestureRecognizer.enabled = true
            }
        }
    }
}