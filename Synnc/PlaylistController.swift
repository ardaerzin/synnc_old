//
//  CreatePlaylistController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/13/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager
import WCLPopupManager
import DKImagePickerController
import AssetsLibrary
import Cloudinary
import Shimmer
import WCLNotificationManager

class PlaylistController : ASViewController, WildAnimated {
    
    var editedTitle : String!
    var editedImage : UIImage! {
        didSet {
            if let pl = self.playlist {
                pl.coverImage = editedImage
            }
        }
    }
    
    var animator : WildTransitioning! = PlaylistAnimator()
    var displayStatusBar : Bool! = false
    
    var screenNode : PlaylistNode!
    var playlist : SynncPlaylist!
    var imagePicker : DKImagePickerController!
    
    override var editing : Bool {
        didSet {
            if editing != oldValue {
                if self.playlist != SharedPlaylistDataSource.findUserFavoritesPlaylist() {
                    self.screenNode.editing = editing
                }
            }
        }
    }
    
    var displayAnimatableProperty : POPAnimatableProperty {
        get {
            let x = POPAnimatableProperty.propertyWithName("displayAnimationProperty", initializer: {
                
                prop in
                
                prop.readBlock = {
                    obj, values in
                    values[0] = (obj as! PlaylistController).displayAnimationProgress
                }
                prop.writeBlock = {
                    obj, values in
                    (obj as! PlaylistController).displayAnimationProgress = values[0]
                }
                prop.threshold = 0.01
            }) as! POPAnimatableProperty
            
            return x
        }
    }
    var displayAnimation : POPBasicAnimation {
        get {
            if let anim = self.pop_animationForKey("displayAnimation") {
                return anim as! POPBasicAnimation
            } else {
                let x = POPBasicAnimation()
                x.duration = 0.5
                x.property = self.displayAnimatableProperty
                self.pop_addAnimation(x, forKey: "displayAnimation")
                return x
            }
        }
    }
    var displayAnimationProgress : CGFloat = 0 {
        didSet {
            let translationY = POPTransition(displayAnimationProgress, startValue: self.screenNode.calculatedSize.height, endValue: 0)
            POPLayerSetTranslationY(self.screenNode.layer, translationY)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        let x = true
        UIApplication.sharedApplication().statusBarHidden = x
        return x
    }
    
    var streamButton : ButtonNode!
    var editButton : ButtonNode!
    var isNewPlaylist : Bool = false
    
    init(playlist : SynncPlaylist?){
        let node = PlaylistNode(playlist: playlist)
        super.init(node: node)
        self.screenNode = node
        self.screenNode.underTabbar = true
        
        node.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if playlist == nil {
            self.playlist = SynncPlaylist.create(inContext: Synnc.sharedInstance.moc) as! SynncPlaylist
            self.playlist.user = Synnc.sharedInstance.user._id
            isNewPlaylist = true
            self.editing = true
            self.screenNode.editButton.selected = true
            self.screenNode.playlist = self.playlist
            self.screenNode.emptyState = true
        } else {
            self.playlist = playlist
            if self.playlist == SharedPlaylistDataSource.findUserFavoritesPlaylist() {
                self.screenNode.addSongsButton.hidden = true
            }
            if self.playlist.songs.isEmpty {
                self.screenNode.emptyState = true
            }
        }
        
        self.screenNode.tracksTable.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        
        node.playlistTitleNode.delegate = self
        (node.mainScrollNode.backgroundNode as! PlaylistBackgroundNode).imageSelector.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.addSongsButton.addTarget(self, action: Selector("displayTrackSearch:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.streamButton.addTarget(self, action: Selector("streamPlaylist:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.editButton.addTarget(self, action: Selector("toggleEditMode:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.headerNode.closeButton.addTarget(self, action: Selector("closeAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenNode.tracksTable.view.asyncDataSource = self
        self.screenNode.tracksTable.view.asyncDelegate = self
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.updateScrollSizes()
    }
    func updateScrollSizes(){
        
        let csh = max(self.screenNode.tracksTable.view.contentSize.height, self.screenNode.tracksTable.calculatedSize.height)
        let totalCs = csh + self.screenNode.mainScrollNode.backgroundNode.calculatedSize.height + 50
        if totalCs != self.screenNode.mainScrollNode.view.contentSize.height {
            self.screenNode.mainScrollNode.view.contentSize = CGSizeMake(self.view.frame.size.width, totalCs)
        }
    }
}
extension PlaylistController : ASTableViewDataSource {
    func tableView(tableView: ASTableView, nodeForRowAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let track = self.playlist.songs[indexPath.item]
        let node = PlaylistTableCell()
        node.configureForTrack(track)
        node.backgroundColor = UIColor.whiteColor()
        return node
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.songs.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.playlist.moveSong(sourceIndexPath, toIndexPath: destinationIndexPath)
        self.playlist.save()
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.editing
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            
            self.playlist.removeSong(atIndexPath: indexPath)
            updateScrollSizes()
            
            self.screenNode.updateTrackCount()
            
            self.screenNode.tracksTable.view.beginUpdates()
            self.screenNode.tracksTable.view.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.screenNode.tracksTable.view.endUpdates()
            break
        default:
            return
        }
        
        self.playlist.save()
        self.screenNode.setNeedsLayout()
    }
}
extension PlaylistController : ASTableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select song")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension PlaylistController : ParallaxNodeDelegate {
    func imageForBackground() -> (image: AnyObject?, viewMode: UIViewContentMode?) {
        if self.editedImage == nil {
            
            if let str = self.playlist.cover_id where str != "" {
                let transformation = CLTransformation()
                
                transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.crop = "fill"
                
                if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                    return (image: url, viewMode: nil)
                }
            }
            return (image: self.playlist.coverImage, viewMode: .Center)
        } else {
            return (image: self.editedImage, viewMode: nil)
        }
    }
    func gradientImageName() -> String? {
        return "imageGradient"
    }
}

extension PlaylistController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            return false
        }
        return true
    }
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {
        let str = editableTextNode.textView.text
        self.editedTitle = str
    }
}
extension PlaylistController {
    func closeAction(sender: ButtonNode) {
        self.navigationController?.popViewControllerAnimated(true)
        
        if isNewPlaylist {
            let vals = self.playlist.changedValues().keys
            if vals.indexOf("songs") == nil && vals.indexOf("name") == nil && vals.indexOf("cover_id") == nil {
                playlist.delete()
            }
        }
    }
    func toggleEditMode(sender : ButtonNode) {
        self.editing = !self.editing
        sender.selected = self.editing
        
        self.screenNode.tracksTable.view.setEditing(self.editing, animated: true)
        
        if !self.editing {
            self.saveChanges()
        }
        
    }
    func saveChanges(){
        guard let playlist = self.playlist else {
            return
        }
        
        if self.editedTitle != nil {
            playlist.name = self.editedTitle
            self.editedTitle = nil
        } else if playlist.name == nil {
            playlist.name = "Untitled Playlist"
        }
        
        if self.editedImage != nil {
            playlist.cover_id = ""
            playlist.coverImage = self.editedImage
            
            Synnc.sharedInstance.imageUploader = CLUploader(_cloudinary, delegate: nil)
            let data = UIImageJPEGRepresentation(self.editedImage, 1)
            let a = CLTransformation()
            a.angle = "exif"
            
            Synnc.sharedInstance.imageUploader.upload(data, options: ["transformation" : a], withCompletion: {
                (successResult, errorString, code, context)  in
                
                print("uploaded image")
                
                if let err = errorString {
                    print("err with upload", err)
                } else {
                    if let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                        
                        self.editedImage = nil
                        
                        let id = "image/upload/v\(v)/\(publicId).\(format)"
                        
                        self.playlist.cover_id = id
                        self.playlist.save()
                    }
                }
                
            }, andProgress: nil)
        }
        isNewPlaylist = false
        
