//
//  TrackSearchController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/14/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager
import WCLSoundCloudKit
import WCLPopupManager
import WCLDataManager
import WCLNotificationManager

enum EntityType : String {
    case Artist = "artist"
    case Track = "track"
}

protocol TrackSearchControllerDelegate {
    func trackSearcher(controller : TrackSearchController, hasTrack track : SynncTrack) -> Bool
    func trackSearcher(controller : TrackSearchController, didSelect track : SynncTrack)
    func trackSearcher(controller : TrackSearchController, didDeselect track : SynncTrack)
}

class TrackSearchController : WCLPopupViewController {
    
    var queryString_artists : String = ""
    var queryString_tracks : String = ""
    
    var screenNode : TrackSearchNode!
    
    var last_search : NSDate!
    var delegate : TrackSearchControllerDelegate?
    
    var artistsDataSource = ArtistSearchDataSource()
    var tracksDataSource = TrackSearchDataSource()
    
    var artistsManager : WCLCollectionViewManager = WCLCollectionViewManager()
    var tracksManager : WCLTableViewManager = WCLTableViewManager()
    
    var forceUpdate : Bool = false
    var previousSource : SynncExternalSource {
        get {
            if let previous = WildDataManager.sharedInstance().getUserDefaultsValue("synnc-search-source") as? String, let src = SynncExternalSource(rawValue: previous) {
                return src
            } else {
                return .Soundcloud
            }
        }
    }
    
    var selectedSource : SynncExternalSource = .Soundcloud {
        didSet {
            
            WildDataManager.sharedInstance().updateUserDefaultsValue("synnc-search-source", value: selectedSource.rawValue)
            
            self.queryString_artists = ""
            self.queryString_tracks = ""
            self.screenNode.sourceOptionsButton.setImage(UIImage(named: selectedSource.rawValue.lowercaseString + "_active"), forState: .Normal)
            self.searchStringChanged(self.screenNode.inputNode.textView.text)
        }
    }
    var selectedArtist : SynncArtist?
    var spotifyAlbums : [SPTAlbum] = []
    
