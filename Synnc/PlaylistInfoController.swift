//
//  PlaylistInfoController.swift
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
import WCLLocationManager
import WCLNotificationManager
import Cloudinary
import DKImagePickerController

class PlaylistInfoController : ASViewController, PagerSubcontroller {
    
    lazy var _leftHeaderIcon : ASControlNode! = {
//        let x = ASImageNode()
//        x.image = UIImage(named: "trash-can")
//        x.contentMode = .Center
//        return x
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
        x.attributedString = NSAttributedString(string: "Playlist Info", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Medium", size: 16)!, NSForegroundColorAttributeName : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1), NSKernAttributeName : 0.5])
        return x
    }()
    var titleItem : ASTextNode! {
        get {
            return _titleItem
        }
    }
    var pageControlStyle : [String : UIColor]? {
        get {
            return [ "pageControlColor" : UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), "pageControlSelectedColor" : UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)]
        }
    }
    
    var imagePicker : DKImagePickerController!
    var editedTitle : String! {
        didSet {
            if let _ = editedTitle, let _ = self.playlist {
                saveChanges()
            }
        }
    }
    var uploadingImage : Bool = false
    var editedImage : UIImage! {
        didSet {
            if let _ = editedImage, let _ = self.playlist {
                saveChanges()
            }
        }
    }
    var playlist : SynncPlaylist? {
        get {
            if let parent = self.parentViewController as? PlaylistController, let pl = parent.playlist {
                return pl
            } else {
                return nil
            }
        }
    }
    var screenNode : PlaylistInfoHolder!
    
    init(playlist : SynncPlaylist){
        let n = PlaylistInfoHolder()
        super.init(node: n)
        self.screenNode = n
        n.infoNode.infoDelegate = self
        n.infoNode.titleNode.delegate = self
        
        screenNode.infoNode.genreHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.displayGenrePicker(_:)))
        screenNode.infoNode.locationHolder.tapGestureRecognizer.addTarget(self, action: #selector(PlaylistInfoController.toggleLocation(_:)))
        if playlist != SharedPlaylistDataSource.findUserFavoritesPlaylist() {
            screenNode.infoNode.imageNode.addTarget(self, action: #selector(PlaylistInfoController.displayImagePicker(_:)), forControlEvents: .TouchUpInside)
        }
        
//        self._leftHeaderIcon.addTarget(self, action: #selector(PlaylistInfoController.deletePlaylist(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenNode.infoNode.view.delegate = self
        screenNode.infoNode.addSongsButton.addTarget(self.parentViewController, action: #selector(PlaylistController.addSongs(_:)), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PlaylistInfoController.checkActiveStream(_:)), name: "DidSetActiveStream", object: nil)
    }
    
    func checkActiveStream(notification : NSNotification) {
        if let _ = notification.object as? Stream {
//            if playlist == stream.playlist {
//                self.screenNode.infoNode.imageNode.userInteractionEnabled = false
//                self.screenNode.infoNode.titleNode.userInteractionEnabled = false
//                self.screenNode.infoNode.genreHolder.userInteractionEnabled = false
//                self.screenNode.infoNode.locationHolder.userInteractionEnabled = false
//            } else {
//                self.screenNode.infoNode.imageNode.userInteractionEnabled = true
//                self.screenNode.infoNode.titleNode.userInteractionEnabled = true
//                self.screenNode.infoNode.genreHolder.userInteractionEnabled = true
//                self.screenNode.infoNode.locationHolder.userInteractionEnabled = true
//            }
        }
    }
    
    func displayImagePicker(sender : AnyObject){
        
        let oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsManager.sharedInstance.newScreen("Image Picker Playlist")
        AnalyticsEvent.new(category : "ui_action", action: "image_tap", label: "Playlist Info", value: nil)
        
        imagePicker = DKImagePickerController()
        imagePicker.assetType = .AllPhotos
        imagePicker.singleSelect = true
        imagePicker.showsEmptyAlbums = true
        imagePicker.showsCancelButton = true
        
        imagePicker.didCancel = {
            self.imagePicker = nil
            AnalyticsManager.sharedInstance.newScreen(oldScreen!)
        }
        imagePicker.didSelectAssets = {
            assets in
            if let img = assets.first {
                
                img.fetchOriginalImageWithCompleteBlock {
                    image, info in
                    if let i = image {
                        self.editedImage = i
                    }
                }
            }
            
            self.imagePicker = nil
            AnalyticsManager.sharedInstance.newScreen(oldScreen!)
        }
        
        self.parentViewController?.presentViewController(imagePicker, animated: true) {}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PlaylistInfoController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if let s = self.screenNode.infoNode.view {
            if s.contentOffset.y  < -50 {
                s.programaticScrollEnabled = false
                s.panGestureRecognizer.enabled = false
                s.programaticScrollEnabled = true
                
                let animation = POPBasicAnimation(propertyNamed: kPOPScrollViewContentOffset)
                s.pop_addAnimation(animation, forKey: "offsetAnim")
                animation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
            } else {
                s.panGestureRecognizer.enabled = true
            }
        }
    }
}

extension PlaylistInfoController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == (self.parentViewController as? PlaylistController)?.screenNode.pager.view.panGestureRecognizer {
            return false
        }
        return true
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.infoNode.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.screenNode.infoNode.view.panGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}

