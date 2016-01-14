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
import Shimmer

class PlaylistController : ASViewController, WildAnimated {
    
    var editedTitle : String!
    var editedImage : UIImage!
    
    var animator : WildTransitioning! = PlaylistAnimator()
    var displayStatusBar : Bool! = false
    
    var screenNode : PlaylistNode!
    var playlist : SynncPlaylist!
    var imagePicker : DKImagePickerController!
    
    override var editing : Bool {
        didSet {
            if editing != oldValue {
                
                self.screenNode.editing = editing
                
//                self.screenNode.playlistTitleNode.userInteractionEnabled = editing
//                
//                self.screenNode.titleShimmer.shimmeringHighlightLength = 0.7
//                self.screenNode.titleShimmer.shimmeringPauseDuration = 0
//                
//                self.screenNode.titleShimmer.shimmering = editing
//                self.screenNode.imageNode.userInteractionEnabled = editing
//                self.screenNode.imageNode.enabled = editing
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        } else {
            self.playlist = playlist
        }
        
        self.screenNode.tracksTable.view.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        
        node.playlistTitleNode.delegate = self
        (node.mainScrollNode.backgroundNode as! PlaylistBackgroundNode).imageSelector.addTarget(self, action: Selector("imageTap:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.addSongsButton.addTarget(self, action: Selector("displayTrackSearch:"), forControlEvents: ASControlNodeEvent.TouchUpInside)
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
        
        let csh = self.screenNode.tracksTable.view.contentSize.height
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
    func imageForBackground() -> AnyObject? {
        if self.editedImage == nil {
            
            if let str = self.playlist.cover_id {
                let transformation = CLTransformation()
                
                transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.crop = "fill"
                
                if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                    return url
                }
            }
            return nil
        } else {
            return self.editedImage
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
                print("DELETE")
            }
        }
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
                let data = UIImageJPEGRepresentation(self.editedImage, 1)
                let a = CLTransformation()
                a.angle = "exif"
                Synnc.sharedInstance.imageUploader.upload(data, options: ["transformation" : a], withCompletion: {
//                    [unowned self]
                    (successResult, errorString, code, context)  in
                    
                    if let err = errorString {
                        print("err with upload", err)
                    } else {
                        if let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                            
                            let id = "image/upload/v\(v)/\(publicId).\(format)"
                            
                            playlist.cover_id = id
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
        self.playlist.addSongs([song])
        self.playlist.save()
        
        self.screenNode.updateTrackCount()
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func didDeselectTrack(song: SynncTrack) {
        self.playlist.removeSongs([song])
        self.playlist.save()
        
        self.screenNode.updateTrackCount()
        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
    func hasSong(song: SynncTrack) -> Bool{
        return self.playlist.hasTrack(song)
    }
}