    init(size: CGSize) {
        let opts = WCLPopupAnimationOptions(fromLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Bottom), toLocation: (WCLPopupRelativePointToSuperView.Center, WCLPopupRelativePointToSuperView.Center), withShadow: true)
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = opts
    }
    override func loadView() {
        super.loadView()
        
        
        self.screenNode = TrackSearchNode()
        
        self.screenNode.sourceSelectionNode.delegate = self
        
        self.screenNode.inputNode.delegate = self
        self.screenNode.closeButton.addTarget(self, action: #selector(TrackSearchController.closeTrackSearch(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        self.screenNode.sourceOptionsButton.addTarget(self, action: #selector(TrackSearchController.toggleSourceSelector(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        
        self.screenNode.artistsCollection.view.asyncDataSource = artistsDataSource
        self.screenNode.artistsCollection.view.asyncDelegate = self
        
        self.screenNode.tracksTable.view.asyncDataSource = tracksDataSource
        self.screenNode.tracksTable.view.asyncDelegate = self
        
        artistsDataSource.delegate = self
        tracksDataSource.delegate = self
        
        self.view.addSubnode(self.screenNode)
        self.screenNode.view.frame = CGRect(origin: CGPointZero, size: self.size)
        
    }
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: self.screenNode)
    }
    override func didHide() {
        super.didHide()
        AnalyticsManager.sharedInstance.newScreen(oldScreen)
    }
    func toggleSourceSelector(sender : ButtonNode){
        self.screenNode.sourceSelectionNode.toggle(self.selectedSource)
        AnalyticsEvent.new(category: "trackSearch", action: "sourceSelect", label: nil, value: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            n.measureWithSizeRange(ASSizeRangeMake(self.view.frame.size, self.view.frame.size))
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeTrackSearch(sender : ButtonNode) {
        self.closeView(true)
        AnalyticsEvent.new(category : "ui_action", action: "button_tap", label: "Close TrackSearch", value: nil)
    }
    
    override func closeView(animated: Bool) {
        super.closeView(animated)
        self.screenNode.inputNode.resignFirstResponder()
    }
    override func display() {
        super.display()
        self.screenNode.inputNode.becomeFirstResponder()
    }
    override func endedPanGesture(recognizer: UIPanGestureRecognizer) -> Bool {
        let status = super.endedPanGesture(recognizer)
        if !status {
            self.screenNode.inputNode.resignFirstResponder()
        }
        return status
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedSource = self.sourceSelector(canSelectSource: self.previousSource) ? self.previousSource : .Soundcloud
    }
}

extension TrackSearchController : ASEditableTextNodeDelegate {
    func editableTextNode(editableTextNode: ASEditableTextNode, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if let _ = text.rangeOfString("\n") {
            editableTextNode.resignFirstResponder()
            return false
        }
        if let fieldStr = editableTextNode.textView.text {
            var str = (fieldStr as NSString).stringByReplacingCharactersInRange(range, withString: text)
            str = (str as NSString).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.searchStringChanged(str)
        }
        return true
    }
}

extension TrackSearchController : ASTableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item >= self.tracksDataSource.data.count {
            return
        }
        if let data = self.tracksDataSource.data[indexPath.item] as? SynncTrack {
            AnalyticsEvent.new(category: "trackSearch", action: "itemSelect", label: "track", value: nil)
            self.delegate?.trackSearcher(self, didSelect: data)
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item >= self.tracksDataSource.data.count {
            return
        }
        if let data = self.tracksDataSource.data[indexPath.item] as? SynncTrack {
            AnalyticsEvent.new(category: "trackSearch", action: "itemDeselect", label: "track", value: nil)
            self.delegate?.trackSearcher(self, didDeselect: data)
        }
    }
    func tableView(tableView: ASTableView, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath) {
        
        Async.main {
            if indexPath.item >= self.tracksDataSource.data.count {
                return
            }
            if let data = self.tracksDataSource.data[indexPath.item] as? SynncTrack where indexPath.item < self.tracksDataSource.data.count && self.delegate!.trackSearcher(self, hasTrack: data) {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        }
    }
}
extension TrackSearchController : ASCollectionDelegate {
    func shouldBatchFetchForTableView(tableView: ASTableView) -> Bool {
        return true
    }
    func tableView(tableView: ASTableView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.tracksManager.batchContext = context
        AnalyticsEvent.new(category: "trackSearch", action: "loadMore", label: "track", value: nil)
        self.tracksDataSource.loadMore()
    }
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView) -> Bool {
        return true
    }
    func collectionView(collectionView: ASCollectionView, willBeginBatchFetchWithContext context: ASBatchContext) {
        self.artistsManager.batchContext = context
        AnalyticsEvent.new(category: "trackSearch", action: "loadMore", label: "artist", value: nil)
        self.artistsDataSource.loadMore()
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let artist = self.artistsDataSource.dataAtIndex(indexPath.item) as? SynncArtist {
            if let s = self.selectedArtist where s.source == artist.source && s.id == artist.id {
                self.selectedArtist = nil
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
            } else {
                self.selectedArtist = artist
            }
            artistSearch()
        }
    }
    func collectionView(collectionView: ASCollectionView, willDisplayNodeForItemAtIndexPath indexPath: NSIndexPath) {
        Async.background {
            if let data = self.artistsDataSource.dataAtIndex(indexPath.item) as? SynncArtist, let selected = self.selectedArtist {
                if data.source == selected.source && data.id == selected.id {
                    collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                } else {
                    collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                }
            }
        }
    }
}
extension TrackSearchController {
    func searchStringChanged(newString: String){
        
        self.selectedArtist = nil
        
        last_search = NSDate()
        let ts = last_search
        
        if newString == "" {
            self.tracksDataSource.refresh = true
            self.tracksDataSource.pendingData = []
            self.artistsDataSource.refresh = true
            self.artistsDataSource.pendingData = []
            
            self.screenNode.trackEmptyStateNode.state = false
            self.screenNode.artistEmptyStateNode.state = false
            
            return
        }
        
        if !checkSourceAvailability(self.selectedSource) {
            notifyForSource(self.selectedSource)
            return
        }
        
        switch self.selectedSource {
        case .Soundcloud:
            searchSoundcloud(newString,timeStamp: ts)
        case .Spotify:
            searchSpotify(newString, timeStamp: ts)
        default:
            break
        }
        
        
    }
    
