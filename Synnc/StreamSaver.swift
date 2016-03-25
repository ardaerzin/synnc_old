//
//  StreamSaver.swift
//  Synnc
//
//  Created by Arda Erzin on 2/25/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias StreamSaveBatch = (data : [JSON], completionHandler : ((streams : [Stream])->Void)?)

class BatchStreamSaver {
    
    var isLocked : Bool = false
    var batches : [StreamSaveBatch] = [] {
        didSet {
            if let batch = batches.first where !isLocked {
                self.isLocked = true
                self.saveBatch(batch)
            }
        }
    }
    var savedStreams : [Stream] = []
    class var sharedInstance : BatchStreamSaver {
        get {
            return _batchSaver
        }
    }
    init() {
        
    }
    
    func saveBatch(batch : StreamSaveBatch){
        var b = batch
        if let data = b.data.first {
            
            if let id = data["_id"].string {
                if let str = StreamManager.sharedInstance.findStream(id) {
                    
                    str.fromJSON(data, callback: {
                        stream in
                        
                        self.savedStreams.append(stream)
                        b.data.removeFirst()
                        
                        if b.data.isEmpty {
                            b.completionHandler?(streams: self.savedStreams)
                            self.savedStreams.removeAll()
                            
                            self.isLocked = false
                            self.batches.removeFirst()
                        } else {
                            self.saveBatch(b)
                        }
                    })
                } else {
                    let _ = Stream(json: data, delegate: StreamManager.sharedInstance, completionBlock: {
                        stream in
                        
                        StreamManager.sharedInstance.streams.append(stream)
                        self.savedStreams.append(stream)
                        b.data.removeFirst()
                        
                        if b.data.isEmpty {
                            b.completionHandler?(streams: self.savedStreams)
                            self.savedStreams.removeAll()
                            
                            self.isLocked = false
                            self.batches.removeFirst()
                        } else {
                            self.saveBatch(b)
                        }
                    })
                }
            }
        }
    }
}
let _batchSaver : BatchStreamSaver = {
    return BatchStreamSaver()
}()
