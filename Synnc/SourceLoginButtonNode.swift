//
//  SourceButtonLoginNode.swift
//  Synnc
//
//  Created by Arda Erzin on 2/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit
import WCLUserManager

class SourceLoginButtonNode : SourceButton {
    
    override init(source: SynncExternalSource) {
        super.init(source: source)
        
        if let type = WCLUserLoginType(rawValue: source.rawValue.lowercaseString) {
            
            if let ext = Synnc.sharedInstance.user.userExtension(type) {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SourceLoginButtonNode.loginStatusChanged(_:)), name: "\(type.rawValue)LoginStatusChanged", object: ext)
                print(source)
                
                self.selected = ext.loginStatus == nil ? false : ext.loginStatus
            }
        }
    }
    func loginStatusChanged(notification: NSNotification){
        if let userExtension = notification.object as? WCLUserExtension {
            self.selected = userExtension.loginStatus
        }
    }
}