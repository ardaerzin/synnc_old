//
//  MainUser.swift
//  RadioHunt
//
//  Created by Arda Erzin on 8/12/15.
//  Copyright (c) 2015 Arda Erzin. All rights reserved.
//

import Foundation
import WCLUserManager
import Socket_IO_Client_Swift
import FBSDKCoreKit
import SwiftyJSON
import WCLUtilities

class MainUser : WCLUser {
    
    var generatedUsername : Bool = false
    var joinedUsers : [String] = []
    
    convenience init(socket: SocketIOClient) {
        self.init(alternatives: [
            .Facebook : [.withSession, .authServer],
            .Twitter : [.withSession, .authServer],
            .Spotify : [.withSession],
            .Soundcloud : [.withSession]
        ])
        self.withSocket(socket)
        self.needsToNotify = true
    }
    
    func isFollowing(user: WCLUser) -> Bool {
        return false
    }
    override func didChangeFollowers(newFollowers added: [WCLUser], removedFollowers removed: [WCLUser]) {
        super.didChangeFollowers(newFollowers: added, removedFollowers: removed)
        
//        for user in added {
//            self.joinUserRoom(user._id, callback: nil)
//        }
//        for user in removed {
//            self.leaveUserRoom(user._id, callback: nil)
//        }
    }
    override func didChangeFollowings(followingNew added: [WCLUser], followingNoMore removed: [WCLUser]) {
        
        super.didChangeFollowings(followingNew: added, followingNoMore: removed)
        for user in added {
            print(user._id)
            self.joinUserRoom(user._id, callback: nil)
        }
        for user in removed {
            self.leaveUserRoom(user._id, callback: nil)
        }
    }
    
    func leaveUserRoom(id : String, callback : ((status:Bool)->Void)?){
        if self.joinedUsers.indexOf(id) == nil {
            WCLUserManager.sharedInstance().socket.emitWithAck("user:leave", id)(timeoutAfter: 0) {
                ack in
                guard let status = ack.first as? Bool else {
                    callback?(status: false)
                    return
                }
                if self.joinedUsers.indexOf(id) == nil {
                    self.joinedUsers.append(id)
                }
                callback?(status: status)
            }
        } else {
            callback?(status: true)
        }
    }
    func joinUserRoom(id : String, callback : ((status:Bool)->Void)?){
        if self.joinedUsers.indexOf(id) == nil {
            WCLUserManager.sharedInstance().socket.emitWithAck("user:join", id)(timeoutAfter: 0) {
                ack in
                guard let status = ack.first as? Bool else {
                    callback?(status: false)
                    return
                }
                
                if self.joinedUsers.indexOf(id) == nil {
                    self.joinedUsers.append(id)
                }
                callback?(status: status)
            }
        } else {
            callback?(status: true)
        }
    }
    
    override func userLoginStatusChanged() {
        super.userLoginStatusChanged()
        
        if self.status {
            self.syncFollowed()
        }
    }
    
}