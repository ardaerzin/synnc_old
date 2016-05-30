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
import Async
import Dollar

extension PlaylistTracklistController : TrackSearchControllerDelegate {
    func trackSearcher(controller: TrackSearchController, didSelect track: SynncTrack) {
//        self.playlist!.addSongs([track])
//        playlistUpdated()
//        
//        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func trackSearcher(controller: TrackSearchController, hasTrack track: SynncTrack) -> Bool {
        if let p = self.playlist {
            return p.hasTrack(track)
        } else {
            return false
        }
    }
    func trackSearcher(controller: TrackSearchController, didDeselect track: SynncTrack) {
//        self.playlist!.removeSongs([track])
//        playlistUpdated()
//        
//        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func trackSearcher(controller: TrackSearchController, updatedTracklist newList: [SynncTrack]) {
        let addedSongs = $.difference(newList, self.playlist!.songs)
        let removedSongs = $.difference(self.playlist!.songs, newList)
        
        self.playlist?.removeSongs(removedSongs)
        self.playlist?.addSongs(addedSongs)
        
        playlistUpdated()
        
        Async.main {
            self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
//        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
}

class PlaylistTracklistController : ASViewController, PagerSubcontroller {
    
    var editMode : Bool = false {
        didSet {
            self.screenNode.tracksTable.view.setEditing(editMode, animated: true)
        }
    }
    func displayTrackSearch(sender : ASButtonNode!) {
        
        guard let plist = self.playlist else {
            return
        }
        
        if !canDisplayTrackSearch() {
            
            Async.main {
                SynncNotification(body: ("You can't edit your active playlist.", "can't edit"), image: "notification-error").addToQueue()
            }
            return
        }
        
        let lc = TrackSearchController(size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size, playlist: plist)
        lc.becomeFirstResponder()
        lc.delegate = self
        WCLPopupManager.sharedInstance.newPopup(lc)
        
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "trackSearch", value: nil)
    }
    
    func canDisplayTrackSearch() -> Bool {
        if let activeStream = StreamManager.sharedInstance.activeStream where activeStream.playlist == self.playlist {
            return false
        }
        return true
    }
    
    var emptyState : Bool! {
        didSet {
            if emptyState != oldValue {
                Async.main {
                    self.screenNode.emptyState = self.emptyState
                    self.screenNode.emptyStateNode?.setText("This playlist does not contain any songs", withAction: true)
                    self.screenNode.emptyStateNode?.subTextNode.addTarget(self, action: #selector(PlaylistTracklistController.displayTrackSearch(_:)), forControlEvents: .TouchUpInside)
                    self.screenNode.emptyStateNode?.setNeedsLayout()
                }
            }
        }
    }
    
    lazy var _leftHeaderIcon : ASControlNode! = {
        return nil
    }()
    var leftHeaderIcon : ASControlNode! {
        get {
            return _leftHeaderIcon
        }
    }
    lazy var _rightHeaderIcon : ASControlNode! = {
        return nil
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistTracklistController.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
    }
    
    func checkActiveStream(notification : NSNotification) {
        if let plist = self.playlist, let stream = notification.object as? Stream where stream.playlist == plist && self.editMode {
            self.editMode = false
        }
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
            self.rightHeaderIcon?.hidden = true
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
        let node = SynncTrackNode(withIcon: false, withSource: true)
        node.configureForTrack(track)
        node.backgroundColor = .clearColor()
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
    }
}


extension PlaylistTracklistController : ASTableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
