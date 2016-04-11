//
//  PlaylistTracklistController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/25/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLPopupManager
import WCLNotificationManager

extension PlaylistTracklistController : TrackSearchControllerDelegate {
    func trackSearcher(controller: TrackSearchController, didSelect track: SynncTrack) {
        self.playlist!.addSongs([track])
        playlistUpdated()
        
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func trackSearcher(controller: TrackSearchController, hasTrack track: SynncTrack) -> Bool {
        return self.playlist!.hasTrack(track)
    }
    func trackSearcher(controller: TrackSearchController, didDeselect track: SynncTrack) {
        self.playlist!.removeSongs([track])
        playlistUpdated()
        
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
}

class PlaylistTracklistController : ASViewController, PagerSubcontroller {
    
    var editMode : Bool = false {
        didSet {
            self.screenNode.tracksTable.view.setEditing(editMode, animated: true)
        }
    }
    func toggleEditMode(sender : ButtonNode) {
        print("toggle edit mode")
        
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == self.playlist {
            
            Async.main {
                if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                    WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "You can't edit your active playlist.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                }
            }
            
            return
        }
        
        sender.selected = !sender.selected
        editMode = !editMode
    }
    func displayTrackSearch(sender : ASButtonNode!) {
        
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == self.playlist {
            
            Async.main {
                if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                    WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "You can't edit your active playlist.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil))
                }
            }
            return
        }
        
        let lc = TrackSearchController(size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size)
        lc.delegate = self
        WCLPopupManager.sharedInstance.newPopup(lc)
        
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "trackSearch", value: nil)
    }
    
    var emptyState : Bool! {
        didSet {
            if emptyState != oldValue {
                self.screenNode.emptyState = emptyState
                self.screenNode.emptyStateNode?.setText("This playlist does not contain any songs", withAction: true)
                self.screenNode.emptyStateNode?.subTextNode.addTarget(self, action: #selector(PlaylistTracklistController.displayTrackSearch(_:)), forControlEvents: .TouchUpInside)
                self.screenNode.emptyStateNode?.setNeedsLayout()
            }
        }
    }
    
    lazy var _leftHeaderIcon : ASControlNode! = {
        let x = ButtonNode()
        x.setImage(UIImage(named: "edit-icon"), forState: .Normal)
        x.setImage(UIImage(named: "edit-icon-selected"), forState: .Selected)
        x.addTarget(self, action: #selector(PlaylistTracklistController.toggleEditMode(_:)), forControlEvents: .TouchUpInside)
        return x
    }()
    var leftHeaderIcon : ASControlNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASControlNode! = {
        let x = ASImageNode()
        x.image = UIImage(named: "newPlaylist")
        x.contentMode = .Center
        x.addTarget(self, action: #selector(PlaylistTracklistController.displayTrackSearch(_:)), forControlEvents: .TouchUpInside)
        return x
    }()
    var rightHeaderIcon : ASControlNode! {
        get {
            return _rightHeaderIcon
        }
    }
    lazy var _titleItem : ASTextNode = {
        let x = ASTextNode()
        x.attributedString = NSAttributedString(string: "Track List", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor.whiteColor().colorWithAlphaComponent(0.27), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    var screenNode : PlaylistTracksNode!
    var playlist : SynncPlaylist? {
        get {
            if let parent = self.parentViewController as? PlaylistController, let pl = parent.playlist {
                return pl
            } else {
                return nil
            }
        }
    }
    
    init(){
        let n = PlaylistTracksNode()
        super.init(node: n)
        self.screenNode = n
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyState = self.playlist!.songs.isEmpty
        
        self.screenNode.tracksTable.view.asyncDataSource = self
        self.screenNode.tracksTable.view.asyncDelegate = self
    
        if let fav = SharedPlaylistDataSource.findUserFavoritesPlaylist() where playlist == fav {
            self.rightHeaderIcon.hidden = true
        }
    }
    
    func playlistUpdated(){
        
        playlist!.save()
        self.emptyState = self.playlist!.songs.isEmpty
        
        if let pvc = self.parentViewController as? PlaylistController {
            pvc.isNewPlaylist = false
            pvc.infoController.screenNode.recursivelyFetchData()
        }
    }
}


extension PlaylistTracklistController : ASTableViewDataSource {
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let track = self.playlist!.songs[indexPath.item]
        let node = PlaylistTableCell()
        node.configureForTrack(track)
        node.backgroundColor = UIColor.clearColor()
        return node
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist!.songs.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.playlist!.moveSong(sourceIndexPath, toIndexPath: destinationIndexPath)
        self.playlist!.save()
        
        AnalyticsEvent.new(category : "playlistAction", action: "moveTrack", label: nil, value: nil)
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            
            if let plist = self.playlist {
                plist.removeSong(atIndexPath: indexPath)
                playlistUpdated()
            }
            
            
            self.screenNode.tracksTable.view.beginUpdates()
            self.screenNode.tracksTable.view.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.screenNode.tracksTable.view.endUpdates()
            
            AnalyticsEvent.new(category : "playlistAction", action: "deleteTrack", label: "cell", value: nil)
            
            break
        default:
            return
        }
        
        self.playlist!.save()
        self.screenNode.setNeedsLayout()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.screenNode.scrollPosition = scrollView.contentOffset.y        
//        if let s = self.screenNode.tracksTable.view {
//            print("DID SCROLL", s.contentOffset.y, self.screenNode.calculatedSize.width - 100)
//            
//            if s.contentOffset.y  < -(self.screenNode.calculatedSize.width - 100) {
//                s.programaticScrollEnabled = false
//                s.panGestureRecognizer.enabled = false
//                s.programaticScrollEnabled = true
//                
//                let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
//                s.pop_addAnimation(animation, forKey: "offsetAnim")
//                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
//            } else {
//                s.panGestureRecognizer.enabled = true
//            }
//        }
    }
}


extension PlaylistTracklistController : ASTableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
