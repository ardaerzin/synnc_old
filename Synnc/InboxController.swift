//
//  InboxController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit

class SynncNotification : NSObject {
    var msg : String!
    var from : String!
    var timestamp : NSDate!
    
    init(msg : String) {
        super.init()
        self.msg = msg
    }
}
class InboxDataSource : WCLAsyncTableViewDataSource {
    override func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = InboxItemNode()
       
        if let data = self.data[indexPath.item] as? SynncNotification {
            node.configureForNotification(data)
        }
        
        node.backgroundColor = UIColor.whiteColor()
        return node
    }
    
    func loadData(){
        let data = [
            SynncNotification(msg: "I arrived in America's @airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's @airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS."),
            SynncNotification(msg: "I arrived in America's airport with clothings, US dollars, and a jar of gypsy tears to protect me from AIDS.")
        ]
        self.pendingData = data
    }
}

class InboxController : PopContentController {
    
    var dataSource : InboxDataSource! = InboxDataSource()
    var inboxManager : WCLTableViewManager = WCLTableViewManager()
    
    init(){
        let node = InboxNode()
        super.init(node: node)
        self.screenNode = node
        
        node.inboxTable.view.asyncDataSource = dataSource
        node.inboxTable.view.asyncDelegate = self
        
        self.dataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource.loadData()
    }
}
extension InboxController : WCLAsyncTableViewDataSourceDelegate {
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedItems: WCLListSourceUpdaterResult) {
        self.inboxManager.performUpdates((self.screenNode as! InboxNode).inboxTable.view, updates: updatedItems, animated: true)
    }
}
extension InboxController : ASTableViewDelegate {
    func tableView(tableView: ASTableView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.inboxManager.batchContext = context
        self.dataSource.loadData()
    }
    func shouldBatchFetchForTableView(tableView: ASTableView) -> Bool {
        return true
    }
}

class InboxNode : ASDisplayNode {
    
    var headerNode : ASTextNode!
    var separator : ASDisplayNode!
    var inboxTable : ASTableNode!
    var closeButton : ButtonNode!
    
    let attributes = [NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 18)!, NSForegroundColorAttributeName : UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1), NSKernAttributeName : -0.1]
    
    override init() {
    
        super.init()
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.headerNode = ASTextNode()
        self.headerNode.attributedString = NSAttributedString(string: "Inbox", attributes: self.attributes)
        self.headerNode.spacingBefore = 22
        self.headerNode.flexGrow = true
        
        self.closeButton = ButtonNode(normalColor: .clearColor(), selectedColor: .clearColor())
        self.closeButton.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        self.closeButton.setImage(UIImage(named: "close")?.resizeImage(usingWidth: 12), forState: ASControlState.Normal)
        self.closeButton.alpha = 0.6
        
        self.separator = ASDisplayNode()
        self.separator.flexBasis = ASRelativeDimension(type: .Points, value: 1/UIScreen.mainScreen().scale)
        self.separator.alignSelf = .Stretch
        self.separator.backgroundColor = UIColor(red: 212/255, green: 212/255, blue: 212/255, alpha: 1)
        
        self.inboxTable = ASTableNode(style: UITableViewStyle.Plain)
//        self.inboxTable.alignSelf = .Stretch
        self.inboxTable.view.leadingScreensForBatching = 1
//        self.inboxTable.flexGrow = true
        
        self.addSubnode(self.headerNode)
        self.addSubnode(self.closeButton)
        self.addSubnode(self.separator)
        self.addSubnode(self.inboxTable)
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.inboxTable.view.tableFooterView = UIView(frame: CGRectZero)
        self.inboxTable.view.tableHeaderView = UIView(frame: CGRectZero)
        self.inboxTable.view.allowsMultipleSelection = true
        self.inboxTable.view.separatorInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 0)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let buttonSpec = ASStaticLayoutSpec(children: [self.closeButton])
        buttonSpec.spacingAfter = 18
        
        let headerSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.headerNode, buttonSpec])
        headerSpec.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        headerSpec.alignSelf = .Stretch
        
        let spacer = ASLayoutSpec()
        spacer.flexGrow = true
        
        if constrainedSize.max.height.isFinite {
            inboxTable.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: constrainedSize.max.height - 65))
        }
        
        let x = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [headerSpec, separator, ASStaticLayoutSpec(children: [inboxTable])])
        
        return x
    }
}