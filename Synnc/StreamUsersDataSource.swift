//
//  StreamUsersDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 1/6/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import WCLUIKit
import AsyncDisplayKit
import WCLUserManager

class StreamUsersDataSource : WCLAsyncCollectionViewDataSource {
    
    override func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = ListenerCellNode()
        
        
        if let user = self.data[indexPath.item] as? WCLUser {
            node.configureForUser(user)
        }
        
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