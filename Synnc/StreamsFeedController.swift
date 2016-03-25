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
        let x = ASImageNode()
        x.image = UIImage(named: "magnifier-white")
        x.contentMode = .Center
        return x
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
        x.attributedString = NSAttributedString(string: "feed", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    
    var screenNode : StreamsFeedNode!
    var dataSource : StreamFeedDataSource! = StreamFeedDataSource()
    var collectionManager : WCLCollectionViewManager! = WCLCollectionViewManager()
    
    init() {
        let node = StreamsFeedNode()
        super.init(node: node)
        self.screenNode = node
        dataSource.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamsFeedController.updatedFeed(_:)), name: "UpdatedUserFeed", object: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        screenNode.streamCollection.view.asyncDataSource = self.dataSource
        screenNode.streamCollection.view.asyncDelegate = self

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
        
        self.screenNode.emptyState = StreamManager.sharedInstance.userFeed.isEmpty
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
//        if let stream = self.dataSource.data[indexPath.item] as? Stream {
//            Synnc.sharedInstance.streamNavigationController.displayStream(stream)
//        }
    }
}
extension StreamsFeedController : WCLAsyncCollectionViewDataSourceDelegate {
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
        return (min: CGSizeMake(self.view.frame.width, CGFloat.min), max: CGSizeMake(self.view.frame.width, CGFloat.max))
    }
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: WCLListSourceUpdaterResult) {
        self.collectionManager.performUpdates(self.screenNode.streamCollection.view, updates: updatedData, animated: true)
    }
}