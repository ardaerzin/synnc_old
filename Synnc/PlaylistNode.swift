//
//  PlaylistNode.swift
//  Synnc
//
//  Created by Arda Erzin on 12/26/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import AsyncDisplayKit.ASDisplayNode_Subclasses
import pop
import SpinKit
import WCLUIKit
import Shimmer

class PlaylistNode : ParallaxNode, TrackedView {
    
    var title: String! = "PlaylistNode"
    var emptyStateNode : PlaylistEmptyNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = PlaylistEmptyNode()
                }
                if emptyState {
                    self.addSubnode(emptyStateNode)
                } else {
                    emptyStateNode.removeFromSupernode()
                    emptyStateNode = nil
                }
                self.emptyStateNode?.setNeedsLayout()
                self.setNeedsLayout()
            }
        }
    }
    
    var playlist : SynncPlaylist?
    
    var tracksTable : ASTableNode!
    var imageNode : ASNetworkImageNode! {
        get {
            return self.mainScrollNode.backgroundNode.imageNode
        }
    }
    var titleShimmer : FBShimmeringView!
    var playlistTitleNode : MyTextNode!
    var countTextNode : ASTextNode!

    var editing : Bool = false {
        didSet {
            if editing != oldValue {
//                self.playlistTitleNode.userInteractionEnabled = editing
//                self.titleShimmer.shimmeringHighlightLength = 0.7
//                self.titleShimmer.shimmeringPauseDuration = 0
//                
//                self.titleShimmer.shimmering = editing
                self.mainScrollNode.backgroundNode.editing = editing
            }
        }
    }
    
    
    var placeholderScrollAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("placeholderScrollAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PlaylistNode).placeholderScrollAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PlaylistNode).placeholderScrollAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var placeholderScrollAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("placeholderScrollAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("placeholderScrollAnimation")
                }
                x.springBounciness = 0
                x.dynamicsFriction = 20
                x.property = self.placeholderScrollAnimatableProperty
                self.pop_addAnimation(x, forKey: "placeholderScrollAnimation")
                return x
            }
        }
    }
    var placeholderAutoScrollAmount : CGFloat = 0
    var placeholderScrollAnimationProgress : CGFloat = 0 {
        didSet {
            let a = POPTransition(placeholderScrollAnimationProgress, startValue: 0, endValue: placeholderAutoScrollAmount)
            POPLayerSetTranslationY(self.placeholderView.layer, a)
        }
    }
    
    
    var placeholderStatusAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("placeholderStatusAnimatableProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PlaylistNode).placeholderStatusAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PlaylistNode).placeholderStatusAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var placeholderStatusAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("placeholderStatusAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("placeholderStatusAnimation")
                }
                x.springBounciness = 0
                x.dynamicsFriction = 20
                x.property = self.placeholderStatusAnimatableProperty
                self.pop_addAnimation(x, forKey: "placeholderStatusAnimation")
                return x
            }
        }
    }
    var placeholderStatusAnimationProgress : CGFloat = 0 {
        didSet {
            
            let a = POPTransition(placeholderStatusAnimationProgress, startValue: 1, endValue: 1.1)
            POPLayerSetScaleXY(self.placeholderView.layer, CGPointMake(a,a))
        }
    }
    
    var placeholderView : UIView! {
        didSet {
            if placeholderView != nil {
                placeholderStatusAnimation.completionBlock = {
                    anim, finished in
                    
                    self.pop_removeAnimationForKey("placeholderStatusAnimation")
                }
                placeholderStatusAnimation.toValue = 1
            }
        }
    }
    
    var movingIndexPath : NSIndexPath!
    var touchOriginY : CGFloat!
    var initialIndexPath : NSIndexPath!
    var autoscrollAmount : CGFloat!
    let AutoScrollingMinDistanceFromEdge : CGFloat = 60
    var timerToAutoscroll : CADisplayLink!
    var draggedCell : ASCellNode!
    
    
    lazy var addSongsButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "ADD SONGS", selectedTitleString: "ADD SONGS", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    lazy var streamButton : TitleColorButton = {
        var a = TitleColorButton(normalTitleString: "STREAM", selectedTitleString: "STOP STREAM", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!], normalColor: .whiteColor(), selectedColor: .SynncColor())
        return a
        }()
    
    var buttons : [ButtonNode] {
        get {
            return [addSongsButton, streamButton]
        }
    }
    var longPressGestureRecognizer : UILongPressGestureRecognizer!
    
    func updateTrackCount(){
        var countString : String = "0 Tracks"
        
        if let p = self.playlist {
            countString = "\(p.songs.count) Tracks"
        } else {
        }
        countTextNode.attributedString = NSAttributedString(string: countString, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.26)])
        self.setNeedsLayout()
    }
    override func fetchData() {
        super.fetchData()
        updateTrackCount()
    }
    init(playlist: SynncPlaylist?) {
        
        let table = ASTableNode(style: UITableViewStyle.Plain)
        table.alignSelf = .Stretch
        table.flexGrow = true
        table.view.separatorStyle = .None
        table.view.scrollEnabled = false
        table.clipsToBounds = true
        
        
        let bgNode = PlaylistBackgroundNode()
        super.init(backgroundNode: bgNode, contentNode: table)
        
        self.playlist = playlist
        
        self.headerNode.buttons = self.buttons
        self.tracksTable = table
        
        playlistTitleNode = MyTextNode()
        playlistTitleNode.layoutDelegate = self
        playlistTitleNode.returnKeyType = UIReturnKeyType.Done
        playlistTitleNode.attributedPlaceholderText = NSAttributedString(string: "New Playlist", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)])
        playlistTitleNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 26)!, NSForegroundColorAttributeName : UIColor.whiteColor().colorWithAlphaComponent(0.74)]
        
        if let title = self.playlist?.name {
            playlistTitleNode.attributedText = NSAttributedString(string: title, attributes: (self.playlistTitleNode.typingAttributes as [String : AnyObject]!))
        }
        countTextNode = ASTextNode()
     
        self.titleShimmer = FBShimmeringView()
        self.titleShimmer.contentView = self.playlistTitleNode.view
        
        self.imageNode.userInteractionEnabled = false
        self.imageNode.enabled = false

        
        self.view.addSubview(self.titleShimmer)
        self.addSubnode(countTextNode)
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPressRecognized:"))
        self.tracksTable.view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    override func didScroll(position: CGFloat) {
        super.didScroll(position)
        if let esn = self.emptyStateNode {
            POPLayerSetTranslationY(esn.layer, -position)
        }
    }
    
    
    override func layout() {
        super.layout()
        
        emptyStateNode?.position.y = self.mainScrollNode.backgroundNode.calculatedSize.height + (emptyStateNode.calculatedSize.height / 2)
        
        countTextNode.position.x = (countTextNode.calculatedSize.width / 2) + 20
        countTextNode.position.y = (((playlistTitleNode.calculatedSize.height / 2) + 50) + (playlistTitleNode.calculatedSize.height / 2)) + 10 + (countTextNode.calculatedSize.height / 2)
    
        titleShimmer.frame = CGRect(origin: CGPointMake(20, 50), size: self.playlistTitleNode.calculatedSize)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let x = super.layoutSpecThatFits(constrainedSize)
        playlistTitleNode.sizeRange = ASRelativeSizeRangeMake(ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: 30)), ASRelativeSize(width: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40), height: ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 100)))
        
        self.emptyStateNode?.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - 125 - 50))
        
        if self.emptyStateNode == nil {
            return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode])
        } else {
            return ASStaticLayoutSpec(children: [x, playlistTitleNode, countTextNode, self.emptyStateNode])
        }
    }
    
    override func backgroundSizeRange(forConstrainedSize constrainedSize : ASSizeRange) -> ASRelativeSizeRange? {
        self.mainScrollNode.topLimit = 125
        return ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width), ASRelativeDimension(type: .Points, value: 125))
    }
}
extension PlaylistNode : MyTextNodeDelegate{
    func needsLayout() {
        self.setNeedsLayout()
    }
    func tf_becomeFirstResponder() {
        
    }
    func tf_resignFirstResponder() {
        
    }
}

