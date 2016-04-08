//
//  PagerNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/21/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class PagerNode : ASPagerNode {
    
    override init(viewBlock: ASDisplayNodeViewBlock, didLoadBlock: ASDisplayNodeDidLoadBlock?) {
        super.init(viewBlock: viewBlock, didLoadBlock: didLoadBlock)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, layoutFacilitator: ASCollectionViewLayoutFacilitatorProtocol?) {
        super.init(frame: frame, collectionViewLayout: layout, layoutFacilitator: layoutFacilitator)
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    override init!(collectionViewLayout flowLayout: ASPagerFlowLayout!) {
        super.init(collectionViewLayout: flowLayout)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        self.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Percent, value: 1))
//        self.view.delaysContentTouches = false
        self.view.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        let a = ASRangeTuningParameters(leadingBufferScreenfuls: 1, trailingBufferScreenfuls: 1)
        self.setTuningParameters(a, forRangeMode: .Full, rangeType: ASLayoutRangeType.FetchData)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        print("touches began")
    }
}