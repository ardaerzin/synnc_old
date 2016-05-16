//
//  ActionSheetPopup.swift
//  Synnc
//
//  Created by Arda Erzin on 4/24/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import WCLPopupManager
import AsyncDisplayKit
import WCLDataManager
import pop

class ActionSheetPopup : WCLPopupViewController {
    
    var screenNode : ActionSheetPopupNode!
    var onCancel : (()->Void)?
    
    init(size: CGSize, buttons : [ButtonNode]) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.screenNode.addButtons(buttons)
        self.screenNode.cancelButton.addTarget(self, action: #selector(ActionSheetPopup.cancel(_:)), forControlEvents: .TouchUpInside)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center, .Bottom), toLocation: (.Center, .Bottom), withShadow: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        self.draggable = true
        
        let node = ActionSheetPopupNode()
        self.screenNode = node
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.screenNode {
            let x = n.measureWithSizeRange(ASSizeRangeMake(CGSizeMake(self.view.frame.width, 0), self.view.frame.size))
            if x.size != self.size {
                self.size = x.size
                screenNode.view.frame = CGRect(origin: CGPointZero, size: self.size)
                self.configureView()
            }
        }
    }
    
    
    var oldScreen : AnalyticsScreen!
    override func didDisplay() {
        super.didDisplay()
        oldScreen = AnalyticsManager.sharedInstance.screens.last
        AnalyticsScreen.new(node: screenNode)
    }
    override func didHide() {
        super.didHide()
        if oldScreen != nil {
            AnalyticsManager.sharedInstance.newScreen(oldScreen)
        }
    }
    func cancel(sender : AnyObject) {
        self.onCancel?()
        self.closeView(true)
    }
}

class ActionSheetPopupNode : ASDisplayNode, TrackedView {
    
    var title: String! = "ActionSheet"
    var cancelButton : ButtonNode!
    
    var buttons : [ButtonNode] = []
    
    override init() {
        
        super.init()
        
        self.backgroundColor = UIColor.clearColor()
        
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        cancelButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        cancelButton.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        cancelButton.minScale = 1
        cancelButton.cornerRadius = 8
            
        cancelButton.alignSelf = .Stretch
        cancelButton.flexBasis = ASRelativeDimension(type: .Points, value: 50)
        cancelButton.spacingBefore = 20
        
        self.addSubnode(cancelButton)
    }
    
    func addButtons(buttons : [ButtonNode]) {
        
        self.buttons = buttons
        
        for button in buttons {
            button.alignSelf = .Stretch
            button.flexBasis = ASRelativeDimension(type: .Points, value: 50)
            button.spacingAfter = 5
            self.addSubnode(button)
        }
        self.setNeedsLayout()
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
       
        let items = self.buttons + [cancelButton]
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: items)
        
        return ASInsetLayoutSpec(insets: UIEdgeInsetsMake(0, 10, 10, 10), child: stack)
    }
}