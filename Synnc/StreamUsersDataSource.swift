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
        if let data = self.data[indexPath.item] as? WCLUser {
            node.imageURL = data.avatarURL(WCLUserLoginType(rawValue: data.provider)!, frame: CGRectMake(0, 0, 40, 40), scale: UIScreen.mainScreen().scale)
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