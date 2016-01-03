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
    init(){
        let a = ASDisplayNode()
        super.init(node: a)
        a.backgroundColor = UIColor.whiteColor()
        self.screenNode = a
    }
    override init!(node: ASDisplayNode!) {
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
//        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
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
        if let nvc = self._navController, let vc = nvc.viewControllers.last where vc != self {
            return vc.prefersStatusBarHidden()
        }
        print(!statusBarDisplayed)
        return !statusBarDisplayed
    }
    internal var _subsections : [TabSubsectionController]!
        {
        didSet {
            if _subsections != nil {
                for section in _subsections {
                    self.addChildViewController(section)
                }
            }
        }
    }
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
    final var selectedIndex : Int = 0
    var titleAttributes : [String : AnyObject] = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 30)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : -0.15]
    var screenNode : ASDisplayNode!
    
    init(){
        let a = NavigationHolderNode()
        super.init(node: a)
        a.backgroundColor = UIColor.clearColor()
        self.screenNode = a
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override init!(node: ASDisplayNode!) {
        super.init(node: node)
        self.screenNode = node
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent != nil {
            if let nn = self.screenNode as? NavigationHolderNode {
                nn.scrollNode.delegate = self
                nn.headerNode.updateForItem(self)
                nn.scrollNode.updateForItem(self, controller : self)
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func willBecomeActiveTab(){
        
    }
}
extension TabItemController : TabbarContentScrollerDelegate {
    func didScrollToRatio(ratio: CGFloat) {
        if let nn = self.screenNode as? NavigationHolderNode {
            let subsection = nn.headerNode.subSectionArea
            if let min = subsection.minX {
                let a = POPTransition(ratio, startValue: subsection.minX, endValue: subsection.maxX)
                subsection.currentIndicatorPosition = a
            }
        }
    }
    func didChangeCurrentIndex(index: Int) {
        self.selectedIndex = index
        if let nn = self.screenNode as? NavigationHolderNode {
            nn.headerNode.subSectionArea.selectedSubsectionIndex = index
        }
    }
    func beganScrolling() {
        if let nn = self.screenNode as? NavigationHolderNode {
            nn.headerNode.subSectionArea.pop_removeAnimationForKey("indicatorPositionAnimation")
//                .subSectionArea.selectedSubsectionIndex = index
        }
//        self.headerNode.subSectionArea.pop_removeAnimationForKey("indicatorPositionAnimation")
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