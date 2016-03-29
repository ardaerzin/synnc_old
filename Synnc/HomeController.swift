//
//  HomeController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUserManager
import WCLUIKit
import pop

protocol PagerSubcontroller {
    var leftHeaderIcon : ASImageNode! {get}
    var rightHeaderIcon : ASImageNode! {get}
    var titleItem : ASTextNode! {get}
    var pageControlStyle : [String : UIColor]? {get}
}

class HomeController : PagerBaseController {
    lazy var feedController : StreamsFeedController = {
        return StreamsFeedController()
    }()
    lazy var playlistsController : MyPlaylistsController = {
        return MyPlaylistsController()
    }()
    override var subControllers : [ASViewController]! {
        get {
            return [feedController, playlistsController]
        }
    }
    
    init(){
        let node = HomeNode()
        super.init(pagerNode: node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension HomeController : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        let x = 1-window.lowerPercentage
        let za = (1 - progress - x) / (1-x)
        
        self.screenNode.headerNode.leftButtonHolder.alpha = za
        self.screenNode.headerNode.rightButtonHolder.alpha = za
        self.screenNode.headerNode.pageControl.alpha = za
        
        let z = POPTransition(za, startValue: 10, endValue: 0)
        POPLayerSetTranslationY(self.screenNode.headerNode.titleHolder.layer, z)
    }
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
        
    }
}