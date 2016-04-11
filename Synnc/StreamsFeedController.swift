//
//  StreamsFeedController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop

class StreamsFeedController : ASViewController, PagerSubcontroller {
    
    lazy var _leftHeaderIcon : ASControlNode! = {
        return nil
    }()
    var leftHeaderIcon : ASControlNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASControlNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "newPlaylist")
        x.contentMode = .Center
        return x
    }()
    var rightHeaderIcon : ASControlNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Discover", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor.whiteColor().colorWithAlphaComponent(0.27), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    
    var screenNode : StreamsFeedNode!
    var dataSource : StreamFeedDataSource! = StreamFeedDataSource()
    var tableManager : WCLTableViewManager! = WCLTableViewManager()
    
    init() {
        let node = StreamsFeedNode()
        super.init(node: node)
        self.screenNode = node
        dataSource.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamsFeedController.updatedFeed(_:)), name: "UpdatedUserFeed", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamsFeedController.updatedStream(_:)), name: "UpdatedStream", object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenNode.tableNode.view.asyncDataSource = self.dataSource
        screenNode.tableNode.view.asyncDelegate = self

        self.rightHeaderIcon.addTarget(self.parentViewController!, action: #selector(HomeController.scrollAndCreatePlaylist(_:)), forControlEvents: .TouchUpInside)
    
        self.screenNode.emptyState = StreamManager.sharedInstance.userFeed.isEmpty
        if self.screenNode.emptyState {
            self.screenNode.emptyStateNode.actionButton.addTarget(self, action: #selector(StreamsFeedController.scrollToPlaylists(_:)), forControlEvents: .TouchUpInside)
        }
    }
   
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateDataSource(){
        
//        let diff = SearchResultsUpdater.compareResults(self.dataSource, newArr: StreamManager.sharedInstance.userFeed) { (results) -> Void in
//            self.streamsCollectionView.performBatchUpdates({
//                
//                self.dataSource = StreamManager.sharedInstance.userFeed
//                
//                if !results.addedIndexPaths.isEmpty {
//                    self.streamsCollectionView.insertItemsAtIndexPaths(results.addedIndexPaths)
//                }
//                if !results.removedIndexPaths.isEmpty {
//                    self.streamsCollectionView.deleteItemsAtIndexPaths(results.removedIndexPaths)
//                }
//                for item in results.movedIndexPaths {
//                    self.streamsCollectionView.moveItemAtIndexPath(item.fromIndexPath, toIndexPath: item.toIndexPath)
//                }
//                
//                }, completion: nil)
//        }
        //        let a = StreamManager.sharedInstance.userFeed
        //        StreamManager.sharedInstance.userFeed
        //        self.dataSource = streamManager.streams
        //            .map { ($0.copy() as! Stream) }
        //        self.dataSource = streamManager.streams.sort({ $0.users.count > $1.users.count})
    }
    
    func updatedStream(notification: NSNotification) {
        if let stream = notification.object as? Stream, let ind = self.dataSource.data.indexOf(stream) {

            if let cell = self.screenNode.tableNode.view.nodeForRowAtIndexPath(NSIndexPath(forItem: ind, inSection: 0)) as? StreamCellNode {
            
                cell.configureForStream(stream)
                
            }
            
        }
    }
    func updatedFeed(notification: NSNotification) {
        
        Async.main {
            self.dataSource.refresh = true
            self.dataSource.pendingData = StreamManager.sharedInstance.userFeed
            self.screenNode.emptyState = StreamManager.sharedInstance.userFeed.isEmpty
            
            if self.screenNode.emptyState {
                self.screenNode.emptyStateNode.actionButton.addTarget(self, action: #selector(StreamsFeedController.scrollToPlaylists(_:)), forControlEvents: .TouchUpInside)
            }
        }
        
    }
    
    func scrollToPlaylists(sender: AnyObject) {
        if let pvc = self.parentViewController as? HomeController {
            pvc.screenNode.pager.scrollToPageAtIndex(1, animated: true)
        }
    }
}
extension StreamsFeedController : ASTableDelegate {
    func shouldBatchFetchForTableView(tableView: ASTableView) -> Bool {
        return true
    }
    func tableView(tableView: ASTableView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.tableManager.batchContext = context
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let stream = self.dataSource.data[indexPath.item] as? Stream where indexPath.item < self.dataSource.data.count {
            
            self.node.userInteractionEnabled = false
            
            let vc = StreamVC(stream: stream)
            let opts = WCLWindowOptions(link: false, draggable: true, limit: UIScreen.mainScreen().bounds.height - 70, dismissable: true)
        
            let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
            a.delegate = vc
            a.clipsToBounds = false
            a.panRecognizer.delegate = vc
            a.display(true)
            
            AnalyticsEvent.new(category : "ui_action", action: "cell_tap", label: "stream", value: nil)
        }
    }
}
extension StreamsFeedController : WCLAsyncTableViewDataSourceDelegate {
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedData: (oldData: [NSObject], newData: [NSObject])) {
        self.tableManager.performUpdates(self.screenNode.tableNode.view, updates: (oldItems: updatedData.oldData, newItems: updatedData.newData), animated: true)
    }
}