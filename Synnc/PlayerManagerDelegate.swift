//
//  PlayerManagerDelegate.swift
//  Synnc
//
//  Created by Arda Erzin on 4/15/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation

@objc protocol PlayerManagerDelegate {
    optional func playerManager(manager : StreamPlayerManager!, volumeChanged volume: Float)
    optional func playerManager(manager : StreamPlayerManager!, updatedToTime: CGFloat)
    optional func playerManager(manager : StreamPlayerManager!, readyToPlay: Bool)
    optional func playerManager(manager : StreamPlayerManager!, updatedToPosition position: CGFloat)
    optional func playerManager(manager : StreamPlayerManager!, updatedRate rate: Float)
    optional func playerManager(manager : StreamPlayerManager!, updatedPlaylistIndex index: Int)
    optional func playerManager(manager : StreamPlayerManager!, updatedPreviewPosition position: CGFloat)
    optional func playerManager(manager : StreamPlayerManager!, updatedPreviewStatus status: Bool)
    optional func playerManager(manager : StreamPlayerManager!, isSyncing syncing : Bool)
    optional func playerManager(manager : StreamPlayerManager!, endOfPlaylist playedToEnd : Bool)
}