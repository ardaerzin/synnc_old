//
//  AnalyticsManager.swift
//  Synnc
//
//  Created by Arda Erzin on 3/10/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol TrackedView {
    var title : String! {get}
}

protocol AnalyticsItem {
    static func new()
}
struct AnalyticsScreen {
    var name : String!
    var node : TrackedView!

    init(){
        
    }
    static func new(node node : TrackedView){
        var screen = AnalyticsScreen()
        screen.node = node
        screen.name = node.title
        AnalyticsManager.sharedInstance.newScreen(screen)
    }
}
struct AnalyticsEvent {
    var category : String!
    var action : String!
    var label : String!
    var value : NSNumber!
    
    init(){
        
    }
    static func new(category category : String, action: String, label: String!, value: NSNumber?){
        var event = AnalyticsEvent()
        event.category = category
        event.action = action
        event.label = label
        event.value = value
        
        AnalyticsManager.sharedInstance.newEvent(event)
    }
}

class AnalyticsManager {
    class var sharedInstance : AnalyticsManager {
        
        struct Static {
            static let instance : AnalyticsManager = AnalyticsManager()
        }
        
        return Static.instance
    }
    
    
    var screens : [AnalyticsScreen] = [] {
        didSet {
            if let ls = self.screens.last {
                print("appended screen", ls.name)
                GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: ls.name)
                GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
            }
        }
    }
    
    func newScreen(screen : AnalyticsScreen){
        if let ls = self.screens.last {
            if let x = ls.node as? NSObject, let y = screen.node as? NSObject where x != y {
                self.screens.append(screen)
            }
            
        } else {
            self.screens.append(screen)
        }
    }
    
    func newEvent(event : AnalyticsEvent) {
        
        print("new event", event)
        let dict = GAIDictionaryBuilder.createEventWithCategory(event.category, action: event.action, label: event.label, value: event.value).build() as [NSObject : AnyObject]
        GAI.sharedInstance().defaultTracker.send(dict)
        
    }
}