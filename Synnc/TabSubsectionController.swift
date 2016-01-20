//
//  TabSubsectionController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/20/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import SpinKit
import WCLUserManager

class TabSubsectionController : ASViewController {
    
    var screenNode : ASDisplayNode!
    internal var _title : String! {
        get {
            return "Subsection"
        }
    }
    override var title : String! {
        get {
            return _title
        }
        set {
        }
    }
    
    internal var _publicIdentifier : String! {
        get {
            return "Subsection"
        }
    }
    var publicIdentifier : String! {
        get {
            return _publicIdentifier
        }
    }
    
    init(){
        let a = ControllerNotAvailableNode()
        super.init(node: a)
        a.controllerName = self.publicIdentifier
        self.screenNode = a
    }
    override init(node: ASDisplayNode) {
        super.init(node: node)
        self.screenNode = node
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}