    func searchSpotify(str: String, timeStamp: NSDate, offSet : Int? = 0) {
        
        let types : [EntityType] = [.Track, .Artist]
        
        for type in types {            SPTSearch.performSearchWithQuery(str.stringByRemovingPercentEncoding, queryType: type == .Track ? .QueryTypeTrack : .QueryTypeArtist, offset: offSet!, accessToken: SPTAuth.defaultInstance().session.accessToken, market: SPTMarketFromToken) { (err, data) -> Void in
            
            if (self.last_search.compare(timeStamp) == NSComparisonResult.OrderedSame) {
                    if let sptshit = data as? SPTListPage {
                        if sptshit.items != nil {
                            self.processResults(str, source: .Spotify, entity: type, timestamp: timeStamp, dataArr: sptshit.items)
                            
                            if sptshit.hasNextPage {
                                if type == EntityType.Track {
                                    self.tracksDataSource.nextAction = {
                                        self.searchSpotify(str, timeStamp: timeStamp, offSet: sptshit.range.location + sptshit.range.length)
                                    }
                                } else {
                                    self.artistsDataSource.nextAction = {
                                        self.searchSpotify(str, timeStamp: timeStamp, offSet: sptshit.range.location + sptshit.range.length)
                                    }
                                }
                            } else {
                                if type == EntityType.Track {
                                    self.tracksDataSource.nextAction = nil
                                } else {
                                    self.artistsDataSource.nextAction = nil
                                }
                            }
                        }
                    }
                    switch type {
                    case .Track:
                        break
                    case .Artist:
                        break
                    }
                }
            }
        }
    }
    
    func searchSoundcloud(str: String, timeStamp: NSDate){
        if str == "" {
            return
        }
        
        Async.background {
            let types : [SCEntityType] = [.Users, .Tracks]
            
            for type in types {
                SCEngine.search(type, searchString: str, limit: 20, jsonCallback: {
                    cb in
                    if (self.last_search.compare(timeStamp) == NSComparisonResult.OrderedSame) {
                        if let arr = cb.data {
                            Async.background {
                                
                                self.processResults(str, source: .Soundcloud, entity: type == .Tracks ? .Track : .Artist, timestamp: timeStamp, dataArr: arr)
                                
                                if type == .Tracks {
                                    self.tracksDataSource.nextAction = cb.next
                                } else {
                                    self.artistsDataSource.nextAction = cb.next
                                }
                                
                            }
                        }
                    }
                })
            }
        }
    }
    
    func processResults(query: String, source: SynncExternalSource, entity: EntityType! = nil, timestamp: NSDate, dataArr: [AnyObject]? = nil){
        
        if entity == nil {
            return
        }
        var data : [NSObject] = []
        if let arr = dataArr {
            for item in arr {
                let x : NSObject = (entity == .Track) ? SynncTrack.create(item, source: source) : SynncArtist.create(item, source: source)
                data.append(x)
            }
            
            if (self.last_search.compare(timestamp) != NSComparisonResult.OrderedSame) {
                return
            }
            
            if entity == .Track {
                let needsRefresh = query != self.queryString_tracks
                self.tracksDataSource.refresh = needsRefresh
                self.tracksDataSource.pendingData = data
                self.queryString_tracks = query
                
                if (needsRefresh && data.isEmpty) || (!needsRefresh && self.tracksDataSource.data.isEmpty && data.isEmpty) {
                    
                    var emptyMsg : String
                    if let _ = self.selectedArtist {
                        emptyMsg = "Selected artist doesn't \n have any playable tracks"
                    } else {
                        emptyMsg = "Couldn't find any tracks \n mathing your query"
                    }
                    self.screenNode.trackEmptyStateNode.setMessage(emptyMsg)
                    self.screenNode.trackEmptyStateNode.state = true
                } else {
                    self.screenNode.trackEmptyStateNode.state = false
                }
            } else {
                
                let needsRefresh = forceUpdate ? forceUpdate : query != self.queryString_artists
                self.artistsDataSource.refresh = needsRefresh
                self.artistsDataSource.pendingData = data
                self.queryString_artists = query
                
                if (needsRefresh && data.isEmpty) || (!needsRefresh && self.artistsDataSource.data.isEmpty && data.isEmpty) {
                    self.screenNode.artistEmptyStateNode.setMessage("Couldn't find any artists \n mathing your query")
                    self.screenNode.artistEmptyStateNode.state = true
                } else {
                    self.screenNode.artistEmptyStateNode.state = false
                }
            }
        }
    }
    
