//
//  SearchStreamsController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class SearchStreamsController : TabSubsectionController {
    override var _title : String! {
        return "Streams"
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let x = self.parentViewController as? SearchController {
            x.titleItem.resignFirstResponder()
        }
    }
    override init(){
        let listNode = StreamSearchNode()
        super.init(node: listNode)
        self.screenNode = listNode
        
        if SharedPlaylistDataSource.allItems.isEmpty {
            let s = self.screenNode as! MyPlaylistsNode
            s.emptyState = true
            s.emptyStateNode.subTextNode.addTarget(self, action: Selector("newPlaylistAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        }
        
//        let nn = self.screenNode as! MyPlaylistsNode
//        nn.collectionNode.view.asyncDataSource = self
//        nn.collectionNode.view.asyncDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchStreamsController : SubSearchController {
    func subSearchController(updatedSearchString: String!) {
        
        guard let str = updatedSearchString else {
            print("error")
            return
        }
        
        let x = StreamManager.sharedInstance.findStreams(updatedSearchString) { (searchString, genres, timeStamp, objects) -> Void in
            print("wadap")
            print("found streams:", objects)
        }
        print("x",x)
    }
}

class StreamSearchNode : ASDisplayNode, TrackedView {
    var title : String! = "Stream Search"
}