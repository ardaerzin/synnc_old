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
//    var node : OnboardingVCNode!
  
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
        (node as! OnboardingVCNode).pageControl.addTarget(self, action: Selector("didSelectPageControl:"), forControlEvents: .ValueChanged)
        (node as! OnboardingVCNode).pager.setDataSource(self)
        (node as! OnboardingVCNode).pager.view.asyncDelegate = self
        (node as! OnboardingVCNode).getStartedButton.addTarget(self, action: Selector("proceedToLogin:"), forControlEvents: .TouchUpInside)
    }
    
    func proceedToLogin(sender : ButtonNode) {
        if let ivc = self.parentViewController as? InitialViewController {
            ivc.state = .Login
            WildDataManager.sharedInstance().updateUserDefaultsValue("seenOnboarding", value: true)
            
            AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Get Started", value: nil)
        }
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
        
        let a = (node as! OnboardingVCNode).pageControl.currentPage
        
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
            return OnboardingPage(item: self.pages[index])
        }
    }
}


class OnboardingVCNode : ASDisplayNode, TrackedView {
    
    var title : String! = "OnboardingView"
    
    var displayAnimationProgress : CGFloat = 1 {
        didSet {
            
            POPLayerSetScaleXY(self.pagerHolder.layer, CGPointMake(displayAnimationProgress,displayAnimationProgress))
            let holderTranslation = self.calculatedSize.height + self.pagerHolder.calculatedSize.height / 2 - self.pagerHolder.position.y
            POPLayerSetTranslationY(self.pagerHolder.layer, holderTranslation * (1-displayAnimationProgress))
            
            let buttonTranslation = self.calculatedSize.height + self.getStartedButton.calculatedSize.height / 2 - self.getStartedButton.position.y
            POPLayerSetTranslationY(self.getStartedButton.layer, buttonTranslation * (1-displayAnimationProgress))
            
        }
    }
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("hideAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! OnboardingVCNode).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! OnboardingVCNode).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var hideAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("hideAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("spinStateAnimation")
                }
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "spinStateAnimation")
                return x
            }
        }
    }
    
    var pagerHolder : PagerHolder!
    var getStartedButton : ButtonNode!
    var pageControlHolder : ASDisplayNode!
    var pager : OnboardingPager {
        get {
            return self.pagerHolder.pager
        }
    }
    var pageControl : UIPageControl {
        get {
            return self.pagerHolder.pageControl
        }
    }

    override init() {
        super.init()
       
        pagerHolder = PagerHolder()
        
        getStartedButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        getStartedButton.contentEdgeInsets = UIEdgeInsetsMake(15, 25, 15, 25)
        getStartedButton.cornerRadius = 6
        getStartedButton.minScale = 0.9
        getStartedButton.setAttributedTitle(NSAttributedString(string: "GET STARTED", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 18)!, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: .Normal)
        
        self.backgroundColor = .clearColor()
        
        self.addSubnode(pagerHolder)
        self.addSubnode(getStartedButton)
    }

    override func layout() {
        super.layout()
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let cardHolder = ASStaticLayoutSpec(children: [pagerHolder])
        pagerHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width * 0.8), ASRelativeDimension(type: .Points, value: constrainedSize.max.height * 0.7))
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        let topSpacer = ASLayoutSpec()
        topSpacer.flexGrow = true
        
        let bottomSpacer = ASLayoutSpec()
        bottomSpacer.flexGrow = true
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 40, justifyContent: .Center, alignItems: .Center, children: [topSpacer, spacer, cardHolder, getStartedButton, bottomSpacer])
    }
    
}

class PagerHolder : ASDisplayNode {
    var pager : OnboardingPager!
    var pageControl : UIPageControl!
    
    override init(){
        super.init()
        
        let layout = ASPagerFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        pager = OnboardingPager(collectionViewLayout: layout)
        pager.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        
        pageControl = UIPageControl()
        pageControl.defersCurrentPageDisplay = true
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        
        self.addSubnode(pager)
        self.view.addSubview(pageControl)
    }
    
    override func layout() {
        super.layout()
        
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        
        pageControl.frame = CGRect(x: self.calculatedSize.width / 2 - size.width / 2, y: self.calculatedSize.height - size.height - 10, width: size.width, height: size.height)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStaticLayoutSpec(children: [pager])
    }
}

class OnboardingPager : ASPagerNode {
    
    var shit : ASDisplayNode!
    
    override init(viewBlock: ASDisplayNodeViewBlock, didLoadBlock: ASDisplayNodeDidLoadBlock?) {
        super.init(viewBlock: viewBlock, didLoadBlock: didLoadBlock)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, layoutFacilitator: ASCollectionViewLayoutFacilitatorProtocol?) {
        super.init(frame: frame, collectionViewLayout: layout, layoutFacilitator: layoutFacilitator)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    override init!(collectionViewLayout flowLayout: ASPagerFlowLayout!) {
        super.init(collectionViewLayout: flowLayout)
        
        self.cornerRadius = 10
        
//        shit = ASDisplayNode()
//        shit.backgroundColor = .redColor()
//        shit.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(50,50))
//        
//        self.addSubnode(shit)
    }

    override func didLoad() {
        super.didLoad()
        
        let a = ASRangeTuningParameters(leadingBufferScreenfuls: 1, trailingBufferScreenfuls: 1)
        self.setTuningParameters(a, forRangeMode: .Full, rangeType: ASLayoutRangeType.FetchData)
    }
}


class OnboardingPage : ASCellNode {
    
    var titleNode : ASTextNode!
    var titleAttributes : [String : AnyObject] {
        get {
            let paragraphAtrributes = NSMutableParagraphStyle()
            paragraphAtrributes.alignment = .Center
            return [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.blackColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]
        }
    }
    var item : OnboardingItem!
    
    override func fetchData() {
        super.fetchData()
        titleNode.attributedString = NSAttributedString(string: item.title, attributes: titleAttributes)
        self.setNeedsLayout()
    }
    init(item : OnboardingItem) {
        super.init()
        self.item = item
        titleNode = ASTextNode()
        
        self.addSubnode(titleNode)
        
        self.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [titleNode])
    }
}