extension PlaylistInfoController : ASEditableTextNodeDelegate {
    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
        if editableTextNode != self.screenNode.infoNode.titleNode {
            return
        }
        if let str = editableTextNode.attributedText?.string {
            self.editedTitle = str
        }
    }
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            editableTextNode.resignFirstResponder()
            return false
        }
        return true
    }
}

extension PlaylistInfoController : PlaylistInfoDelegate {
    func imageForPlaylist() -> AnyObject? {
        
        guard let playlist = self.playlist else {
            return nil
        }
        
        if let fav = SharedPlaylistDataSource.findUserFavoritesPlaylist() where playlist == fav {
            return Synnc.appIcon
        }
        
        if self.editedImage == nil && playlist.coverImage == nil {
            
            if let str = playlist.cover_id where str != "" {
                let transformation = CLTransformation()
                
                transformation.width = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.height = self.view.frame.width * UIScreen.mainScreen().scale
                transformation.crop = "fill"
                
                if let x = _cloudinary.url(str, options: ["transformation" : transformation]), let url = NSURL(string: x) {
                    return url
                }
            }
        } else {
            var image : UIImage!
            if let img = self.editedImage {
                image = img
            } else if let img = playlist.coverImage {
                image = img
            }
            return image
        }
        
        return nil
    }
    func titleForPlaylist() -> String? {
        if let pl = self.playlist {
            return pl.name
        } else {
            return nil
        }
    }
    func genresForPlaylist() -> [Genre] {
        if let pl = self.playlist {
            return Array(pl.genres)
        } else {
            return []
        }
    }
    func locationForPlaylist() -> String? {
        if let pl = self.playlist {
            return pl.location
        } else {
            return nil
        }
    }
    func trackCountForPlaylist() -> Int {
        if let pl = self.playlist {
            self.screenNode.infoNode.addSongsButton.alpha = pl.songs.isEmpty ? 1 : 0
            return pl.songs.count
        } else {
            self.screenNode.infoNode.addSongsButton.alpha = 1
            return 0
        }
    }
    
