//
//  ChatTableManager.swift
//  Synnc
//
//  Created by Arda Erzin on 1/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import WCLUIKit
import WCLUtilities

class ChatTableManager : WCLTableViewManager {
    override func performUpdates(tableView: ASTableView, updates: WCLListSourceUpdaterResult, animated: Bool, completion: ((Bool) -> Void)? = nil) {       
        Async.main {
            
            tableView.beginUpdates()
            
            if !updates.addedIndexPaths.isEmpty {
                tableView.insertRowsAtIndexPaths(updates.addedIndexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
            }
            if !updates.removedIndexPaths.isEmpty {
                tableView.deleteRowsAtIndexPaths(updates.removedIndexPaths, withRowAnimation: .Fade)
            }
            if !updates.movedIndexPaths.isEmpty {
                for item in updates.movedIndexPaths {
                    tableView.moveRowAtIndexPath(item.fromIndexPath, toIndexPath: item.toIndexPath)
                }
            }
            
            tableView.endUpdatesAnimated(true, completion: {
                status in
                self.finishUpdates()
                completion?(status)
            })
            
        }
    }
}