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
import Cloudinary
import WCLLocationManager
import WCLNotificationManager

class StreamViewController : ASViewController {
    
    var screenNode : StreamViewNode!
    var stream : Stream?
    var createController : StreamCreateController!
    
    init(stream : Stream?){
        let node = StreamViewNode()
        super.init(node: node)
        node.delegate = self
        self.stream = stream
        self.screenNode = node
        if self.stream == nil {
            
            createController = StreamCreateController()
            createController.parentController = self
            createController.delegate = self
            createController.contentNode.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
            
            node.updateForState(createController)
        }
        self.screenNode.mainScrollNode.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if let p = parent as? StreamNavigationController {
            p.panRecognizer.delegate = self
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.updateScrollSizes()
    }
    func updateScrollSizes(){
        let csh = (self.screenNode.mainScrollNode.parallaxContentNode.view as! UIScrollView).contentSize.height
        let totalCs = csh + self.screenNode.mainScrollNode.backgroundNode.calculatedSize.height
        if totalCs != self.screenNode.mainScrollNode.view.contentSize.height {
            self.screenNode.mainScrollNode.view.contentSize = CGSizeMake(self.view.frame.size.width, totalCs)
        }
    }
}
extension StreamViewController : ParallaxNodeDelegate {
    func imageForBackground() -> AnyObject? {
        if let s = self.stream {
            print("has stream")
        } else {
            if let cc = self.createController {
                if let img = cc.selectedImage {
                    return img
                } else if let plist = cc.playlist, let str = plist.cover_id {
                    let transformation = CLTransformation()
                    
                    transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                    transformation.crop = "fill"
                    
                    if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                        return url
                    }
                }
            }
        }
        return nil
    }
}
extension StreamViewController : StreamCreateControllerDelegate {
    func updatedImage(image: UIImage!) {
        
    }
    func updatedPlaylist(playlist: SynncPlaylist!) {
    }
    func updatedData() {
        self.screenNode.fetchData()
    }
}
extension StreamViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension StreamViewController : ParallaxContentScrollerDelegate {
    func scrollViewDidScroll(scroller: ParallaxContentScroller, position: CGFloat) {
        if let p = self.parentViewController as? StreamNavigationController where position <= -50 {
            if let s = scroller.view {
                s.programaticScrollEnabled = false
                scroller.view.panGestureRecognizer.enabled = false
                s.programaticScrollEnabled = true

                var animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
                scroller.view.pop_addAnimation(animation, forKey: "offsetAnim")
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
            }
        } else {
            scroller.view.panGestureRecognizer.enabled = true
        }
        
        self.screenNode.mainScrollNode.backgroundNode.updateScrollPositions(position)
    }
}
class StreamViewNode : ParallaxNode {
    init() {
        let bgNode = ParallaxBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: StreamContentNode())
    }
    
    func updateForState(createController : StreamCreateController?){
        if let vc = createController {
            self.mainScrollNode.backgroundNode.removeFromSupernode()
            self.mainScrollNode.parallaxContentNode.removeFromSupernode()
            
            self.mainScrollNode.backgroundNode = vc.backgroundNode
            self.mainScrollNode.parallaxContentNode = vc.contentNode
            self.mainScrollNode.setNeedsLayout()
        }
    }
}
class StreamContentNode : ASScrollNode {
    
}