//
//  StreamVCNode.swift
//  Synnc
//
//  Created by Arda Erzin on 3/28/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import pop
import WCLUIKit

class StreamHeaderNode : PagerHeaderNode {
    
    var gradientLayer : CAGradientLayer!
    
    init(){
        super.init(backgroundColor: nil)
    }
}

class StreamImageHeader : ASDisplayNode {
    var imageNode : ASNetworkImageNode!
    var tintNode : ASDisplayNode!
    
    override init() {
        super.init()
        
        imageNode = ASNetworkImageNode()
        self.addSubnode(imageNode)
        
        tintNode = ASDisplayNode()
        tintNode.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
        self.addSubnode(tintNode)
        
        self.backgroundColor = .purpleColor()
        
        self.clipsToBounds = true
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1) , ASRelativeDimension(type: .Percent, value: 1))
        
        tintNode.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1) , ASRelativeDimension(type: .Percent, value: 1))
        
        return ASStaticLayoutSpec(children: [imageNode, tintNode])
    }
    
    func updateScrollPosition(position : CGFloat) {
        
        let shit = max(0, -position)
        let progress = POPProgress(shit, startValue: 0, endValue: self.calculatedSize.height - 100)
        
        let transition = POPTransition(progress, startValue: (self.calculatedSize.height / 2) - 50, endValue: 0)
        
        let x = -position - (self.calculatedSize.height - 100)
        let scale = max(1, (self.calculatedSize.height + x) / self.calculatedSize.height)
        
        POPLayerSetTranslationY(self.layer, shit)
        POPLayerSetTranslationY(imageNode.layer, transition)
        POPLayerSetTranslationY(tintNode.layer, transition)
        
        POPLayerSetScaleXY(imageNode.layer, CGPointMake(scale, scale))
        POPLayerSetScaleXY(tintNode.layer, CGPointMake(scale, scale))
        
        if progress > 1 {
            self.clipsToBounds = false
        } else {
            self.clipsToBounds = true
        }
        
    }
}

class StreamVCNode : PagerBaseControllerNode {
    
    var imageHeader : StreamImageHeader!
    var imageNode : ASNetworkImageNode! {
        get {
            return imageHeader.imageNode
        }
    }
    var scrollPosition : CGFloat! {
        didSet {
            imageHeader.updateScrollPosition(scrollPosition)
        }
    }
    
    init() {
        
        let header = StreamHeaderNode()
        super.init(header: header, pager: nil)
        
        imageHeader = StreamImageHeader()
        self.addSubnode(imageHeader)
        
        self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    override func didLoad() {
        super.didLoad()
        self.view.bringSubviewToFront(self.headerNode.view)
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        
        if scrollPosition == nil {
            scrollPosition = 0
        }
    }
    
    override func layout() {
        super.layout()
        imageHeader.position.y = (imageHeader.calculatedSize.width / 2) - imageHeader.calculatedSize.width + 100
    }
    
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let x = super.layoutSpecThatFits(constrainedSize)
        
        self.imageHeader.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(constrainedSize.max.width, constrainedSize.max.width))
        
        return ASStaticLayoutSpec(children: [x, imageHeader])
    }
    
    override func fetchData() {
        super.fetchData()
//        if let x = self.infoDelegate?.imageForPlaylist!() {
//            
//            if let img = x as? UIImage {
//                
//                if img != self.imageNode.image {
//                    self.imageNode.URL = nil
//                    self.imageNode.image = img
//                    
//                    if img.size.height < self.imageNode.calculatedSize.height && img.size.width < self.imageNode.calculatedSize.width {
//                        self.imageNode.contentMode = .Center
//                    } else {
//                        self.imageNode.contentMode = .ScaleAspectFill
//                    }
//                }
//            } else if let url = x as? NSURL {
//                if let prevURL = self.imageNode.URL where prevURL.absoluteString == url.absoluteString {
//                } else {
//                    self.imageNode.URL = url
//                    self.imageNode.contentMode = .ScaleAspectFill
//                }
//            }
//        }
    }
}