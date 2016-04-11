//
//  ArtistSearchDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 12/15/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUIKit
import AsyncDisplayKit
import pop

class ArtistSearchDataSource : WCLAsyncCollectionViewDataSource {
    
    var nextAction : (()->Void)?
    
    override func collectionView(collectionView: ASCollectionView, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> ASSizeRange {
        return ASSizeRangeMakeExactSize(CGSizeMake(100, collectionView.frame.height - 10))
    }
    
    override func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = SynncArtistSmallNode()
        
        if indexPath.item >= self.data.count {
            return node
        }
        
        if let data = self.data[indexPath.item] as? SynncArtist where indexPath.item < self.data.count {
            node.configureForArtist(data)
        }
        node.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return node
    }
    
    func loadMore(){
        nextAction?()
    }
    
    func dataAtIndex(index: Int) -> NSObject? {
        if index < self.data.count {
            return self.data[index]
        } else {
            return nil
        }
    }
}