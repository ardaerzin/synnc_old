//
//  StreamVC.swift
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
import WCLUserManager
import WCLPopupManager
import DKImagePickerController
import AssetsLibrary
import Cloudinary
import Shimmer
import WCLNotificationManager

class StreamVC : PagerBaseController {
    
    var stream : Stream!
    
    lazy var infoController : StreamInfoController = {
        return StreamInfoController()
    }()
    lazy var tracklistController : StreamTracklistController = {
        return StreamTracklistController()
    }()
    override var subControllers : [ASViewController]! {
        get {
            if self.childViewControllers.indexOf(infoController) == nil {
                self.addChildViewController(infoController)
            }
            if self.childViewControllers.indexOf(tracklistController) == nil {
                self.addChildViewController(tracklistController)
            }
            return [infoController, tracklistController]
        }
    }
    
    init(stream : Stream?){
        let node = StreamVCNode()
        super.init(pagerNode: node)
        
//        node.streamButtonHolder.streamButton.addTarget(self, action: #selector(PlaylistController.streamPlaylist(_:)) , forControlEvents: .TouchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createdStream(){
        if StreamManager.canSetActiveStream(stream) {
            if stream == StreamManager.sharedInstance.userStream {
                StreamManager.setActiveStream(stream)
                StreamManager.playStream(stream)
            }
        }
        
        (self.screenNode as! StreamVCNode).imageHeader.imageId = stream.img as String
        (self.screenNode as! StreamVCNode).imageHeader.fetchData()
    }
}

extension StreamVC : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        
    }
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            AnalyticsScreen.new(node: self.currentScreen())
        }
    }
}