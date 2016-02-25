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

protocol ChatRoomDataSourceDelegate {
    func constrainedSizeForChatItem() -> (min : CGSize, max: CGSize)
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
        var node : ChatItemNode
        self.tableView = tableView
        
        if let data = self.data[indexPath.item] as? ChatItem {
            if data.user == Synnc.sharedInstance.user {
                node = MyChatItemNode()
            } else {
                node = ChatItemNode()
            }
            
            node.configure(data)
        } else {
            node = ChatItemNode()
        }
        
        return node
    }
    
    func updateItem(item: ChatItem) {
        if let ind = self.data.indexOf(item) where ind >= 0, let table = tableView {
            if let node = table.nodeForRowAtIndexPath(NSIndexPath(forRow: ind, inSection: 0)) as? ChatItemNode where ind < tableView.numberOfRowsInSection(0) {
                node.configure(item)
            }
        }
    }
    func pushItem(item: ChatItem, completion : (()->Void)?) {
        self.pendingData = [item]
    }
    
}

class ChatManager : NSObject {
    
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
                Async.background {
                    for item in jsonArr! {
                        let ci = ChatItem()
                        ci.fromJSON(item)
                        Async.main {
                            self.newChatEntry(ci)
                        }
                    }
                }
            }
        }
    }
    
    func sendMessage(var dict: [String : AnyObject]){
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
            return chatData[stream_id]!
        }
    }
    
    func newChatEntry(item: ChatItem) {
     
        if chatData[item.stream_id] == nil {
            chatData[item.stream_id] = ChatRoomDataSource()
        }
        
        let dataSource = chatData[item.stream_id]!
        
        if let user = WCLUserManager.sharedInstance.findUser(item.user_id) {
            
            item.user = user
            dataSource.pushItem(item, completion : {
//                Async.main {
//                    self.delegate?.chatManager?(self, messageReceived: item)
//                }
            })
            
            
//            let prevItems = chatArray.filter({
//                return $0.timestamp.compare(item.timestamp) == NSComparisonResult.OrderedAscending
//            })
//            let newIndex = prevItems.count
            
//            item.user = user
//            chatData[item.stream_id]!.insert(item, atIndex: newIndex)
//            delegate?.chatManager?(self, messageReceived: item, atIndex: newIndex)
        } else {
            WCLUserManager.sharedInstance.findUser(item.user_id, cb: { (user) -> Void in
                item.user = user
                dataSource.pushItem(item, completion : {
//                    Async.main {
//                        self.delegate?.chatManager?(self, messageReceived: item)
//                    }
                })
            })
        }
    }
}

let _sharedChatManager : ChatManager = {
    return ChatManager()
}()