    func saveChanges(){
        guard let playlist = self.playlist else {
            return
        }
        
        if self.editedTitle != nil && editedTitle != "" {
            playlist.name = self.editedTitle
            self.editedTitle = nil
            
            AnalyticsEvent.new(category : "playlistAction", action: "editInfo", label: "name", value: nil)
        } else if playlist.name == nil {
            playlist.name = ""
        }
        
        if self.editedImage != nil {
            AnalyticsEvent.new(category : "playlistAction", action: "editInfo", label: "image", value: nil)
            playlist.cover_id = ""
            playlist.coverImage = self.editedImage
            Synnc.sharedInstance.imageUploader = CLUploader(_cloudinary, delegate: nil)
            let data = UIImageJPEGRepresentation(self.editedImage, 1)
            let a = CLTransformation()
            a.angle = "exif"
            
            self.screenNode.infoNode.imageShimmer.shimmering = true
            self.editedImage = nil
            uploadingImage = true
            
            Synnc.sharedInstance.imageUploader.cancel()
            Synnc.sharedInstance.imageUploader.upload(data, options: ["transformation" : a], withCompletion: {
                (successResult, errorString, code, context)  in
                
                self.screenNode.infoNode.imageShimmer.shimmering = false
                
                if let _ = errorString {
                    AnalyticsEvent.new(category : "imageUpload", action: "error", label: "\(code)", value: nil)
                } else {
                    if let publicId = successResult["public_id"] as? String, let v = successResult["version"] as? NSNumber, let format =  successResult["format"] as? String{
                        
                        let id = "image/upload/v\(v)/\(publicId).\(format)"
                        
                        self.playlist?.cover_id = id
                    }
                }
                
                self.playlist?.save()
                self.uploadingImage = false
                
                }, andProgress: nil)
        }
        
        playlist.save()
        
        if let parent = self.parentViewController as? PlaylistController{
            parent.isNewPlaylist = false
            parent.tracklistController.screenNode.recursivelyFetchData()
        }
        self.screenNode.recursivelyFetchData()
        self.screenNode.infoNode.setNeedsLayout()
        
    }

}

extension PlaylistInfoController {
    func displayGenrePicker(sender: AnyObject) {
        let rect = CGRectInset(self.view.frame, 12, 15)
        
        let genres = Array(self.playlist!.genres)
        let popup = GenrePicker(size: rect.size, genres : genres)
        popup.delegate = self
        WCLPopupManager.sharedInstance.newPopup(popup)
    }
    func toggleLocation(sender: AnyObject) {
        AnalyticsEvent.new(category: "StreamAction", action: "infoToggle", label: "location", value: nil)
        let managerStatus = WCLLocationManager.sharedInstance().locationMngrStatus
        switch managerStatus {
        case -1:
            
            let s = Synnc.sharedInstance
            let controller = s.locationAuthController()
            controller.callback = {
                success in
//                if !sender.selected {
                    self.getAddress()
//                } else {
//                    self.backgroundNode.updateLocation(status: false)
//                }
            }
            s.locationManager.requestLocationPermission(controller)
            
            break
        case 0:
            
            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
                WCLNotificationManager.sharedInstance().newNotification(a, info: WCLNotificationInfo(defaultActionName: "", body: "Please go to iOS settings and enable location support for Synnc.", title: "Location Error", sound: nil, fireDate: nil, showLocalNotification: false, object: nil, id: nil))
            }
            return
            
        case 1 :
            
//            if !sender.selected {
                self.getAddress()
//            } else {
//                self.backgroundNode.updateLocation(status: false)
//            }
            
            break
        default :
            return
        }
    }
    
    func getAddress(){
        AnalyticsEvent.new(category: "PlaylistAction", action: "infoEdit", label: "location", value: nil)
        let location = WCLLocationManager.sharedInstance().getCurrentLocation()
        
        WCLLocationManager.sharedInstance().gpsManager.reverseGeocodeLocationUsingGoogleWithCoordinates(location, callback: { (address, error) -> Void in
            if let ad = address {
                if let sublocality = ad.subLocalities.first, let sub = sublocality {
                    self.playlist!.location = sub + " / " + (ad.locality!)
                } else if let subAdmin = ad.administrativeAreas[1] where ad.administrativeAreas.count > 2 {
                    self.playlist!.location = subAdmin + " / " + (ad.locality!)
                }
                Async.main {
                    self.saveChanges()
                }
            }
        })
    }
}

extension PlaylistInfoController : GenrePickerDelegate {
    func genrePicker(picker: GenrePicker, dismissedWithGenres genres: [Genre]) {
        
        AnalyticsEvent.new(category: "PlaylistAction", action: "infoEdit", label: "genre", value: nil)
        
        print("selected genres:", genres)
        
        self.playlist!.genres = Set(genres)
        saveChanges()
    }
}