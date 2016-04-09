//
//  StreamTracklistController.swift
//  Synnc
//
//  Created by Arda Erzin on 3/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLPopupManager
import WCLLocationManager
import WCLNotificationManager
import Cloudinary
import DKImagePickerController

class StreamTracklistController : ASViewController, PagerSubcontroller {
    
    
    var currentIndex : Int = 0 {
        didSet {
            (self.node as! StreamTracklistNode).tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
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
            return nil
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor.whiteColor()]
        }
    }
    
    
    init(){
        let n = StreamTracklistNode()
        super.init(node: n)
        //        self.screenNode = n
        //        n.infoNode.infoDelegate = self
        //        n.infoNode.titleNode.delegate = self
        //
        //        screenNode.infoNode.genreHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.displayGenrePicker(_:)))
        //        screenNode.infoNode.locationHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.toggleLocation(_:)))
        //        screenNode.infoNode.imageNode.addTarget(self, action: #selector(PlaylistInfoController.displayImagePicker(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableNode = (self.node as! StreamTracklistNode).tracksTable
        tableNode.view.asyncDelegate = self
        tableNode.view.asyncDataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func trackAtIndex(index: Int) -> SynncTrack? {
        if let pvc = self.parentViewController as? StreamVC, let stream = pvc.stream {
            return stream.playlist.songs[index]
        }
        return nil
    }
}

extension StreamTracklistController : ASTableViewDataSource {
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        
        let node = PlaylistTableCell()
        if let track = self.trackAtIndex(indexPath.item) {
            node.configureForTrack(track)
        }
        node.backgroundColor = UIColor.clearColor()
        return node
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentIndex == 0 {
            (self.node as! StreamTracklistNode).emptyState = true
        } else {
            (self.node as! StreamTracklistNode).emptyState = false
        }
        return currentIndex
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        self.playlist!.moveSong(sourceIndexPath, toIndexPath: destinationIndexPath)
//        self.playlist!.save()
//        AnalyticsEvent.new(category : "playlistAction", action: "moveTrack", label: nil, value: nil)
    }
}


extension StreamTracklistController : ASTableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let pvc = self.parentViewController as?  StreamVC {
            pvc.updateScrollPosition(scrollView.contentOffset.y)
        }
    }
}



class StreamTracklistEmptyStateNode : ASDisplayNode {
    
    var msgNode : ASTextNode!
    
    override init() {
        super.init()
        
        let p = NSMutableParagraphStyle()
        p.alignment = .Center
        
        msgNode = ASTextNode()
        msgNode.attributedString = NSAttributedString(string: "This stream has \nno previous tracks", attributes: [NSFontAttributeName: UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5, NSParagraphStyleAttributeName : p])
        
        self.addSubnode(msgNode)
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [msgNode])
    }
}

class StreamTracklistNode : ASDisplayNode, TrackedView {
    
    var emptyStateNode : StreamTracklistEmptyStateNode!
    var emptyState : Bool = false {
        didSet {
            if emptyState != oldValue {
                if self.emptyStateNode == nil {
                    emptyStateNode = StreamTracklistEmptyStateNode()
                }
                if emptyState {
                    self.addSubnode(emptyStateNode)
                } else {
                    emptyStateNode.removeFromSupernode()
                    emptyStateNode = nil
                }
                self.setNeedsLayout()
            }
        }
    }
    
    var title: String! = "Stream Tracklist"
    var tracksTable : WCLTableNode!
    
    override init() {
        super.init()
        
        tracksTable = WCLTableNode(style: UITableViewStyle.Plain)
        tracksTable.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
        self.addSubnode(tracksTable)
        tracksTable.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    override func didLoad() {
        super.didLoad()
        
        tracksTable.view.tableFooterView = UIView(frame: CGRectZero)
        tracksTable.view.tableHeaderView = UIView(frame: CGRectMake(0, 0, 1, 100))
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let a = ASStaticLayoutSpec(children: [tracksTable])
        return ASOverlayLayoutSpec(child: a, overlay: emptyStateNode)
    }
}