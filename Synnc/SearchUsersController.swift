//
//  SearchUsersController.swift
//  Synnc
//
//  Created by Arda Erzin on 12/12/15.
//  Copyright © 2015 Arda Erzin. All rights reserved.
//

import Foundation

class SearchUsersController : TabSubsectionController {
    override var _title : String! {
        return "Users"
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let x = self.parentViewController as? SearchController {
            x.titleItem.resignFirstResponder()
        }
    }
}

extension SearchUsersController : SubSearchController {
    func subSearchController(updatedSearchString: String!) {
        print("search users: q:", updatedSearchString)
    }
}