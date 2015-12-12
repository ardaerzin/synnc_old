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

class MeController : TabItemController {
    
    override var identifier : String! {
        return "MeController"
    }
    override var imageName : String! {
        return "user"
    }
    
    override var subsections : [TabSubsectionController]! {
        get {
            if _subsections == nil {
                _subsections = [MyProfileController(), InboxController(), AchievementsController()]
            }
            return _subsections
        }
    }
    override var titleItem : ASDisplayNode! {
        get {
            if _titleItem == nil {
                let item = ASTextNode()
                item.attributedString = NSAttributedString(string: "Me", attributes: self.titleAttributes)
                self._titleItem = item
            }
            return _titleItem
        }
    }
    override var iconItem : ASDisplayNode! {
        get {
            if _iconItem == nil {
                let item = ButtonNode(normalColor: UIColor.clearColor(), selectedColor: UIColor.clearColor())
                item.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(34, 34))
                item.setImage(UIImage(named: "settings"), forState: ASButtonStateNormal)
                _iconItem = item
            }
            return _iconItem
        }
    }
    
    init(){
        let node = ASDisplayNode()
        super.init(node: node)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("userProfileInfoChanged:"), name: "profileInfoChanged", object: Synnc.sharedInstance.user)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MeController {
    func userProfileInfoChanged(notification: NSNotification!) {
        if let tn = self.titleItem as? ASTextNode {
            tn.attributedString = NSAttributedString(string: Synnc.sharedInstance.user.name, attributes: self.titleAttributes)
            self.titleItem.setNeedsLayout()
        }
    }
}