//
//  PagerBaseController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/22/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PagerBaseController : ASViewController {
    
    var screenNode : PagerBaseControllerNode!
    var currentIndex : Int = 0 {
        didSet {
            if currentIndex != oldValue {
                updatedCurrentIndex(currentIndex)
                AnalyticsScreen.new(node: self.currentScreen())
            }
        }
    }
    var subControllers : [ASViewController]! {
        get {
            return []
        }
    }
    
    init(pagerNode node: PagerBaseControllerNode) {
        super.init(node: node)
        self.screenNode = node
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenNode.pager.delegate = self
        screenNode.pager.setDataSource(self)
        
        var leftItems : [ASControlNode?] = []
        var rightItems : [ASControlNode?] = []
        var titleItems : [ASDisplayNode?] = []
        var pagerStyles : [[String : UIColor]?] = []
        for sub in subControllers {
            if let x = sub as? PagerSubcontroller {
                leftItems.append(x.leftHeaderIcon)
                rightItems.append(x.rightHeaderIcon)
                titleItems.append(x.titleItem)
                pagerStyles.append(x.pageControlStyle)
            }
        }
        
        screenNode.headerNode.leftButtonHolder.items = leftItems
        screenNode.headerNode.rightButtonHolder.items = rightItems
        screenNode.headerNode.titleHolder.items = titleItems
        screenNode.headerNode.pageControl.styles = pagerStyles
        
        screenNode.headerNode.delegate = self
        screenNode.headerNode.pageControl.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
    func currentScreen() -> TrackedView {
        return self.subControllers[self.currentIndex].node as! TrackedView
    }
    
    func updatedCurrentIndex(index : Int) {
    }
}

extension PagerBaseController : PageControlDelegate {
    func pageControl(control: PageControlNode, scrollToInd ind: Int) {
        self.screenNode.pager.scrollToPageAtIndex(ind, animated: true)
        
        AnalyticsEvent.new(category: "ui_action", action: "pagerIndicator_tap", label: self.getClassName(), value: nil)
    }
}

extension PagerBaseController : PagerHeaderDelegate {
    func pagerHeaderDidTapOnHeeader(header: PagerHeaderNode) {
        
    }
    func pagerHeader(header: PagerHeaderNode, didSelectPageControl direction: Int) {
        
    }
}

extension PagerBaseController : ASCollectionDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pagerPosition = scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.bounds.width)
        
        if pagerPosition.isFinite {
            self.updatedPagerPosition(pagerPosition)
        } else {
            self.updatedPagerPosition(0)
        }
    }
    
    func updatedPagerPosition(position : CGFloat) {
        self.screenNode.headerNode.update(position)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cp = Int(scrollView.contentOffset.x / scrollView.frame.width)
        screenNode.headerNode.pageControl.currentPage = cp
        currentIndex = cp
        screenNode.headerNode.pageControl.updateCurrentPageDisplay()
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let cp = Int(scrollView.contentOffset.x / scrollView.frame.width)
        screenNode.headerNode.pageControl.currentPage = cp
        currentIndex = cp
        screenNode.headerNode.pageControl.updateCurrentPageDisplay()
    }
}
extension PagerBaseController : ASPagerNodeDataSource {
    func numberOfPagesInPagerNode(pagerNode: ASPagerNode!) -> Int {
        
        let count = subControllers.count
        screenNode.headerNode.pageControl.numberOfPages = count
        
        self.scrollViewDidScroll(pagerNode.view)
        
        return count
    }
    func pagerNode(pagerNode: ASPagerNode!, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath!) -> ASSizeRange {
        return ASSizeRangeMake(pagerNode.calculatedSize, pagerNode.calculatedSize)
    }
    func pagerNode(pagerNode: ASPagerNode!, nodeBlockAtIndex index: Int) -> ASCellNodeBlock! {
        return {
            let node = ASCellNode(viewControllerBlock: { () -> UIViewController in
                return self.subControllers[index]
                }, didLoadBlock: nil)
            return node
        }
    }
}