    func parseAlbum(offset : Int? = 0, timeStamp : NSDate!) {
        guard let artist = self.selectedArtist else {
            return
        }
        
        if offset >= spotifyAlbums.count {
            return
        }
        
        if !checkSourceAvailability(self.selectedSource) {
            notifyForSource(self.selectedSource)
            return
        }
        
        let album = spotifyAlbums[offset!]
        do {
            var req = try SPTAlbum.createRequestForAlbum(album.uri, withAccessToken: SPTAuth.defaultInstance().session.accessToken, market: nil)
            let reqStr = req.URL!.absoluteString.stringByReplacingOccurrencesOfString("?", withString: "/tracks", options: [], range: nil)
            req = try SPTRequest.createRequestForURL(NSURL(string: reqStr), withAccessToken: SPTAuth.defaultInstance().session.accessToken, httpMethod: "GET", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: false)
            
            NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, res, err) in
                do {
                    let x = try SPTListPage(fromData: data, withResponse: res, expectingPartialChildren: false, rootObjectKey: nil)
                    if let tracks = x.items as? [SPTPartialTrack] {
                        for trackItem in tracks {
                            trackItem.setValue(album, forKey: "album")
                        }
                        
                        self.processResults(artist.id + ":search", source: .Spotify, entity : .Track, timestamp: timeStamp, dataArr: tracks)
                        self.tracksDataSource.nextAction = {
                            self.parseAlbum(offset!+1, timeStamp: timeStamp)
                        }
                    } else {
                        self.tracksDataSource.nextAction = nil
                    }
                    
                } catch let error as NSError {
                    print(error)
                    self.tracksDataSource.nextAction = nil
                }
            }).resume()
            
        } catch let error as NSError {
            print(error)
            self.tracksDataSource.nextAction = nil
        }
    }
    
    func addSpotifyAlbums(albums : [SPTAlbum], timeStamp: NSDate!) {
        
        let needsParse = spotifyAlbums.isEmpty
        spotifyAlbums += albums
        
        if needsParse {
            parseAlbum(0, timeStamp: timeStamp)
        }
    }
    
    func spotifyArtistSearch(artist : SPTArtist, uri : NSURL? = nil, timeStamp : NSDate? = nil) {
        
        if !checkSourceAvailability(self.selectedSource) {
            notifyForSource(self.selectedSource)
            return
        }
        
        guard let sptUser = Synnc.sharedInstance.user.userExtension(.Spotify) as? WildSpotifyUser, let loginStatus = sptUser.loginStatus where loginStatus else {
            return
        }
        
        self.spotifyAlbums = []
        
        do {
            let req = uri != nil ? try SPTRequest.createRequestForURL(uri, withAccessToken: SPTAuth.defaultInstance().session.accessToken, httpMethod: "GET", values: nil, valueBodyIsJSON: true, sendDataAsQueryString: false) : try SPTArtist.createRequestForAlbumsByArtist(artist.uri, ofType: .Album, withAccessToken: SPTAuth.defaultInstance().session.accessToken, market: nil)
            NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { (data, res, err) in
                do {
                    let x = try SPTListPage(fromData: data, withResponse: res, expectingPartialChildren: false, rootObjectKey: nil)

                    if let selected = self.selectedArtist where selected.id != artist.identifier {
                        return
                    } else if self.selectedArtist == nil {
                        return
                    }
                    
                    if let albums = x.items as? [SPTAlbum] {
                        
                        self.addSpotifyAlbums(albums, timeStamp: timeStamp)
                        if self.selectedArtist != nil && x.hasNextPage {
                            self.spotifyArtistSearch(artist, uri : x.nextPageURL, timeStamp: timeStamp)
                        }
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }).resume()
        } catch let error as NSError {
            print(error)
        }
    
    }
    
    func artistSearch(){
        guard let id = self.selectedArtist?.id else {
            AnalyticsEvent.new(category: "trackSearch", action: "deselectArtist", label: nil, value: nil)
            self.searchStringChanged(self.screenNode.inputNode.textView.text)
            return
        }
        
        if !checkSourceAvailability(self.selectedSource) {
            notifyForSource(self.selectedSource)
            return
        }
        
        AnalyticsEvent.new(category: "trackSearch", action: "selectArtist", label: nil, value: nil)
        
        last_search = NSDate()
        let ts = last_search
        
        
        Async.background {
            
            if self.selectedSource == .Soundcloud {
                SCEngine.tracks(id, limit: 20, jsonCallback: {
                    cb in
                    let timestamp = cb.timestamp
                    if (ts.compare(timestamp) == NSComparisonResult.OrderedAscending) {
                        self.processResults(id, source: .Soundcloud, entity: .Track, timestamp: self.last_search, dataArr: cb.data)
                        self.tracksDataSource.nextAction = cb.next
                    }
                })
            } else if self.selectedSource == .Spotify {
                
                let url = NSURL(string: "spotify:artist:\(id)")
                if url == nil {
                    return
                }
                
                SPTArtist.artistWithURI(url!, session: SPTAuth.defaultInstance().session) {
                        
                    [weak self]
                    (err, obj) -> Void in
                    
                    
                    
                    if let artist = obj as? SPTArtist, let sptUser = Synnc.sharedInstance.user.userExtension(.Spotify) as? WildSpotifyUser, let loginStatus = sptUser.loginStatus where loginStatus {
                     
                        self?.spotifyArtistSearch(artist, timeStamp: ts)
                        
                        print("found artist", artist)
                    }
                }
            }
        }
    }
}

