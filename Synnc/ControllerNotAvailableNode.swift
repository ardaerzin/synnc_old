//
//  ControllerNotAvailableNode.swift
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

class EmptyVC : ASViewController {
    init(){
        let node = ControllerNotAvailableNode()
        super.init(node: node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ControllerNotAvailableNode : ASDisplayNode, TrackedView {
    var mainTextNode : ASTextNode!
    var subTextNode : ASTextNode!
    var controllerName : String! = "test" {
        didSet {
            self.title = controllerName
        }
    }
    var box : ASDisplayNode!
    var title : String! = "LoginView"
    
    override init() {
        super.init()
        
        mainTextNode = ASTextNode()
        mainTextNode.maximumNumberOfLines = 2
      
        self.addSubnode(mainTextNode)
    }
    override func willEnterHierarchy() {
        super.willEnterHierarchy()
        self.fetchData()
    }
    override func fetchData() {
        
        super.fetchData()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.lineHeightMultiple = 1.25
        
        mainTextNode.attributedString = NSAttributedString(string: "\"" + controllerName + "\" will be here soon...", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 15)!, NSForegroundColorAttributeName : UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1), NSKernAttributeName : -0.1, NSParagraphStyleAttributeName : paragraphStyle])
//        self.layoutSpecThatFits(ASSizeRange(min: UIScreen.mainScreen().bounds.size, max: UIScreen.mainScreen().bounds.size))
        
        setNeedsLayout()
        
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let shit = ASStaticLayoutSpec(children: [mainTextNode])
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .Default, child: shit)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 50, 0, 50), child: centerSpec)
    }
}