extension PlaylistNode {
    
    var movingCell : ASCellNode! {
        get {
            return self.tracksTable.view.nodeForRowAtIndexPath(self.movingIndexPath)
        }
    }
    var targetIndexPath : NSIndexPath! {
        get {
            let location = self.longPressGestureRecognizer.locationInView(self.tracksTable.view)
            let overlappingIndexPath = self.tracksTable.view.indexPathForRowAtPoint(location)
            let movingRect = self.movingRect
            
            let diffY = self.placeholderView.frame.origin.y - movingRect.origin.y
            
            if diffY < 0 {
                if overlappingIndexPath!.compare(self.movingIndexPath).rawValue < 0 && location.y < (CGRectGetMinY(self.tracksTable.view.rectForRowAtIndexPath(overlappingIndexPath!)) + CGRectGetMaxY(movingRect)) / 2 {
                    return overlappingIndexPath
                }
            } else {
                if overlappingIndexPath!.compare(self.movingIndexPath).rawValue > 0 && location.y > (CGRectGetMinY(movingRect) + CGRectGetMaxY(self.tracksTable.view.rectForRowAtIndexPath(overlappingIndexPath!))) / 2 {
                    return overlappingIndexPath
                }
            }
            return nil
        }
    }
    var movingRect : CGRect {
        get {
            return self.tracksTable.view.rectForRowAtIndexPath(self.movingIndexPath)
        }
    }
    func longPressRecognized(recognizer : UILongPressGestureRecognizer) {
        let locationInView = recognizer.locationInView(self.tracksTable.view)
        
        switch recognizer.state {
        case .Began:
            self.startMovingCellAtLocation(locationInView)
            break
        case .Changed:
            self.keepMovingCellAtLocation(locationInView)
            break
        case .Ended, .Cancelled:
            self.finishMovingCell()
            break
        default:
            break
        }
    }
    
