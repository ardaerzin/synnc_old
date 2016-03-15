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

class StreamsFeedController : TabSubsectionController {
    
    var dataSource : StreamFeedDataSource! = StreamFeedDataSource()
    var collectionManager : WCLCollectionViewManager! = WCLCollectionViewManager()
    override var _title : String! {
        return "Recommended"
    }
    
    override init() {
        let node = StreamsFeedNode()
        super.init(node: node)
        self.screenNode = node
        dataSource.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updatedFeed:"), name: "UpdatedUserFeed", object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let s = self.screenNode as? StreamsFeedNode {
            s.streamCollection.view.asyncDataSource = self.dataSource
            s.streamCollection.view.asyncDelegate = self
        }
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
    func updatedFeed(notification: NSNotification) {
        self.dataSource.refresh = true
        self.dataSource.pendingData = StreamManager.sharedInstance.userFeed
        
        (self.screenNode as! StreamsFeedNode).emptyState = StreamManager.sharedInstance.userFeed.isEmpty
    }
}
extension StreamsFeedController : ASCollectionDelegate {
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView) -> Bool {
        return true
    }
    func collectionView(collectionView: ASCollectionView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.collectionManager.batchContext = context
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let stream = self.dataSource.data[indexPath.item] as? Stream {
            Synnc.sharedInstance.streamNavigationController.displayStream(stream)
        }
    }
}
extension StreamsFeedController : WCLAsyncCollectionViewDataSourceDelegate {
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
        return (min: CGSizeMake(self.view.frame.width, CGFloat.min), max: CGSizeMake(self.view.frame.width, CGFloat.max))
    }
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: WCLListSourceUpdaterResult) {
        self.collectionManager.performUpdates((self.screenNode as! StreamsFeedNode).streamCollection.view, updates: updatedData, animated: true)
    }
}