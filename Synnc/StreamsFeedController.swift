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
        self.dataSource.refresh = true
        self.dataSource.pendingData = StreamManager.sharedInstance.userFeed
        
        self.screenNode.emptyState = StreamManager.sharedInstance.userFeed.isEmpty
        print("UPDATED FEED")
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
            let vc = StreamVC(stream: stream)
            let opts = WCLWindowOptions(link: false, draggable: true, limit: UIScreen.mainScreen().bounds.height - 70, dismissable: true)
        
            let a = WCLWindowManager.sharedInstance.newWindow(vc, animated: true, options: opts)
            a.delegate = vc
            a.panRecognizer.delegate = vc
            a.display(true)
            
            AnalyticsEvent.new(category : "ui_action", action: "cell_tap", label: "stream", value: nil)
        }
    }
}
extension StreamsFeedController : WCLAsyncTableViewDataSourceDelegate {
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedItems: WCLListSourceUpdaterResult) {
        self.tableManager.performUpdates(self.screenNode.tableNode.view, updates: updatedItems, animated: true)
    }

//    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
//        return (min: CGSizeMake(self.view.frame.width, CGFloat.min), max: CGSizeMake(self.view.frame.width, CGFloat.max))
//    }
//    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: WCLListSourceUpdaterResult) {
//        self.collectionManager.performUpdates(self.screenNode.streamCollection.view, updates: updatedData, animated: true)
//    }
}