    func startMovingCellAtLocation(location : CGPoint) {
        
        guard let indexPath = self.tracksTable.view.indexPathForRowAtPoint(location) else {
            return
        }
        self.initialIndexPath = indexPath
        
        draggedCell = self.tracksTable.view.nodeForRowAtIndexPath(indexPath)
        placeholderView = draggedCell.view.snapshotViewAfterScreenUpdates(false)
        
        self.movingIndexPath = self.tracksTable.view.indexPathForNode(draggedCell)
        let x = self.tracksTable.view.rectForRowAtIndexPath(indexPath).origin.y + draggedCell.calculatedSize.height / 2
        
        placeholderView.center = CGPointMake(placeholderView.center.x, x)
        self.touchOriginY = placeholderView.center.y - location.y
        
//        draggedCell.hidden = true
        self.tracksTable.view.addSubview(placeholderView)
    }
    func keepMovingCellAtLocation(location : CGPoint) {
        
        self.autoScrollIfNeeded()
        let newCenter = CGPointMake(self.placeholderView.center.x, location.y + self.touchOriginY)
        self.placeholderView.center = newCenter
        self.movingCellDidMove()
    }
    func finishMovingCell() {
        
        self.timerToAutoscroll?.invalidate()
        self.timerToAutoscroll = nil
        
        self.tracksTable.view.asyncDataSource?.tableView?(self.tracksTable.view, moveRowAtIndexPath: initialIndexPath, toIndexPath: self.movingIndexPath)
        
        let x = (draggedCell.view.frame.height - self.movingRect.height) / 2
        print("!*!*!*!*!*!", draggedCell.view.frame, self.movingRect)
        
        placeholderAutoScrollAmount = CGRectGetMidY(self.movingRect) - self.placeholderView.center.y + x
        placeholderScrollAnimation.toValue = 1
        
        self.placeholderStatusAnimation.completionBlock = {
            anim, finished in
            
            for node in self.tracksTable.view.visibleNodes() {
                node.view.hidden = false
            }
            
            self.placeholderView.removeFromSuperview()
            self.placeholderView = nil
            self.movingIndexPath = nil
        }
        self.placeholderStatusAnimation.toValue = 0
        
//        UIView.animateWithDuration(0.3, animations: {
////            self.placeholderView.frame = self.movingRect
//            }, completion: {
//            finished in
//                
//                for node in self.tracksTable.view.visibleNodes() {
//                    node.view.hidden = false
//                }
//                
//                self.placeholderView.removeFromSuperview()
//                self.placeholderView = nil
//                self.movingIndexPath = nil
//        })
    }
    func movingCellDidMove() {
        if let mc = self.movingCell {
            mc.hidden = true
        }
        
        if let targetIndexPath = self.targetIndexPath {
            let oldMovingIndexPath = self.movingIndexPath
            self.movingIndexPath = targetIndexPath
            
            self.tracksTable.view.beginUpdates()
            self.tracksTable.view.moveRowAtIndexPath(oldMovingIndexPath, toIndexPath: targetIndexPath)
            self.tracksTable.view.endUpdates()
        
//            for node in self.tracksTable.view.visibleNodes() {
//                if node != draggedCell {
//                    node.view.hidden = false
//                } else {
//                    node.view.hidden = true
//                }
//            }
            
            self.tracksTable.view.bringSubviewToFront(placeholderView)
        }
        
    }
    
