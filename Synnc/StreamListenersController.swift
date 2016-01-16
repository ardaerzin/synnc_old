//
//  StreamListenersController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop
import WCLUserManager

class StreamListenersController : ASViewController {
    var dataSource : StreamUsersDataSource = StreamUsersDataSource()
    var manager : WCLCollectionViewManager! = WCLCollectionViewManager()
    var collectionView : ASCollectionView! {
        get {
            if let v = self.screenNode.listenersCollection?.view {
                return v
            } else {
                return nil
            }
        }
    }
    var screenNode : StreamListenersNode!
    
    init(){
        let node = StreamListenersNode()
        super.init(node: node)
        self.screenNode = node
        self.screenNode.listenersCollection.view.asyncDataSource = self.dataSource
        self.screenNode.listenersCollection.view.asyncDelegate = self
        
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(stream : Stream) {
        self.dataSource.refresh = true
        self.dataSource.pendingData = stream.users
        self.screenNode.update(stream)
    }
}

extension StreamListenersController : ASCollectionDelegate {
    func collectionView(collectionView: ASCollectionView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.manager.batchContext = context
    }
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView) -> Bool {
        return true
    }
}
extension StreamListenersController : WCLAsyncCollectionViewDataSourceDelegate {
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: WCLListSourceUpdaterResult) {
        self.manager?.performUpdates(collectionView, updates: updatedData, animated: true, completion: nil)
    }
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
        return (min: CGSizeMake(40,40), max: CGSizeMake(40,40))
    }
}