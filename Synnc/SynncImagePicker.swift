//
//  SynncImagePicker.swift
//  Synnc
//
//  Created by Arda Erzin on 12/18/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation
import DKImagePickerController
import AsyncDisplayKit

extension ASViewController {
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

class SynncImagePicker : DKImagePickerController {
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}