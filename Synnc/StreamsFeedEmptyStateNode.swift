//
//  StreamsFeedEmptyStateNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

class StreamsFeedEmptyStateNode : EmptyStateNode {
    
    var activeState : Bool = false {
        didSet {
            let msg = activeState ? "No others are Synnc'ing." : "There are no active streams now."
            
            self.setMessage(msg)
            self.actionButton.hidden = activeState
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override init(){
        super.init()
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamsFeedEmptyStateNode.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        let att = [NSFontAttributeName : UIFont(name: "Ubuntu", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSParagraphStyleAttributeName : p]
        self.actionButton.setAttributedTitle(NSAttributedString(string: "Create a Stream", attributes:  att), forState: .Normal)
        self.actionButton.cornerRadius = 8
        
        self.checkActiveStream(nil)
    }
    
    func checkActiveStream(notification : NSNotification!) {
        
        if let userStream = StreamManager.sharedInstance.userStream, let activeStream = StreamManager.sharedInstance.activeStream where userStream == activeStream {
            self.activeState = true
        } else {
            self.activeState = false
        }
        
        self.setNeedsLayout()
        
    }
    
    override func fetchData() {
        super.fetchData()
        
        self.setNeedsLayout()
    }
}