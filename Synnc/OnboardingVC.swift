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
    var imageName : String = "yo"
}

class OnboardingVC : ASViewController {
  
    var currentIndex : Int = 0
    var pages : [OnboardingItem] = [
        OnboardingItem(title: "LISTEN", mainText: "Connect to streams that resonate with you.", imageName: "earPlugs"),
        OnboardingItem(title: "STREAM", mainText: "Create and stream your own playlists, enhance your musical insight", imageName: "equalizer"),
        OnboardingItem(title: "SHARE", mainText: "Synnc is a social platform. Follow, get notified, listen and discover new streamers", imageName: "cable")
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
        
        (node as! OnboardingVCNode).stateAnimationProgress = 0
        (node as! OnboardingVCNode).pager.setDataSource(self)
        (node as! OnboardingVCNode).pager.view.asyncDelegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (node as! OnboardingVCNode).stateAnimation.toValue = 1
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
            return OnboardingPageItem(item: self.pages[index])
        }
    }
}