        playlist.save()
        self.screenNode.fetchData()
    }
    func imageTap(sender : ButtonNode){
        imagePicker = SynncImagePicker()
        imagePicker.assetType = .AllPhotos
        imagePicker.maxSelectableCount = 1
        imagePicker.showsEmptyAlbums = false
        imagePicker.showsCancelButton = true
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
            
                img.fetchOriginalImageWithCompleteBlock {
                    image, info in
                    if let i = image {
                        
                        self.editedImage = i
                        self.screenNode.fetchData()
                    }
                }
            }
            
            self.screenNode.mainScrollNode.scrollViewDidScroll(self.screenNode.mainScrollNode.view)
        }
        self.parentViewController?.presentViewController(imagePicker, animated: true) {}
    }
}
extension PlaylistController {
    func displayTrackSearch(sender : ASButtonNode!) {
        let lc = TrackSearchController(size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size)
        lc.delegate = self
        WCLPopupManager.sharedInstance.newPopup(lc)
    }
    func streamPlaylist(sender : ASButtonNode){
        
        if self.playlist.songs.isEmpty {
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                
                let info = WCLNotificationInfo(defaultActionName: "", body: "Add Tracks to this playlist before streaming", title: "Invalid Playlist", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                    
                    [weak self]
                    notif in
                    
                    if self == nil {
                        return
                    }
                    
                    self?.displayTrackSearch(nil)
                }
                WCLNotificationManager.sharedInstance().newNotification(a, info: info)
            }
            
            return
        }
        
        Synnc.sharedInstance.streamNavigationController.displayStreamCreateController(self.playlist)
    }
}

extension PlaylistController : TrackSearchControllerDelegate {
    
    func updatedPlaylist(){
        self.screenNode.updateTrackCount()
        
        self.screenNode.updateTrackCount()
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        
        self.screenNode.emptyState = self.playlist.songs.isEmpty
    }
    
    func didSelectTrack(song: SynncTrack) {
        self.playlist.addSongs([song])
        self.saveChanges()
    }
    func didDeselectTrack(song: SynncTrack) {
        self.playlist.removeSongs([song])
        
        self.saveChanges()
    }
    func hasSong(song: SynncTrack) -> Bool{
        return self.playlist.hasTrack(song)
    }
}