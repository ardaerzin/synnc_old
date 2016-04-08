//class PlaylistController : ASViewController {

//    var editedTitle : String!

//    var emptyState : Bool! {
//        didSet {
//            if emptyState != oldValue {
//                self.screenNode.emptyState = emptyState
//
//                if let e = emptyState where e {
//                    if self.playlist == SharedPlaylistDataSource.findUserFavoritesPlaylist() {
//                        self.screenNode.emptyStateNode.setText("Add Tracks to your favorites as you listen to them.", withAction: false)
//                    } else {
//                        self.screenNode.emptyStateNode.setText("This playlist does not contain any songs", withAction: true)
//                        self.screenNode.emptyStateNode.subTextNode.addTarget(self, action: #selector(PlaylistController.displayTrackSearch(_:)), forControlEvents: .TouchUpInside)
//                    }
//                } else {
//                    self.screenNode.emptyStateNode?.subTextNode.removeTarget(self, action: #selector(PlaylistController.displayTrackSearch(_:)), forControlEvents: .TouchUpInside)
//                }
//
//                self.screenNode.emptyStateNode?.setNeedsLayout()
//            }
//        }
//    }

//    var streamButton : ButtonNode!
//    var editButton : ButtonNode!
//
//    init(playlist : SynncPlaylist?){
//        let node = PlaylistNode(playlist: playlist)
//        super.init(node: node)
//        self.screenNode = node
//        self.screenNode.underTabbar = true
//
////        node.delegate = self
//
//        self.editing = true
//    }

//    func tableView(tableView: ASTableView, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath) {
//        let a = tableView.nodeForRowAtIndexPath(indexPath)
//        a.view.hidden = false
//    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if isNewPlaylist {
//            self.emptyState = true
//        } else {
//            if self.playlist == SharedPlaylistDataSource.findUserFavoritesPlaylist() {
//                self.screenNode.addSongsButton.hidden = true
//            }
//            if self.playlist.songs.isEmpty {
//                self.emptyState = true
//            }
//        }
//
//    }
//    func updateScrollSizes(){
//
//        let csh = max(self.screenNode.tracksTable.view.contentSize.height, self.screenNode.tracksTable.calculatedSize.height)
//        let totalCs = csh + self.screenNode.mainScrollNode.backgroundNode.calculatedSize.height + 50
//        if totalCs != self.screenNode.mainScrollNode.view.contentSize.height {
//            self.screenNode.mainScrollNode.view.contentSize = CGSizeMake(self.view.frame.size.width, totalCs)
//        }
//    }
//}

//
//extension PlaylistController : ASEditableTextNodeDelegate {
//    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if let _ = text.rangeOfString("\n") {
//            editableTextNode.resignFirstResponder()
//            return false
//        }
//        return true
//    }
//    func editableTextNodeDidUpdateText(editableTextNode: ASEditableTextNode) {
//        let str = editableTextNode.textView.text
//        self.editedTitle = str
//    }
//    func editableTextNodeDidFinishEditing(editableTextNode: ASEditableTextNode) {
//        self.saveChanges()
//    }
//}
//extension PlaylistController {
//    func closeAction(sender: ButtonNode) {
//        self.navigationController?.popViewControllerAnimated(true)
//
//        if isNewPlaylist {
//            let vals = self.playlist.changedValues().keys
//            if vals.indexOf("songs") == nil && vals.indexOf("name") == nil && vals.indexOf("cover_id") == nil {
//                playlist.delete()
//            }
//        }
//    }
//}

//extension PlaylistController {
//    func displayTrackSearch(sender : ASButtonNode!) {
//        let lc = TrackSearchController(size: CGRectInset(UIScreen.mainScreen().bounds, 0, 0).size)
//        lc.delegate = self
//        WCLPopupManager.sharedInstance.newPopup(lc)
//
//        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "trackSearch", value: nil)
//    }
//    func streamPlaylist(sender : ASButtonNode){
//
//        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "streamPlaylist", value: nil)
//
//        if self.playlist.songs.isEmpty {
//            if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
//
//                let info = WCLNotificationInfo(defaultActionName: "", body: "Add Tracks to this playlist before streaming", title: "Invalid Playlist", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
//
//                    [weak self]
//                    notif in
//
//                    if self == nil {
//                        return
//                    }
//
//                    self?.displayTrackSearch(nil)
//                }
//                WCLNotificationManager.sharedInstance().newNotification(a, info: info)
//            }
//
//            return
//        }
//
////        Synnc.sharedInstance.streamNavigationController.displayStreamCreateController(self.playlist)
//    }
//}

//extension PlaylistController : TrackSearchControllerDelegate {
//
//    func updatedPlaylist(){
//        self.screenNode.updateTrackCount()
//
//        self.screenNode.updateTrackCount()
//        self.screenNode.tracksTable.view.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
//
//        self.emptyState = self.playlist.songs.isEmpty
//    }
//    func hasSong(song: SynncTrack) -> Bool{
//        return self.playlist.hasTrack(song)
//    }
//}