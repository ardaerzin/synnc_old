//
//  OnboardingPager.swift
//  Synnc
//
//  Created by Arda Erzin on 3/19/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnboardingPager : ASPagerNode {
    
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
        
        self.cornerRadius = 10
    }
    
    override func didLoad() {
        super.didLoad()
        
        let a = ASRangeTuningParameters(leadingBufferScreenfuls: 1, trailingBufferScreenfuls: 1)
        self.setTuningParameters(a, forRangeMode: .Full, rangeType: ASLayoutRangeType.FetchData)
    }
}