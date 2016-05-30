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
    var leftHeaderIcon : ASControlNode! {get}
    var rightHeaderIcon : ASControlNode! {get}
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
            if self.childViewControllers.indexOf(feedController) == nil {
                self.addChildViewController(feedController)
            }
            if self.childViewControllers.indexOf(playlistsController) == nil {
                self.addChildViewController(playlistsController)
            }
            return [feedController, playlistsController]
        }
    }
    
    init(){
        let header = HomeHeader(backgroundColor: .SynncColor(), height: 60)
        let node = HomeNode(header: header, pager: nil)
        super.init(pagerNode: node)
        header.toggleButton.addTarget(self, action: #selector(HomeController.toggleWindowPosition(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeController.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
    }
    
    func toggleWindowPosition(sender : AnyObject) {
        
        var action : String = ""
        if let w = self.view.wclWindow {
            if w.position == .Displayed {
                w.hide(true)
                action = "close"
            } else {
                w.display(true)
                action = "display"
            }
        }
        
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "\(action) Home", value: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.feedController.leftHeaderIcon?.addTarget(self, action: #selector(HomeController.displaySearch(_:)), forControlEvents: .TouchUpInside)
        self.playlistsController.leftHeaderIcon?.addTarget(self, action: #selector(HomeController.displaySearch(_:)), forControlEvents: .TouchUpInside)
    }
    
    func displaySearch(sender : AnyObject) {
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Display Search", value: nil)
    }
    
    func checkActiveStream(notification : NSNotification) {
        if let window = self.screenNode.view.wclWindow {
            
            var lowerLimit : CGFloat = 0
            
            let hasActiveStream = (notification.object as? Stream) != nil
            if hasActiveStream {
                lowerLimit = UIScreen.mainScreen().bounds.height - 60 - 70
            } else {
                lowerLimit = UIScreen.mainScreen().bounds.height - 60
            }
            
            self.playlistsController.screenNode.tableNode.view.tableFooterView = UIView(frame: CGRectMake(0,0,1, hasActiveStream ? 75 : 0))
            self.feedController.screenNode.tableNode.view.tableFooterView = UIView(frame: CGRectMake(0,0,1, hasActiveStream ? 75 : 0))
            
            window.lowerPercentage = lowerLimit
            
            if window.position == WCLWindowPosition.LowerLinked {
                window.hide(true)
            }
        }
    }

    var needsToShowPlaylist : Bool = false
    
    func scrollAndCreatePlaylist(sender : AnyObject) {
        needsToShowPlaylist = true
        self.screenNode.pager.scrollToPageAtIndex(1, animated: true)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "New Playlist 2", value: nil)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        
        if self.currentIndex == 1 && needsToShowPlaylist {
            self.playlistsController.newPlaylistAction(self)
        }
        needsToShowPlaylist = false
    }
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        if self.currentIndex == 1 && needsToShowPlaylist {
            self.playlistsController.newPlaylistAction(self)
        }
        needsToShowPlaylist = false
    }
}
extension HomeController : WCLWindowDelegate {
    func wclWindow(window: WCLWindow, updatedTransitionProgress progress: CGFloat) {
        let x = 1-window.lowerPercentage
        let za = (1 - progress - x) / (1-x)
        
        (self.screenNode.headerNode as! HomeHeader).toggleButton.progress = za
        self.screenNode.headerNode.leftButtonHolder.alpha = za
        self.screenNode.headerNode.rightButtonHolder.alpha = za
        self.screenNode.headerNode.pageControl.alpha = za
        
        let z = POPTransition(za, startValue: 10, endValue: 0)
        POPLayerSetTranslationY(self.screenNode.headerNode.titleHolder.layer, z)
    }
    func wclWindow(window: WCLWindow, didDismiss animated: Bool) {
        print("did dismiss window")
    }
    func wclWindow(window: WCLWindow, updatedPosition position: WCLWindowPosition) {
        if position == .Displayed {
            self.feedController.node.userInteractionEnabled = true
            self.playlistsController.node.userInteractionEnabled = true
            
            AnalyticsScreen.new(node: self.currentScreen())
        }
        
        
    }
}

extension HomeController {
    override func pagerHeaderDidTapOnHeeader(header: PagerHeaderNode) {
        super.pagerHeaderDidTapOnHeeader(header)
        if let w = self.screenNode?.view.wclWindow, let pos = w.position {
            if pos == .LowerLinked {
                w.display(true)
            }
        }
    }
}