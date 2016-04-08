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
import WCLPopupManager

class ChatController : ASViewController, PagerSubcontroller {
    
    lazy var _leftHeaderIcon : ASImageNode! = {
        return nil
    }()
    var leftHeaderIcon : ASImageNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASImageNode! = {
        return nil
    }()
    var rightHeaderIcon : ASImageNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Stream Info", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return nil
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    var initialTouchTopWindowPosition : CGFloat = 0
    override var inputAccessoryView : UIView! {
        get {
            
//            self.chatbar.measureWithSizeRange(ASSizeRangeMakeExactSize(CGSizeMake(self.view.bounds.width, 50)))
            self.chatbar.measure(CGSizeMake(self.view.bounds.width, 50))
            self.chatbar.view.frame = CGRect(origin: CGPointZero, size: self.chatbar.calculatedSize)
            return self.chatbar.view
        }
    }
    
    var shouldFirstRespond : Bool = false
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func canResignFirstResponder() -> Bool {
        return true
    }
    var isActive : Bool = false {
        didSet {
            if isActive {
//                self.chatbar.textNode.becomeFirstResponder()
                self.becomeFirstResponder()
            } else {
                self.resignFirstResponder()
            }
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
//            POPLayerSetTranslationY(node.layer, trans)
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
                let ds = ChatManager.sharedInstance().getChatDataForStream(streamId)
                ds.roomDelegate = self
                return ds
            } else {
                return nil
            }
        }
    }
    var manager : ChatTableManager! = ChatTableManager()
    var isEnabled : Bool = false {
        didSet {
            if isEnabled != oldValue {
//                self.chatbar.state = isEnabled
                if isEnabled {
                    let dataSource = ChatManager.sharedInstance().getChatDataForStream(self.id)
                    dataSource.roomDelegate = self
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
    
    init(){
        let bar = ChatBarNode()
        let n = ChatNode()
        super.init(node: n)
        self.chatbar = bar
        screenNode = n
        screenNode.chatCollection.view.asyncDelegate = self
        
        screenNode.delegate = self
        self.chatbar.sendButton.addTarget(self, action: #selector(ChatController.newMessage(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.chatbar.textNode.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatController.keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    func display(){
        self.activeState = true
    }
    func hide(sender : ButtonNode? = nil){
        self.activeState = false
    }
    
    
    var needsFetch : Bool = false {
        didSet {
            if needsFetch != oldValue && needsFetch {
//                print("FETCH NOW")
//                ["last_update" : x, "limit" : 100, "stream_id"]
                ChatManager.sharedInstance().requestOld(self.id)
            }
        }
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
        if CGRectGetMaxY(a.finalFrame) > self.node.calculatedSize.height {
            isDisplayed = false
        } else {
            isDisplayed = true
        }
        let translation = isDisplayed ? -CGRectGetHeight(a.finalFrame) - self.chatbar.calculatedSize.height : isEnabled ? -self.chatbar.calculatedSize.height : 0
        POPLayerSetTranslationY(self.screenNode.collectionHolder.layer, isDisplayed ? -CGRectGetHeight(a.finalFrame) : 0)
    }
    
    var msgStr : String!
    
    func configure(stream: Stream) {
        self.id = stream.o_id
        
        isActive = (stream == StreamManager.sharedInstance.activeStream)
        
        self.screenNode.notAvailableState = !isActive
        if self.screenNode.notAvailableState {
            self.screenNode.notAvailableStateNode.subTextNode.addTarget(self, action: #selector(ChatController.joinStream(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
    func joinStream(sender : AnyObject){
        if let pvc = self.parentViewController as? StreamVC {
            pvc.joinStream(sender)
        }
    }
    
    func newMessage(sender : ButtonNode!) {
        AnalyticsEvent.new(category: "StreamChat", action: "newItem", label: "button", value: nil)
        if let sid = self.id, let m = msgStr {
            let msg : [String : AnyObject] = ["stream_id" : sid, "message" : m]
            ChatManager.sharedInstance().sendMessage(msg)
            self.chatbar.textNode.attributedText = nil
            self.msgStr = nil
        }
    }
}
extension ChatController : WCLAsyncTableViewDataSourceDelegate {
    
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedItemAtIndexPath indexPAth: NSIndexPath) {
        self.manager.updateItem(self.screenNode.chatCollection.view, indexPath: indexPAth, animated: true)
    }
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
            headerHeight = max(50, table.frame.height - h)
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
extension ChatController : ASTableViewDelegate {
    func shouldBatchFetchForTableView(tableView: ASTableView) -> Bool {
//        tableView.trailing
//        tableView.direction
        return false
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
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        needsFetch = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
//        print(scrollView.contentOffset.y, scrollView.decelerating)
        if scrollView.contentOffset.y < 0 && scrollView.contentOffset.y >= -50 && scrollView.decelerating {
//            print("BATCH")
            needsFetch = true
        }
        
        if let pvc = self.parentViewController as?  StreamVC {
            pvc.updateScrollPosition(scrollView.contentOffset.y)
        }
        
        if let s = (self.screenNode).chatCollection.view {
            if s.contentOffset.y  < -(self.node.calculatedSize.width - 100) {
                s.programaticScrollEnabled = false
                s.panGestureRecognizer.enabled = false
                s.programaticScrollEnabled = true
                
                let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
                s.pop_addAnimation(animation, forKey: "offsetAnim")
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
            } else {
                s.panGestureRecognizer.enabled = true
            }
        }
        
//        self.screenNode.chatCollection.view.beginFet
        
//        if scrollView == self.screenNode.chatCollection.view {
//            let yPos = scrollView.contentOffset.y
//            if yPos < -50 {
//                if let x = self.screenNode.chatCollection.view {
//                    x.programaticScrollEnabled = false
//                    
//                    scrollView.panGestureRecognizer.enabled = false
//                    self.scrollAnim.toValue = NSValue(CGPoint: CGPointMake(0, 0))
//                    x.programaticScrollEnabled = true
//                }
//            }
//        }
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
            AnalyticsEvent.new(category: "StreamChat", action: "newItem", label: "keyboard", value: nil)
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

extension ChatController : ChatRoomDataSourceDelegate {
    func nodeForItemAtIndexPath(indexPath: NSIndexPath) -> ASCellNode {
        var node : ChatItemNode
        
        if let data = self.dataSource!.data[indexPath.item] as? ChatItem {
            if data.user == Synnc.sharedInstance.user {
                node = MyChatItemNode()
            } else {
                node = ChatItemNode()
            }
            //            print("data for indexPath", indexPath.item, data.message)
            node.configure(data)
        } else {
            node = ChatItemNode()
        }
        
        node.imageNode.addTarget(self, action: #selector(ChatController.didTapUserInfo(_:)) , forControlEvents: .TouchUpInside)
        node.textHolder.usernameNode.addTarget(self, action: #selector(ChatController.didTapUserInfo(_:)), forControlEvents: .TouchUpInside)
        
        
        
        return node
    }
    
    func didTapUserInfo(sender : AnyObject) {
        if let uui = sender as? UserUIElement, let user = WCLUserManager.sharedInstance.findUser(uui.userId) {
            
            if self.chatbar.textNode.isFirstResponder() {
                self.chatbar.textNode.resignFirstResponder()
            }
//            self.resignFirstResponder()
            
            let size = CGSizeMake(UIScreen.mainScreen().bounds.width - 100, UIScreen.mainScreen().bounds.height - 200)
            let x = UserProfilePopup(size: size, user: user)
            WCLPopupManager.sharedInstance.newPopup(x)
        }
    }
}

class ChatBarNode : ASDisplayNode {
        
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
            
        backgroundColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        sendButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(70, 32))
        let buttonSpec = ASStaticLayoutSpec(children: [sendButton])
//        textNode.spacingBefore = 14
        self.textNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - (70 + 20 + 15))
        let hStack = ASStackLayoutSpec(direction: .Horizontal, spacing: 15, justifyContent: .Start, alignItems: .Start, children: [textNode, buttonSpec])
        hStack.alignSelf = .Stretch
        
        let a = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [hStack])
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(5, 10, 5, 10), child: a)
    }
}