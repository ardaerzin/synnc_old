//
//  TrackSearchDataSource.swift
//  Synnc
//
//  Created by Arda Erzin on 12/16/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit
import pop

class TrackSearchDataSource : WCLAsyncTableViewDataSource {
    
    var nextAction : (()->Void)?
    
    override func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = SynncTrackNode(withIcon: true, withSource: false)
        if indexPath.item >= self.data.count {
            return node
        }
        if let data = self.data[indexPath.item] as? SynncTrack where indexPath.item < self.data.count {
            node.configureForTrack(data)
        }
        
        return node
    }
    
    func loadMore(){
        nextAction?()
    }
    
    
}