//
//  StreamChatManager.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SocketIOClientSwift
import WCLUtilities
import WCLUserManager
import SwiftyJSON
import AsyncDisplayKit
import WCLUIKit
import Dollar
import Async

protocol ChatRoomDataSourceDelegate {
    func nodeForItemAtIndexPath(indexPath : NSIndexPath) -> ASCellNode
}
class ChatRoomDataSource : WCLAsyncTableViewDataSource {
    var roomDelegate : ChatRoomDataSourceDelegate?
    weak var tableView : ASTableView!
    
    override func processPendingData(oldData: [NSObject], newData: [NSObject]) {
        Async.background {
            if var chatData = newData as? [ChatItem] where !newData.isEmpty {
                chatData.sortInPlace { $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending }
                super.processPendingData(oldData, newData: chatData)
            }
        }

    }
    
    override func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        self.tableView = tableView
        return self.roomDelegate!.nodeForItemAtIndexPath(indexPath)
    }
    
    func updateItem(item: ChatItem) {
        if let ind = self.data.indexOf(item) where ind >= 0, let table = tableView {
            if let node = table.nodeForRowAtIndexPath(NSIndexPath(forRow: ind, inSection: 0)) as? ChatItemNode where ind < tableView.numberOfRowsInSection(0) {
                node.configure(item)
            }
        }
    }
    func pushItem(item: ChatItem, completion : (()->Void)?) {
        self.pendingData.append(item)
    }
    func pushMultiple(items: [NSObject], completion : (()->Void)?) {
        self.pendingData += items
    }
}

typealias ChatSaveBatch = (data : [JSON], completionHandler : ((chatItems : [ChatItem])->Void)?)
class ChatBatchSaver {
    var isLocked : Bool = false {
        didSet {
            print("!*!*!*!* IS LOCKED", isLocked)
        }
    }
    var batches : [ChatSaveBatch] = [] {
        didSet {
            if let batch = batches.first where !isLocked {
                self.isLocked = true
                self.saveBatch(batch)
            }
        }
    }
    var savedItems : [ChatItem] = []
    class var sharedInstance : BatchStreamSaver {
        get {
            return _batchSaver
        }
    }
    init() {
        
    }
    
    func saveBatch(batch : ChatSaveBatch){
        var b = batch
        if let data = b.data.first {
            
            let item = ChatItem()
            item.fromJSON(data)
            
//            for item in jsonArr! {
//                let ci = ChatItem()
//                ci.fromJSON(item)
//                arr.append(ci)
//                //                        Async.main {
//                //                            self.newChatEntry(ci)
//                //                        }
//            }
            if let user = WCLUserManager.sharedInstance.findUser(item.user_id) {
                item.user = user
                self.savedItems.append(item)
                b.data.removeFirst()
                if b.data.isEmpty {
                    b.completionHandler?(chatItems: self.savedItems)
                    self.savedItems.removeAll()
                    self.isLocked = false
                    self.batches.removeFirst()
                } else {
                    self.saveBatch(b)
                }
            } else {
                WCLUserManager.sharedInstance.findUser(item.user_id, cb: { (user) -> Void in
                    item.user = user
                    self.savedItems.append(item)
                    b.data.removeFirst()
                    if b.data.isEmpty {
                        b.completionHandler?(chatItems: self.savedItems)
                        self.savedItems.removeAll()
                        
                        self.isLocked = false
                        self.batches.removeFirst()
                    } else {
                        self.saveBatch(b)
                    }
                })
            }
        } else {
            self.isLocked = false
        }
    }
}

class ChatManager : NSObject {
    
    var batchSaver = ChatBatchSaver()
    weak var socket : SocketIOClient!
    var chatData : [String : ChatRoomDataSource] = [String : ChatRoomDataSource]()
    
    class func sharedInstance() -> ChatManager {
        return _sharedChatManager
    }
    override init() {
        super.init()
    }
    func setupSocket(socket: SocketIOClient){
        self.socket = socket
        socket.on("StreamChat:message", callback: chatMessageCallback())
    }
    func chatMessageCallback() -> NormalCallback {
        return {
            (dataArr, ack) in
            if let data = dataArr.first {
                let jsonArr = JSON(data).array
                
                if jsonArr == nil {
                    return
                }
                
                print(jsonArr)
                
                
                Async.background {
                    let batch = ChatSaveBatch(data: jsonArr!) {
                        items in
                        
                        if self.chatData[items.first!.stream_id] == nil {
                            self.chatData[items.first!.stream_id] = ChatRoomDataSource()
                        }
                        
                        let dataSource = self.chatData[items.first!.stream_id]!
                        
                        Async.main {
                            dataSource.pushMultiple(items, completion: nil)
                        }
                    }
                    self.batchSaver.batches.append(batch)
                }
            }
        }
    }
    
    func requestOld(streamId : String) {
        
        if self.chatData[streamId] == nil {
            self.chatData[streamId] = ChatRoomDataSource()
        }
        
        let dataSource = self.chatData[streamId]!
        
        var lastUpdate : NSTimeInterval = NSDate().timeIntervalSince1970
        if let item = dataSource.data.first as? ChatItem, let lu = item.last_update {
            lastUpdate = lu.timeIntervalSince1970 * 1000
        }
        
        var dict = [String : AnyObject]()
        dict["last_update"] = lastUpdate
        dict["stream_id"] = streamId
        self.socket.emit("StreamChat", dict)
    }
    
    func sendMessage(dictionary: [String : AnyObject]){
        
        var dict = dictionary
        
        dict["timestamp"] = NSDate().timeIntervalSince1970
        dict["user_id"] = Synnc.sharedInstance.user._id
        
        let json = JSON(dict)
        
        let ci = ChatItem()
        ci.fromJSON(json)
        ci.status = false
        ci.user = Synnc.sharedInstance.user
        self.newChatEntry(ci)
        
        self.socket.emitWithAck("StreamChat:message", dict)(timeoutAfter: 0, callback: {
            (dataArr) in
            if let err = dataArr.first, let isErr = JSON(err).bool where isErr {
                print("err with chat", err)
            }
            
            if self.chatData[ci.stream_id] == nil {
                self.chatData[ci.stream_id] = ChatRoomDataSource()
            }
            
            let dataSource = self.chatData[ci.stream_id]!
            ci.status = true
            dataSource.updateItem(ci)
        })
    }
    
    func getChatDataForStream(stream_id : String) -> ChatRoomDataSource {
        if let chatRoom = chatData[stream_id] {
            return chatRoom
        } else {
            chatData[stream_id] = ChatRoomDataSource()
            var dict = [String : AnyObject]()
            dict["timestamp"] = NSDate().timeIntervalSince1970
            dict["stream_id"] = stream_id
            self.socket.emitWithAck("StreamChat", dict)(timeoutAfter: 0, callback: {
                (dataArr) in
            })
            return chatData[stream_id]!
        }
    }
    
    func newChatEntry(item: ChatItem, push : Bool? = true) {
     
        if chatData[item.stream_id] == nil {
            chatData[item.stream_id] = ChatRoomDataSource()
        }
        
        let dataSource = chatData[item.stream_id]!
        
        if let user = WCLUserManager.sharedInstance.findUser(item.user_id) {
            item.user = user
            if push! {
                dataSource.pushItem(item, completion : {
                })
            }
        } else {
            WCLUserManager.sharedInstance.findUser(item.user_id, cb: { (user) -> Void in
                item.user = user
                if push! {
                    dataSource.pushItem(item, completion : {
                    })
                }
            })
        }
    }
}

let _sharedChatManager : ChatManager = {
    return ChatManager()
}()