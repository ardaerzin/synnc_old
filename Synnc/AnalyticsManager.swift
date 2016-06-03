//
//  AnalyticsManager.swift
//  Synnc
//
//  Created by Arda Erzin on 3/10/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Crashlytics

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
    var customAttributes : [String : AnyObject]!
    
    init(){
        
    }
    static func new(category category : String, action: String, label: String!, value: NSNumber?, customAttributes : [String : AnyObject]? = nil){
        var event = AnalyticsEvent()
        event.category = category
        event.action = action
        event.label = label
        event.value = value
        event.customAttributes = customAttributes
        
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
                
                GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: ls.name)
                GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
            }
        }
    }
    
    func newScreen(screen : AnalyticsScreen){
        if let ls = self.screens.last {
            if let x = ls.node as? NSObject, let y = screen.node as? NSObject where x != y {
                self.screens.append(screen)
            } else if ls.node == nil {
                self.screens.append(screen)
            }
            
        } else {
            self.screens.append(screen)
        }
    }
    func newScreen(name : String) {
        var x = AnalyticsScreen()
        x.name = name
        self.screens.append(x)
    }
    
    func newEvent(event : AnalyticsEvent) {
        
       
        let dict = GAIDictionaryBuilder.createEventWithCategory(event.category, action: event.action, label: event.label, value: event.value).build() as [NSObject : AnyObject]
        GAI.sharedInstance().defaultTracker.send(dict)
        
        // Answers
        
        if event.category == "login_handler" {
            Answers.logLoginWithMethod(event.action, success: event.label == "true" ? 1 : 0, customAttributes: ["env" : isDev ? "dev" : "prod"])
        } else if event.category == "StreamAction" {
            Answers.logCustomEventWithName("Stream: \(event.action)", customAttributes: ["env" : isDev ? "dev" : "prod"])
        } else if event.category == "Share", let att = event.customAttributes {
            Answers.logShareWithMethod(event.action, contentName: att["contentName"] as? String, contentType: att["contentType"] as? String, contentId: att["contentId"] as? String, customAttributes: ["env" : isDev ? "dev" : "prod"])
        } else if event.action == "cell_tap" && event.label == "stream", let att = event.customAttributes {
            Answers.logContentViewWithName(att["contentName"] as? String, contentType: att["contentType"] as? String, contentId: att["contentId"] as? String, customAttributes: ["env" : isDev ? "dev" : "prod"])
        } else if event.category == "InvitationCallback" {
            Answers.logInviteWithMethod(event.action, customAttributes: ["env" : isDev ? "dev" : "prod"])
        }
    }
}