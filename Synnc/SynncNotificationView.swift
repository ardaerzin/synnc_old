//
//  SynncNotificationView.swift
//  Synnc
//
//  Created by Arda Erzin on 2/11/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLNotificationManager

class SynncNotificationView : WCLNotificationView {
    override var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 3
            iconView.image = Synnc.appIcon
        }
    }
}