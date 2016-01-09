//
//  StreamUsersDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 1/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop
import WCLUserManager

class StreamUsersController : NSObject {
    var dataSource : StreamUsersDataSource = StreamUsersDataSource()
    var manager : WCLCollectionViewManager! = WCLCollectionViewManager()
    var collectionView : ASCollectionView! {
        didSet {
            collectionView.asyncDataSource = self.dataSource
            collectionView.asyncDelegate = self
        }
    }
    
    override init() {
        super.init()
        dataSource.delegate = self
    }
    
    func update(users: [WCLUser]) {
        self.dataSource.refresh = true
        self.dataSource.pendingData = users
    }
}
extension StreamUsersController : ASCollectionViewDelegate {
    func collectionView(collectionView: ASCollectionView!, willBeginBatchFetchWithContext context: ASBatchContext!) {
        self.manager.batchContext = context
    }
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView!) -> Bool {
        return true
    }
}
extension StreamUsersController : WCLAsyncCollectionViewDataSourceDelegate {
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: WCLListSourceUpdaterResult) {
        self.manager?.performUpdates(collectionView, updates: updatedData, animated: true, completion: nil)
    }
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
        return (min: CGSizeMake(40,40), max: CGSizeMake(40,40))
    }
}

class StreamUsersDataSource : WCLAsyncCollectionViewDataSource {
    
    override func collectionView(collectionView: ASCollectionView!, nodeForItemAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let node = ListenerCellNode()
        if let data = self.data[indexPath.item] as? WCLUser {
            node.imageURL = data.avatarURL(WCLUserLoginType(rawValue: data.provider)!, frame: CGRectMake(0, 0, 40, 40), scale: UIScreen.mainScreen().scale)
            print(node.imageURL.absoluteString)
        } else {
            print("NO USER")
        }
        node.fetchData()
        return node
    }
    
    func dataAtIndex(index: Int) -> NSObject? {
        if index < self.data.count {
            return self.data[index]
        } else {
            return nil
        }
    }
}