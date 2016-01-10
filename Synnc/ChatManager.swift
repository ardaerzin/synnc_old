//
//  StreamChatManager.swift
//  Synnc
//
//  Created by Arda Erzin on 1/7/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import WCLUtilities
import WCLUserManager
import SwiftyJSON
import AsyncDisplayKit
import WCLUIKit

class ChatItem : Serializable {
    var message: String!
    var timestamp : NSDate = NSDate()
    var user_id : String!
    var stream_id : String!
    var user : WCLUser!
    
    required init() {
        super.init()
    }
    
    override func fromJSON(json: JSON) -> [String] {
        let x = super.fromJSON(json)
        self.timestamp = NSDate(timeIntervalSince1970: json["timestamp"].double! / 1000 )
        return x
    }
}

//@objc protocol ChatManagerDelegate {
//    optional func chatManager(manager: ChatManager, messageReceived message: ChatItem)
//}
protocol ChatRoomDataSourceDelegate {
    func constrainedSizeForChatItem() -> (min : CGSize, max: CGSize)
}
class ChatRoomDataSource : WCLAsyncTableViewDataSource {
    var roomDelegate : ChatRoomDataSourceDelegate?
    
    
//    override func flushPendingData() {
//        var data : [NSObject] = []
//        let oldData = self.data
//        let nData = self.pendingData
//        if nData.isEmpty {
//            return
//        }
//        if !dataSourceLocked {
//            self._pendingData.removeAll(keepCapacity: false)
//            if self.refresh {
//                data = nData
//            } else {
//                data = oldData + nData
//            }
//            self.dataSourceLocked = true
//        } else {
//            return
//        }
//        print("yo")
//        Async.background {
//            if var chatData = data as? [ChatItem] where !data.isEmpty {
//                chatData.sortInPlace { $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending }
////                if !self.dataSourceLocked {
//                print("za")
//                    self.processPendingData(oldData, newData: data)
////                }
//            }
//        }
//    }
    
//    override func doFlushData(oldData: [NSObject], pendingData: [NSObject]) {
//        var d : [NSObject] = []
//        if self.refresh {
//            d = _pendingData
//        } else {
//            d = oldData + pendingData
//        }
//        Async.background {
//            if var chatData = data as? [ChatItem] where !data.isEmpty {
//                chatData.sortInPlace { $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending }
//                //                if !self.dataSourceLocked {
//                print("za")
//                self.processPendingData(oldData, newData: data)
//                //                }
//            }
//        }
//
//        self.processPendingData(oldData, newData: d)
//    }
    
    override func processPendingData(oldData: [NSObject], newData: [NSObject]) {
        Async.background {
            if var chatData = newData as? [ChatItem] where !newData.isEmpty {
                chatData.sortInPlace { $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending }
                //                if !self.dataSourceLocked {
                print("za")
                self.processPendingData(oldData, newData: chatData)
                //                }
            }
        }

    }
    
    override func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = ChatItemNode()
        if let data = self.data[indexPath.item] as? ChatItem {
            node.configure(data)
        }
        
        return node
    }
    
//    override func collectionView(collectionView: ASCollectionView!, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath!) -> ASSizeRange {
//        if let size = self.delegate?.asyncCollectionViewDataSource(self, constrainedSizeForNodeAtIndexPath: indexPath) {
//            return ASSizeRange(min: size.min, max: size.max)
//        }
//        return ASSizeRange(min: CGSizeZero, max: CGSizeZero)
//    }
//    override func collectionView(collectionView: ASCollectionView!, nodeForItemAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
//        let node = ChatItemNode()
//        if let data = self.data[indexPath.item] as? ChatItem {
//            node.configure(data)
//        }
//        return node
//    }
    func pushItem(item: ChatItem, completion : (()->Void)?) {
//        var a = self.pendingData
//        a.append(item)
        self.pendingData = [item]
        
        print("push item")
//        if let _ = data.indexOf(item) {
//            return
//        }
//        Async.background {
//            self.data.sortInPlace { $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedAscending }
//            completion?()
//        }
        
    }
    
}

class ChatItemNode : ASCellNode {
    
    var imageNode : ASNetworkImageNode!
    var textNode : ASTextNode!
    var timeNode : ASTextNode!
    
    //Data
    var messageString : String!
    var messageUserAvatar : NSURL!
    var timeString : String!
    