extension TrackSearchController : SourceSelectorDelegate {
    func sourceSelector(didUpdateSource source: SynncExternalSource) {
        self.selectedSource = source
    }
    func sourceSelector(canSelectSource source: SynncExternalSource) -> Bool {
        return self.checkSourceAvailability(source)
    }
}

extension TrackSearchController {
    func notifyForSource(source : SynncExternalSource) {
        if let a = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: nil, options: nil).first as? WCLNotificationView {
            let info = WCLNotificationInfo(defaultActionName: "", body: "You need to login to \(source.rawValue) first.", title: "Synnc", sound: nil, fireDate: nil, showLocalNotification: true, object: nil, id: nil) {
                notif in
                
                Synnc.sharedInstance.user.socialLogin(WCLUserLoginType(rawValue: source.rawValue)!)
            }
            WCLNotificationManager.sharedInstance().newNotification(a, info: info)
            
            return
        }
    }
    func checkSourceAvailability(source : SynncExternalSource) -> Bool {
        
        if source == .Soundcloud {
            return true
        } else if source == .Spotify {
            if let user = Synnc.sharedInstance.user, let ext = user.userExtension(.Spotify), let status = ext.loginStatus where status  {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}

extension TrackSearchController : WCLAsyncTableViewDataSourceDelegate {
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedItemAtIndexPath indexPAth: NSIndexPath) {
        
    }
    func asyncTableViewDataSource(dataSource: WCLAsyncTableViewDataSource, updatedData: (oldData: [NSObject], newData: [NSObject])) {
        self.tracksManager.performUpdates(self.screenNode.tracksTable.view, updates: (oldItems: updatedData.oldData, newItems: updatedData.newData), animated: true)
    }
}
extension TrackSearchController : WCLAsyncCollectionViewDataSourceDelegate {
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> (min: CGSize, max: CGSize) {
        let bounds = self.screenNode.artistsCollection.view.bounds
        let h = bounds.height
        
        return (min: CGSizeMake(100,h), max: CGSizeMake(100,h))
    }
    func asyncCollectionViewDataSource(dataSource: WCLAsyncCollectionViewDataSource, updatedData: (oldData: [NSObject], newData: [NSObject])) {
        self.artistsManager.performUpdates(self.screenNode.artistsCollection.view, updates: (oldItems: updatedData.oldData, newItems: updatedData.newData), animated: true)
    }
}