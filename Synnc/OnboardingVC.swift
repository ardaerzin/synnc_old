//
//  OnboardingVC.swift
//  Synnc
//
//  Created by Arda Erzin on 2/27/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop

struct OnboardingItem {
    var title : String = "Title"
    var mainText : String = "Description"
}

class OnboardingVC : ASViewController {
  
    var currentIndex : Int = 0
    var pages : [OnboardingItem] = [
        OnboardingItem(title: "Onboarding 1", mainText: "wadap"),
        OnboardingItem(title: "Onboarding 2", mainText: "wadap"),
        OnboardingItem(title: "Onboarding 3", mainText: "wadap"),
        OnboardingItem(title: "Onboarding 4", mainText: "wadap"),
        OnboardingItem(title: "Onboarding 5", mainText: "wadap")
    ]
    
    init(){
        let node = OnboardingVCNode()
        super.init(node: node)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (node as! OnboardingVCNode).pageControl.addTarget(self, action: #selector(OnboardingVC.didSelectPageControl(_:)), forControlEvents: .ValueChanged)
        (node as! OnboardingVCNode).pager.setDataSource(self)
        (node as! OnboardingVCNode).pager.view.asyncDelegate = self
    }
    func didSelectPageControl(sender: UIPageControl) {
        
        let ind = sender.currentPage
        
        if ind >= 0 && ind < self.pages.count {
            AnalyticsEvent.new(category : "ui_action", action: "pager_tap", label: "onboardingPager", value: nil)
            (node as! OnboardingVCNode).pager.scrollToPageAtIndex(ind, animated: true)
        }
    }
}

extension OnboardingVC : ASCollectionDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cp = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        AnalyticsEvent.new(category : "ui_action", action: "pan", label: "onboarding", value: nil)
        
        (node as! OnboardingVCNode).pageControl.currentPage = cp
        currentIndex = cp
        (node as! OnboardingVCNode).pageControl.updateCurrentPageDisplay()
    }
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        let cp = Int(scrollView.contentOffset.x / scrollView.frame.width)
        currentIndex = cp
        
        (node as! OnboardingVCNode).pageControl.updateCurrentPageDisplay()
        
    }
}
extension OnboardingVC : ASPagerNodeDataSource {
    func numberOfPagesInPagerNode(pagerNode: ASPagerNode!) -> Int {
        
        let count = pages.count
        (node as! OnboardingVCNode).pageControl.numberOfPages = count
        
        return count
    }
    func pagerNode(pagerNode: ASPagerNode!, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath!) -> ASSizeRange {
        return ASSizeRangeMake(pagerNode.calculatedSize, pagerNode.calculatedSize)
    }
    func pagerNode(pagerNode: ASPagerNode!, nodeBlockAtIndex index: Int) -> ASCellNodeBlock! {
        return {
            return OnboardingItemPage(item: self.pages[index])
        }
    }
}