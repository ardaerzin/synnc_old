//
//  TabItem.swift
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
import WCLUserManager
//import Appsee

class TabNavigationController : UINavigationController, UINavigationControllerDelegate {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.setNavigationBarHidden(true, animated: false)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func loadView() {
        super.loadView()
        
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.delegate = self
    }
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("TO VC", toVC)
        
        if let tic = toVC as? TabItemController {
            tic.didBecomeActiveTab()
        } else if let avc = toVC as? ASViewController, let tv = avc.node as? TrackedView {
            AnalyticsScreen.new(node: tv)
        }
        
        switch operation {
        case .Push:
            if let vc = toVC as? WildAnimated {
                vc.animator.presenting = true
                if let rvc = self.rootViewController {
                    rvc.displayStatusBar = !toVC.prefersStatusBarHidden()
                }
                return vc.animator
            }
            break
        case .Pop:
            if let vc = fromVC as? WildAnimated {
                vc.animator.presenting = false
                if let rvc = self.rootViewController {
                    rvc.displayStatusBar = !toVC.prefersStatusBarHidden()
                }
                return vc.animator
            }
            break
        default:
            break
        }
        
        return nil
    }
}

class TabItemController : ASViewController, TabItem {
    
    var _navController : UINavigationController!
    var navController : UINavigationController! {
        get {
            if _navController == nil {
                _navController = TabNavigationController(rootViewController: self)
            }
            return _navController
        }
    }
    var identifier : String! {
        get {
            return "id"
        }
    }
    var imageName : String! {
        get {
            return "hey"
        }
    }
    
    var statusBarDisplayed : Bool = true
    override func prefersStatusBarHidden() -> Bool {
        var status : Bool = false
        if let nvc = self._navController, let vc = nvc.viewControllers.last where vc != self {
            status = vc.prefersStatusBarHidden()
        } else {
            status = !statusBarDisplayed
        }
        UIApplication.sharedApplication().statusBarHidden = status
        return status
    }
    internal var _subsections : [TabSubsectionController]!
    
    var subsections : [TabSubsectionController]! {
        get {
            return []
        }
    }
    internal var _titleItem : ASDisplayNode!
    var titleItem : ASDisplayNode! {
        get {
            return nil
        }
    }
    internal var _iconItem : ASDisplayNode!
    var iconItem : ASDisplayNode! {
        get {
            return nil
        }
    }
    var selectedIndex : Int = 0
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 30)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.15]
    var screenNode : ASDisplayNode!
    
    var isActive : Bool!
        {
        didSet {
            if let x = isActive where x {
                self.didBecomeActiveTab()
            }
        }
    }
    
    init(){
        let a = NavigationHolderNode()
        super.init(node: a)
        a.backgroundColor = UIColor.clearColor()
        self.screenNode = a
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override init(node: ASDisplayNode) {
        super.init(node: node)
        self.screenNode = node
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        Appsee.startScreen(NSStringFromClass(self.subsections[selectedIndex].classForCoder))
//        NSStringFromClass(self.subsections[selectedIndex].classForCoder)
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        if parent != nil {
            if let nn = self.screenNode as? NavigationHolderNode {
                nn.scrollNode.identifier = self.identifier
                nn.scrollNode.scrollerDelegate = self
                nn.scrollNode.setDataSource(self)
                nn.headerNode.updateForItem(self)
                nn.scrollNode.updateForItem(self, controller : self)
            }
        }
    }
    
    func didBecomeActiveTab(){
        trackViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func willBecomeActiveTab(){
        
    }
}
extension TabItemController : ASPagerNodeDataSource {
    func pagerNode(pagerNode: ASPagerNode!, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath!) -> ASSizeRange {
        return ASSizeRangeMake(pagerNode.calculatedSize, pagerNode.calculatedSize)
    }
    func pagerNode(pagerNode: ASPagerNode!, nodeBlockAtIndex index: Int) -> ASCellNodeBlock! {
        return {
            return ASCellNode(viewControllerBlock: { () -> UIViewController in
                
                let controller = self.subsections[index]
                if self.childViewControllers.indexOf(controller) == nil {
                    self.addChildViewController(controller)
                }
                
                return controller
            }, didLoadBlock: nil)
        }
    }
    func numberOfPagesInPagerNode(pagerNode: ASPagerNode!) -> Int {
        return self.subsections.count
    }
}
extension TabItemController : TabbarContentScrollerDelegate {
    func didScrollToRatio(ratio: CGFloat) {
        if let nn = self.screenNode as? NavigationHolderNode {
            let subsection = nn.headerNode.subSectionArea
            if let _ = subsection.minX {
                let a = POPTransition(ratio, startValue: subsection.minX, endValue: subsection.maxX)
                subsection.currentIndicatorPosition = a
            }
        }
    }
    func trackViews(){
        
        if let s = self.isActive where s {
            if self.subsections.count > self.selectedIndex {
                let x = self.subsections[self.selectedIndex]
                AnalyticsScreen.new(node: x.screenNode as! TrackedView)
            } else if let ss = self.screenNode as? TrackedView {
                AnalyticsScreen.new(node: ss)
            }
            
        }
    }
    func didChangeCurrentIndex(index: Int) {
        self.selectedIndex = index
        trackViews()
        if let nn = self.screenNode as? NavigationHolderNode {
            nn.headerNode.subSectionArea.selectedSubsectionIndex = index
        }
    }

    func beganScrolling() {
        if let nn = self.screenNode as? NavigationHolderNode {
            nn.headerNode.subSectionArea.pop_removeAnimationForKey("indicatorPositionAnimation")
        }
    }
}
@objc protocol TabItem {
    var identifier : String! {get}
    var imageName : String! {get}
    
    var titleItem : ASDisplayNode! {get}
    var iconItem : ASDisplayNode! {get}
    var subsections : [TabSubsectionController]! {get}
    var selectedIndex : Int {get set}
}