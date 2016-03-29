//
//  StreamTracklistController.swift
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

class StreamTracklistController : ASViewController, PagerSubcontroller {
    
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
        x.attributedString = NSAttributedString(string: "Track List", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    
    init(){
        let n = ASDisplayNode()
        super.init(node: n)
        //        self.screenNode = n
        //        n.infoNode.infoDelegate = self
        //        n.infoNode.titleNode.delegate = self
        //
        //        screenNode.infoNode.genreHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.displayGenrePicker(_:)))
        //        screenNode.infoNode.locationHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.toggleLocation(_:)))
        //        screenNode.infoNode.imageNode.addTarget(self, action: #selector(PlaylistInfoController.displayImagePicker(_:)), forControlEvents: .TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}