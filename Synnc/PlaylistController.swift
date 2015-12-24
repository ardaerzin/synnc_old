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
import SpinKit
import WCLUserManager
import DeviceKit
import WCLPopupManager
import DKImagePickerController
import AssetsLibrary
import Cloudinary

class PlaylistController : ASViewController {
    
    var editedTitle : String!
    var editedImage : UIImage!
    
    var screenNode : PlaylistNode!
    var playlist : SynncPlaylist!
    var imagePicker : DKImagePickerController!
    
    override var editing : Bool {
        didSet {
            if editing != oldValue {
                self.screenNode.playlistTitleNode.userInteractionEnabled = editing
                self.screenNode.imageNode.userInteractionEnabled = editing
                self.screenNode.imageNode.enabled = editing
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let rvc = self.rootViewController {
            rvc.displayStatusBar = false
        }
    }
    init(playlist : SynncPlaylist?){
        let node = PlaylistNode(playlist: playlist)
        super.init(node: node)
        self.screenNode = node
        node.delegate = self
        if playlist == nil {
            self.playlist = SynncPlaylist.create(inContext: Synnc.sharedInstance.moc) as! SynncPlaylist
            self.playlist.user = Synnc.sharedInstance.user._id
            self.editing = true
            self.screenNode.editButton.selected = true
        } else {
            self.playlist = playlist
        }
        self.screenNode.playlist = self.playlist
        
        self.screenNode.tracksTable.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        
//        self.screenNode.mainScrollNode.view.delegate = self
        node.playlistTitleNode.delegate = self
        node.imageNode.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.addSongsButton.addTarget(self, action: Selector("displayTrackSearch:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.editButton.addTarget(self, action: Selector("toggleEditMode:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.headerNode.closeButton.addTarget(self, action: Selector("closeAction:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenNode.tracksTable.view.asyncDataSource = self
        self.screenNode.tracksTable.view.asyncDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateScrollSizes()
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.updateScrollSizes()
    }
    func updateScrollSizes(){
        
        let csh = self.screenNode.tracksTable.view.contentSize.height
        let totalCs = csh + self.screenNode.mainScrollNode.backgroundNode.calculatedSize.height + 50
//            + 50
        if totalCs != self.screenNode.mainScrollNode.view.contentSize.height {
            self.screenNode.mainScrollNode.view.contentSize = CGSizeMake(self.view.frame.size.width, totalCs)
        }
    }
}
extension PlaylistController : ASTableViewDataSource {
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let track = self.playlist.songs[indexPath.item]
        let node = PlaylistTableCell()
        node.configureForTrack(track)
        node.backgroundColor = UIColor.whiteColor()
        return node
    }
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.songs.count
    }
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    func tableView(tableView: UITableView!, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return false
    }
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!) {
        self.playlist.moveSong(sourceIndexPath, toIndexPath: destinationIndexPath)
        self.playlist.save()
    }
}
extension PlaylistController : ASTableViewDelegate {
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        print("did select song")
    }
}
extension PlaylistController : PlaylistNodeDelegate {
    func imageForPlaylist() -> AnyObject? {
        if self.editedImage == nil {
            if let urlStr = playlist.cover_url {
                return NSURL(string: urlStr)
            }
            return nil
        } else {
            return self.editedImage
        }
    }
}
extension PlaylistController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            return false
        }
//        if let fieldStr = editableTextNode.textView.text {
//            var str = (fieldStr as NSString).stringByReplacingCharactersInRange(range, withString: text)
//            str = (str as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
//        }
        return true
    }
    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode!) {
        let str = editableTextNode.textView.text
        self.editedTitle = str
    }
}
extension PlaylistController {
    func closeAction(sender: ButtonNode) {
        if let rvc = self.rootViewController {
            rvc.displayStatusBar = true
        }
        self.displayAnimation.toValue = 0
    }
    func toggleEditMode(sender : ButtonNode) {
        self.editing = !self.editing
        sender.selected = self.editing
        
        let playlist = self.playlist
        if !self.editing {
            if self.editedTitle != nil {
                self.playlist.name = self.editedTitle
            }
            if self.editedImage != nil {
                Synnc.sharedInstance.imageUploader = CLUploader(_cloudinary, delegate: nil)
                let data = UIImagePNGRepresentation(self.editedImage)
                Synnc.sharedInstance.imageUploader.upload(data, options: nil, withCompletion: {
                    [unowned self]
                    (successResult, errorString, code, context)  in
                    
                    if let err = errorString {
                        print("err with upload", err)
                    } else {
                        if let url = successResult["secure_url"] as? String {
                            playlist.cover_url = url
                            playlist.save()
                        }
                    }
                    
                }, andProgress: nil)
            }

            self.playlist.save()
        }
        
        self.screenNode.tracksTable.view.setEditing(self.editing, animated: true)
    }
    func imageTap(sender : ButtonNode){
        imagePicker = SynncImagePicker()
        imagePicker.assetType = .AllPhotos
        imagePicker.showsEmptyAlbums = false
        imagePicker.showsCancelButton = true
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
                img.fetchFullScreenImageWithCompleteBlock {
                    i in
                    if let img = i {
                        self.editedImage = img
                        self.screenNode.imageNode.image = self.editedImage
                    }
                }
            }
        }
        self.parentViewController?.presentViewController(imagePicker, animated: true) {}
    }
}
extension PlaylistController {
    func displayTrackSearch(sender : ASButtonNode) {
        let lc = TrackSearchController()
        lc.delegate = self
        
        let opts = WCLPopupAnimationOptions(fromLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Bottom), toLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Center), withShadow: true)
        let x = WCLPopupViewController(nibName: nil, bundle: nil, options: opts, size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size)
        x.addChildViewController(lc)
        lc.view.frame = x.view.bounds
        x.view.addSubview(lc.view)
        lc.didMoveToParentViewController(x)
        
        WCLPopupManager.sharedInstance.newPopup(x)
    }
}

extension PlaylistController : TrackSearchControllerDelegate {
    func didSelectTrack(song: SynncTrack) {
        print("add song to playlist")
        
        self.playlist.addSongs([song])
        self.playlist.save()
        
        self.screenNode.updateTrackCount()
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func didDeselectTrack(song: SynncTrack) {
        print("remove song from playlist")
        
        self.playlist.removeSongs([song])
        self.playlist.save()
        
        self.screenNode.updateTrackCount()
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func hasSong(song: SynncTrack) -> Bool{
        return self.playlist.hasTrack(song)
    }
}