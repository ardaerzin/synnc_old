//
//  RootHeaderNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/23/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class RootHeaderNode : PagerHeaderNode {
    
    init(){
//        pageControlColor: UIColor(red: 193/255, green: 193/255, blue: 193/255, alpha: 1), pageControlSelectedColor: UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1)
        super.init(backgroundColor: UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1), height: 75)
    }
    
    override func layout() {
        super.layout()
        
        leftButtonHolder.position.y = (leftButtonHolder.calculatedSize.height / 2) + 30
        leftButtonHolder.position.x = (leftButtonHolder.calculatedSize.width / 2) + 15
        
        rightButtonHolder.position.y = (rightButtonHolder.calculatedSize.height / 2) + 30
        rightButtonHolder.position.x = self.calculatedSize.width - ((rightButtonHolder.calculatedSize.width / 2) + 15)
        
        titleHolder.position.y = titleHolder.calculatedSize.height / 2 + 20 + 5
        
        pageControl.position.x = self.calculatedSize.width / 2
        pageControl.position.y = titleHolder.position.y + (titleHolder.calculatedSize.height / 2) + 15
    }
}