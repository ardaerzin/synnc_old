//
//  SynncNotification.swift
//  Synnc
//
//  Created by Arda Erzin on 5/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLNotificationManager

class SynncNotification : WCLNotification {
    override func didTap(recognizer: UITapGestureRecognizer) {
        if tapCallback != nil {
            
        }
        super.didTap(recognizer)
    }
}