    override init(){
        super.init()
        
        imageNode = ASNetworkImageNode(webImage: ())
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(40, 40))
        
        textNode = ASTextNode()
        textNode.flexGrow = true
        textNode.alignSelf = .Stretch
        
        timeNode = ASTextNode()
        timeNode.spacingAfter = 6
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.addSubnode(imageNode)
        self.addSubnode(textNode)
        self.addSubnode(timeNode)
    }
    
    override func layout() {
        super.layout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASStaticLayoutSpec(children: [self.imageNode])
        imageSpec.spacingBefore = 20
        
        timeNode.flexBasis = ASRelativeDimension(type: .Points, value: 36)
        self.textNode.flexBasis = ASRelativeDimension(type: .Points, value: constrainedSize.max.width - 40 - 36 - 10 - 10 - 20 - 6)
        
//        let vStack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [self.textNode])
//        vStack.flexGrow = true
//        vStack.alignSelf = .Stretch
        
        let x = ASStackLayoutSpec(direction: .Horizontal, spacing: 10, justifyContent: .Start, alignItems: .Start, children: [imageSpec, textNode, timeNode])
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0), child: x)
    }
    override func fetchData() {
        super.fetchData()
        self.imageNode.URL = messageUserAvatar
        if let msg = self.messageString {
            self.textNode.attributedString = NSAttributedString(string: msg, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size: 12)!, NSKernAttributeName : -0.1, NSForegroundColorAttributeName : UIColor(red: 95/255, green: 95/255, blue: 95/255, alpha: 1)])
        }
        if let date = self.timeString {
            self.timeNode.attributedString = NSAttributedString(string: date, attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 9)!, NSForegroundColorAttributeName : UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)])
        }
    }
    func configure(item: ChatItem){
        self.messageString = item.message.stringByRemovingPercentEncoding
        self.messageUserAvatar = item.user.avatarURL(WCLUserLoginType(rawValue: item.user.provider)!, frame: CGRectMake(0, 0, 40, 40), scale: UIScreen.mainScreen().scale)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.timeString = formatter.stringFromDate(NSDate())
        self.fetchData()
    }
}

class ChatManager : NSObject {
    
//    var delegate : ChatManagerDelegate?
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
        self.socket.emitWithAck("StreamChat:message", dict)(timeoutAfter: 0, callback: {
            (dataArr) in
            if let err = dataArr.first, let isErr = JSON(err).bool where isErr {
                print("err with chat", err)
            }
            
            if let data = dataArr.last {
                let json = JSON(data)
                let ci = ChatItem()
                ci.fromJSON(json)
                self.newChatEntry(ci)
            }
        })
    }
    
    func getChatDataForStream(stream_id : String) -> ChatRoomDataSource {
        if let chatRoom = chatData[stream_id] {
            return chatRoom
        } else {
            chatData[stream_id] = ChatRoomDataSource()
            return chatData[stream_id]!
        }
//        let chatRoom = chatData[stream_id] == nil ? [] : chatData[stream_id]!
//        return chatRoom
    }
    
    func newChatEntry(item: ChatItem) {
        
//        if Synnc.sharedInstance.streamManager.activeStream == nil || chatData[item.stream_id] == nil || item.stream_id != Synnc.sharedInstance.streamManager.activeStream!.o_id {
//            chatData[item.stream_id] = []
//        }
//        
//        let chatArray = chatData[item.stream_id]!
        

        if chatData[item.stream_id] == nil {
            chatData[item.stream_id] = ChatRoomDataSource()
        }
        
        let dataSource = chatData[item.stream_id]!
        
        if let user = WCLUserManager.sharedInstance().findUser(item.user_id) {
            
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
            WCLUserManager.sharedInstance().findUser(item.user_id, cb: { (user) -> Void in
                item.user = user
                dataSource.pushItem(item, completion : {
//                    Async.main {
//                        self.delegate?.chatManager?(self, messageReceived: item)
//                    }
                })
                
                
//                let prevItems = chatArray.filter({
//                    return $0.timestamp.compare(item.timestamp) == NSComparisonResult.OrderedAscending
//                })
//                let newIndex = prevItems.count
//                item.user = user
//                self.chatData[item.stream_id]!.insert(item, atIndex: newIndex)
//                self.delegate?.chatManager?(self, messageReceived: item, atIndex: newIndex)
            })
        }
    }
}

let _sharedChatManager : ChatManager = {
    return ChatManager()
    }()