    func autoScrollIfNeeded(){
        self.autoscrollAmount = 0
        
        let location = self.longPressGestureRecognizer.locationInView(self.tracksTable.view)
        
        if self.tracksTable.view.contentSize.height > self.tracksTable.view.frame.size.height {
            let distanceFromTop = location.y - self.tracksTable.view.contentOffset.y
            let distanceFromBottom = tracksTable.view.bounds.height - (location.y - self.tracksTable.view.contentOffset.y)
            
            if distanceFromTop < AutoScrollingMinDistanceFromEdge {
                self.autoscrollAmount = -(self.autoscrollAmountForDistanceToEdge(distanceFromTop))
            } else if distanceFromBottom < AutoScrollingMinDistanceFromEdge{
                self.autoscrollAmount = self.autoscrollAmountForDistanceToEdge(distanceFromBottom)
            }
        }
        
        if self.autoscrollAmount == 0 {
            self.timerToAutoscroll?.invalidate()
            self.timerToAutoscroll = nil
        } else if self.timerToAutoscroll == nil {
            self.timerToAutoscroll = CADisplayLink(target: self, selector: Selector("autoscrollTimerFired:"))
            self.timerToAutoscroll.addToRunLoop(NSRunLoop.mainRunLoop(), forMode:NSDefaultRunLoopMode)
        }
    }
    
    func autoscrollAmountForDistanceToEdge(distance: CGFloat) -> CGFloat {
        return ceil((AutoScrollingMinDistanceFromEdge - distance) / CGFloat(10.0))
    }
    
    func autoscrollTimerFired(timer: NSTimer) {
        var contentOffset = self.tracksTable.view.contentOffset
        let initialContentOffsetY = contentOffset.y
        
        contentOffset.y += self.autoscrollAmount
        
        if contentOffset.y < 0 {
            contentOffset.y = 0
        }
        if contentOffset.y > self.tracksTable.view.contentSize.height - self.tracksTable.view.bounds.size.height {
            contentOffset.y = self.tracksTable.view.contentSize.height - self.tracksTable.view.bounds.size.height
        }
        
        self.tracksTable.view.contentOffset = contentOffset
        
        self.placeholderView.center = CGPointMake(self.placeholderView.center.x, self.placeholderView.center.y + contentOffset.y - initialContentOffsetY)
        
        self.movingCellDidMove()
    }
}


class PlaylistBackgroundNode : ParallaxBackgroundNode {
    var blurView : UIVisualEffectView!
    override init(){
        super.init()
        
        let eff = UIBlurEffect(style: .Dark)
        blurView = UIVisualEffectView(effect: eff)
        self.view.addSubview(blurView)
        print("DID LOAD BACKGROUND NODE")
    }
    
    override func didLoad() {
        super.didLoad()
    }
    
    
    override func layout() {
        super.layout()
        blurView.bounds = CGRectMake(0,0, self.scrollNode.calculatedSize.width, self.scrollNode.calculatedSize.height)
        blurView.center = self.scrollNode.position
    }
    
    override func updateScrollPositions(position: CGFloat, ratioProgress: CGFloat) {
        super.updateScrollPositions(position, ratioProgress: ratioProgress)
        
        if ratioProgress < 1 {
            POPLayerSetTranslationY(self.blurView.layer, 0)
            POPLayerSetScaleXY(self.blurView.layer, CGPointMake(1, 1))
        } else {
            POPLayerSetTranslationY(self.blurView.layer, self.backgroundTranslation)
            POPLayerSetScaleXY(self.blurView.layer, CGPointMake(backgroundScale, backgroundScale))
        }
        
        let initialProgress = self.calculatedSize.height / self.scrollNode.calculatedSize.height
//        print("progress", ratioProgress, initialProgress)
        
        let a = 1 / (1 - initialProgress) * (ratioProgress - initialProgress)
//        POPTransition(ratioProgress, startValue: 1, endValue: 0)
//        print(a)
        self.blurView.alpha = 1 - a
//            1 - (ratioProgress - initialProgress)
    }
}
//0.4 1
//1  0



protocol MyTextNodeDelegate {
    func needsLayout()
}


class MyTextNode : ASEditableTextNode {
    var layoutDelegate : MyTextNodeDelegate?
    var hh : CGFloat = 0 {
        didSet {
            if hh != oldValue {
                self.layoutDelegate?.needsLayout()
            }
        }
    }
    var ww : CGFloat = 0 {
        didSet {
            if ww != oldValue {
                self.layoutDelegate?.needsLayout()
            }
        }
    }
    override func invalidateCalculatedLayout() {
        super.invalidateCalculatedLayout()
        self.measureWithSizeRange(self.constrainedSizeForCalculatedLayout)
        if self.calculatedSize.height != self.hh {
            self.hh = self.calculatedSize.height
        }
    }
    
    override func layout() {
        super.layout()
    }
}