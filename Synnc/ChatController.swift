//
//  ChatController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import pop
import WCLUtilities
import WCLUIKit
import AsyncDisplayKit
import Cloudinary
import WCLLocationManager
import WCLUserManager

class ChatController : ASViewController {
    
    var initialTouchTopWindowPosition : CGFloat = 0
    override var inputAccessoryView : UIView! {
        get {
            return self.chatbar.view
        }
    }
    
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! ChatController).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! ChatController).stateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.springBounciness = 0
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = 1 {
        didSet {
            let trans = POPTransition(stateAnimationProgress, startValue: -node.calculatedSize.height, endValue: 0)
            POPLayerSetTranslationY(node.layer, trans)
        }
    }
    var activeState : Bool = false {
        didSet {
            self.stateAnimation.toValue = activeState ? 0 : 1
            if !activeState {
                self.chatbar.textNode.resignFirstResponder()
            }
        }
    }
    
    var dataSource : ChatRoomDataSource! {
        get {
            if let streamId = self.id {
                return ChatManager.sharedInstance().getChatDataForStream(streamId)
            } else {
                return nil
            }
        }
    }
    var manager : ChatTableManager! = ChatTableManager()
    var isEnabled : Bool = false {
        didSet {
            if isEnabled != oldValue {
                self.chatbar.state = isEnabled
                if isEnabled {
                    let dataSource = ChatManager.sharedInstance().getChatDataForStream(self.id)
                    dataSource.delegate = self
                    dataSource.dataSourceLocked = false
                    self.screenNode.chatCollection.view.asyncDataSource = dataSource
                    self.screenNode.chatCollection.view.reloadData()
                }
            }
        }
    }
    var chatbar : ChatBarNode!
    var screenNode : ChatNode!
    var id : String!
    var tableHeader : UIView!
    var headerHeight : CGFloat!
    var panRecognizer : UIPanGestureRecognizer!
    
    init(){
        let bar = ChatBarNode()
        let n = ChatNode()
        super.init(node: n)
        self.chatbar = bar
        panRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanRecognizer:"))
        panRecognizer.delegate = self
        screenNode = n
        screenNode.view.addGestureRecognizer(panRecognizer)
        screenNode.chatCollection.view.asyncDelegate = self
        screenNode.delegate = self
        self.screenNode.headerNode.closeButton.addTarget(self, action: Selector("hide:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.chatbar.sendButton.addTarget(self, action: Selector("newMessage:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.chatbar.textNode.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
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
    func beginPan(recognizer : UIPanGestureRecognizer){
        initialTouchTopWindowPosition = self.view.frame.origin.y
        self.pop_removeAnimationForKey("inc.stamp.pk.window.progress")
    }
    func updatePan(recognizer : UIPanGestureRecognizer){
        let translation = recognizer.translationInView(UIApplication.sharedApplication().windows.first!)
        
        let yPosition = translation.y
        //            + initialTouchTopWindowPosition
        let x = yPosition / UIScreen.mainScreen().bounds.height
        let y = x
        self.stateAnimationProgress = y
    }
    func endPan(recognizer : UIPanGestureRecognizer){
        let v = recognizer.velocityInView(UIApplication.sharedApplication().windows.first!).y / UIScreen.mainScreen().bounds.height
        if self.stateAnimationProgress >  0.5 {
            if v < -2 {
                self.stateAnimation.velocity = v
                self.display()
            } else {
                self.stateAnimation.velocity = v
                self.hide()
            }
        } else {
            if v > 2 {
                self.stateAnimation.velocity = v
                self.hide()
            } else {
                self.stateAnimation.velocity = v
                self.display()
            }
        }
    }
    func display(){
        self.activeState = true
    }
    func hide(sender : ButtonNode? = nil){
        self.activeState = false
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func keyboardWillChangeFrame(notification: NSNotification) {
        
        if !isEnabled {
            return
        }
        let a = KeyboardAnimationInfo(dict: notification.userInfo!)
        
        var isDisplayed : Bool = false
        if CGRectGetMinY(a.finalFrame) - self.node.calculatedSize.height == 0 {
            isDisplayed = false
        } else {
            isDisplayed = true
        }
        let translation = isDisplayed ? -CGRectGetHeight(a.finalFrame) - self.chatbar.calculatedSize.height : isEnabled ? -self.chatbar.calculatedSize.height : 0
        POPLayerSetTranslationY(self.chatbar.layer, translation)
        POPLayerSetTranslationY(self.screenNode.collectionHolder.layer, isDisplayed ? -CGRectGetHeight(a.finalFrame) : 0)
    }
    
    var msgStr : String!
    
    func configure(stream: Stream) {
        self.screenNode.headerNode.configure(stream)
        self.id = stream.o_id
    }
    
    func newMessage(sender : ButtonNode!) {
        if let sid = self.id, let m = msgStr {
            let msg : [String : AnyObject] = ["stream_id" : sid, "message" : m]
            ChatManager.sharedInstance().sendMessage(msg)
            self.chatbar.textNode.attributedText = nil
            self.msgStr = nil
        }
    }
}
extension ChatController : WCLAsyncTableViewDataSourceDelegate {
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedItems: WCLListSourceUpdaterResult) {
        
        self.manager.performUpdates(self.screenNode.chatCollection.view, updates: updatedItems, animated: true, completion: {
            status in
        
            if status {
                let table = self.screenNode.chatCollection.view
                let ind = table.numberOfRowsInSection(0) - 1
                if ind >= 0 {
                    let ip = NSIndexPath(forItem: table.numberOfRowsInSection(0) - 1, inSection: 0)
                    self.updateHeaderSize(ip)
                }
            }
        })
    }
    
    
    func updateHeaderSize(indexPath : NSIndexPath){
        let table = self.screenNode.chatCollection.view
        if let ds = self.dataSource where ds.data.count > 0 {
            var h : CGFloat = 0
            for (ind,_) in ds.data.enumerate() {
                let ip = NSIndexPath(forItem: ind, inSection: 0)
                if let node = self.screenNode.chatCollection.view.nodeForRowAtIndexPath(ip) as? ChatItemNode {
                    h += node.frame.height
                }
            }
            headerHeight = max(0, table.frame.height - h)
            UIView.animateWithDuration(0.3, animations: {
                table.beginUpdates()
                if let header = self.tableHeader {
                    header.frame.size.height = self.headerHeight
                }
                if h > table.frame.size.height {
                    table.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
                }
                table.endUpdates()
            } )
        }
    }
    
}
extension ChatController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.chatCollection.view.panGestureRecognizer {
            return true
        }
        return false
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panRecognizer && otherGestureRecognizer == self.screenNode.chatCollection.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}
extension ChatController : ASTableViewDelegate {
    func shouldBatchFetchForTableView(tableView: ASTableView) -> Bool {
        return true
    }
    func tableView(tableView: ASTableView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.manager.batchContext = context
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerHeight == nil {
            headerHeight = tableView.frame.height
        }
        return headerHeight
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableHeader == nil {
            tableHeader = UIView()
        }
        return tableHeader
    }
    
    var scrollAnim : POPBasicAnimation {
        get {
            if let anim = self.screenNode.chatCollection.view.pop_animationForKey("scrollAnim") as? POPBasicAnimation {
                return anim
            } else {
                let anim = POPBasicAnimation(propertyNamed: kPOPTableViewContentOffset)
                anim.completionBlock = {
                    anim, finished in
                    self.screenNode.chatCollection.view.panGestureRecognizer.enabled = true
                    self.screenNode.chatCollection.view.pop_removeAnimationForKey("scrollAnim")
                }
                self.screenNode.chatCollection.view.pop_addAnimation(anim, forKey: "scrollAnim")
                return anim
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.screenNode.chatCollection.view {
            let yPos = scrollView.contentOffset.y
            if yPos < -50 {
                if let x = self.screenNode.chatCollection.view {
                    x.programaticScrollEnabled = false
                    
                    scrollView.panGestureRecognizer.enabled = false
                    self.scrollAnim.toValue = NSValue(CGPoint: CGPointMake(0, 0))
                    x.programaticScrollEnabled = true
                }
            }
        }
    }
}
extension ChatController : ChatNodeDelegate {
    func hideKeyboard() {
        self.chatbar.textNode.resignFirstResponder()
        self.activeState = false
    }
}
extension ChatController : ASEditableTextNodeDelegate {
    func editableTextNodeDidBeginEditing(editableTextNode: ASEditableTextNode) {
        self.activeState = true
    }
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            self.newMessage(nil)
            return false
        }
        if let fieldStr = editableTextNode.textView.text {
            var str = (fieldStr as NSString).stringByReplacingCharactersInRange(range, withString: text)
            str = (str as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.msgStr = str
        }
        return true
    }
}


class ChatBarNode : ASDisplayNode {
    
    var stateAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("stateAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! ChatBarNode).stateAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! ChatBarNode).stateAnimationProgress = values[0]
                }
                prop.threshold = 0.001
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var stateAnimation : POPSpringAnimation {
        get {
            if let anim = self.pop_animationForKey("stateAnimation") {
                return anim as! POPSpringAnimation
            } else {
                let x = POPSpringAnimation()
                x.completionBlock = {
                    anim, finished in
                    self.pop_removeAnimationForKey("stateAnimation")
                }
                x.springBounciness = 0
                x.property = self.stateAnimatableProperty
                self.pop_addAnimation(x, forKey: "stateAnimation")
                return x
            }
        }
    }
    var stateAnimationProgress : CGFloat = 1 {
        didSet {
            let trans = POPTransition(stateAnimationProgress, startValue: -self.calculatedSize.height, endValue: 0)
            POPLayerSetTranslationY(self.layer, trans)
        }
    }
    var state : Bool = false {
        didSet {
            if state != oldValue {
                stateAnimation.toValue = state ? 0 : 1
            }
        }
    }
    
    
    var textNode : ASEditableTextNode!
    var sendButton : ButtonNode!
    
        override init() {
        super.init()
        
        textNode = ASEditableTextNode()
        textNode.typingAttributes = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor(red: 65/255, green: 64/255, blue: 64/255, alpha: 1)]
        textNode.attributedPlaceholderText = NSAttributedString(string: "What do you think about this stream", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 13)!, NSForegroundColorAttributeName : UIColor(red: 65/255, green: 64/255, blue: 64/255, alpha: 0.5)])
        textNode.backgroundColor = UIColor.whiteColor()
        textNode.textContainerInset = UIEdgeInsets(top: 5, left: 3, bottom: 5, right: 3)
        textNode.alignSelf = .Stretch
        textNode.returnKeyType = UIReturnKeyType.Send
        
        sendButton = ButtonNode(normalColor: UIColor.SynncColor(), selectedColor: UIColor.SynncColor())
        sendButton.setAttributedTitle(NSAttributedString(string: "Send", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor.whiteColor()]), forState: ASControlState.Normal)
        
        self.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        self.shadowColor = UIColor(red: 223/255, green: 220/255, blue: 220/255, alpha: 1).CGColor
        self.shadowOffset = CGSizeMake(0, -1)
        self.shadowRadius = 1
        
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 44))
        
        self.addSubnode(self.textNode)
        self.addSubnode(sendButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        sendButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(70, 32))
        let buttonSpec = ASStaticLayoutSpec(children: [sendButton])
        textNode.spacingBefore = 14
        self.textNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (70 + 14 + 15 + 9))
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 15, justifyContent: .Start, alignItems: .Start, children: [textNode, buttonSpec])
        hStack.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [hStack])
    }
}