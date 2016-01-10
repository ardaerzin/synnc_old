//
//  StreamViewController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/31/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import WCLNotificationManager

class StreamNavigationController : UINavigationController {
    var initialTouchTopWindowPosition : CGFloat = 0
    var transitionProgress : CGFloat! = 0 {
        didSet {
            POPLayerSetTranslationY(self.view.layer, transitionProgress*self.view.bounds.height)
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    var animatableProperty : POPAnimatableProperty!  {
        get {
            let x = POPAnimatableProperty.propertyWithName("inc.stamp.pk.property.window.progress", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! StreamNavigationController).transitionProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! StreamNavigationController).transitionProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var animation : POPSpringAnimation!  {
        get {
            if let x = self.pop_animationForKey("inc.stamp.pk.window.progress") as? POPSpringAnimation {
                return x
            } else {
                let x = POPSpringAnimation()
                x.property = self.animatableProperty
                self.pop_addAnimation(x, forKey: "inc.stamp.pk.window.progress")
                return x
            }
        }
    }
    var windowBounds : CGRect!
    var tapRecognizer : UITapGestureRecognizer!
    var panRecognizer : UIPanGestureRecognizer!

    init(){
        super.init(nibName: nil, bundle: nil)
        panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanRecognizer:"))
        self.view.addGestureRecognizer(panRecognizer)
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationBarHidden = true
    }
    
    func displayMyStream() {
        if let us = Synnc.sharedInstance.streamManager.userStream {
            self.displayStream(us)
        } else {
            if SharedPlaylistDataSource.allItems.isEmpty {
                if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView, let rvc = Synnc.sharedInstance.window?.rootViewController as? RootViewController, let item = rvc.playlistsTab as? TabItem {
//                    where item.identifier != rvc.displayItem.identifier  {
                    WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "OpenTab", body: "Go ahead and create a playlist first", title: "No Playlists", sound: nil, fireDate: nil, showLocalNotification: false, object: item, id: nil))
                }
                return
            }
            self.pushViewController(StreamViewController(stream: nil), animated: false)
            self.display()
        }
    }
    
    func displayStream(stream : Stream){
        self.pushViewController(StreamViewController(stream: stream), animated: false)
        self.display()
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nil, bundle: nil)
//    }
//    init(){
//        panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanRecognizer:"))
//        self.view.addGestureRecognizer(panRecognizer)
//    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func handlePanRecognizer(recognizer: UIPanGestureRecognizer){
        switch (recognizer.state) {
            
        case UIGestureRecognizerState.Began:
            beginPan(recognizer)
        case UIGestureRecognizerState.Changed:
            updatePan(recognizer)
        default:
            endPan(recognizer)
            break
        }
        
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        if let p = parent {
            self.view.frame = UIScreen.mainScreen().bounds
        }
        
//        self.transitionProgress = 1
    }
    func beginPan(recognizer : UIPanGestureRecognizer){
        initialTouchTopWindowPosition = self.view.frame.origin.y
        self.pop_removeAnimationForKey("inc.stamp.pk.window.progress")
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        self.transitionProgress = 1
    }
    func updatePan(recognizer : UIPanGestureRecognizer){
        let translation = recognizer.translationInView(UIApplication.sharedApplication().windows.first!)
        
        let yPosition = translation.y
//            + initialTouchTopWindowPosition
        let x = yPosition / UIScreen.mainScreen().bounds.height
        
        var y = x
        
//        if x < 0 {
//            y = x/8
//        } else {
//        }
        self.transitionProgress = y
    }
    func endPan(recognizer : UIPanGestureRecognizer){
        
        let v = recognizer.velocityInView(UIApplication.sharedApplication().windows.first!).y / UIScreen.mainScreen().bounds.height
        if self.transitionProgress >  0.5 {
            
            if v < -2 {
                self.animation.velocity = v
                self.display()
            } else {
                self.animation.velocity = v
                self.hide()
            }
        } else {
            if v > 2 {
                self.animation.velocity = v
                self.hide()
            } else {
                self.animation.velocity = v
                self.display()
            }
            
        }
    }
    
    var statusbarDisplay : Bool = true
    func display(){
        self.animation.toValue = 0
        
        if let rvc = self.rootViewController {
            statusbarDisplay = rvc.displayStatusBar
            rvc.displayStatusBar = false
        }
        UIApplication.sharedApplication().statusBarHidden = true
    }
    func hide(){
        self.animation.toValue = 1
        if let rvc = self.rootViewController, let tabitem = rvc.displayItem as? TabItemController {
            rvc.displayStatusBar = !tabitem.prefersStatusBarHidden()
        }
        UIApplication.sharedApplication().statusBarHidden = false
    }
}