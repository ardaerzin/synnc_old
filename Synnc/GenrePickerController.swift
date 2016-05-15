//
//  GenrePickerController.swift
//  Synnc
//
//  Created by Arda Erzin on 1/4/16.
//  Copyright © 2016 Arda Erzin. All rights reserved.
//

import Foundation
import UIKit
import WCLUIKit
import WCLUtilities
import AsyncDisplayKit
import pop
import WCLUserManager
import WCLSoundCloudKit
import WCLPopupManager
import Async

protocol GenrePickerDelegate {
    func genrePicker(picker: GenrePicker, dismissedWithGenres genres: [Genre])
}

class GenrePicker : WCLPopupViewController {
    var selectedGenres : [Genre] = []
    var delegate : GenrePickerDelegate?
    var genresDataSource : GenresDataSource! = GenresDataSource()
    var node : GenrePickerNode!
    
    init(size: CGSize, genres : [Genre]) {
        super.init(nibName: nil, bundle: nil, size: size)
        self.animationOptions = WCLPopupAnimationOptions(fromLocation: (.Center,.Bottom), toLocation: (.Center, .Center), withShadow: true)
        self.selectedGenres = genres
        genresDataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let node = GenrePickerNode()
        self.node = node
        
        self.view.addSubnode(node)
        node.view.frame = CGRect(origin: CGPointZero, size: self.size)
        node.genreCollection.view.asyncDataSource = self
        node.genreCollection.view.asyncDelegate = self
        
        node.buttonHolder.doneButton.addTarget(self, action: #selector(GenrePicker.donePicking(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let n = self.node {
            let x = n.measureWithSizeRange(ASSizeRangeMake(self.view.frame.size, self.view.frame.size))
            if x.size != self.size {
                self.size = x.size
                self.configureView()
            }
        }
    }
    func donePicking(sender : ButtonNode) {
        self.delegate?.genrePicker(self, dismissedWithGenres: self.selectedGenres)
        self.closeView(true)
    }
}

extension GenrePicker : ASCollectionDataSource {
    func collectionView(collectionView: ASCollectionView, constrainedSizeForNodeAtIndexPath indexPath: NSIndexPath) -> ASSizeRange {
        let x = (collectionView.bounds.width - 5 - 10) / 2
        return ASSizeRangeMake(CGSize(width: x, height: 0), CGSize(width: x, height: 300))
    }
    func collectionView(collectionView: ASCollectionView, nodeForItemAtIndexPath indexPath: NSIndexPath) -> ASCellNode {
        let node = GenreCellNode()
        let item = genresDataSource.allItems[indexPath.row]
        node.configure(item)

        return node
    }
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genresDataSource.allItems.count
    }
}
extension GenrePicker : ASCollectionDelegate {
    func shouldBatchFetchForCollectionView(collectionView: ASCollectionView) -> Bool {
        return false
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let genre = genresDataSource.allItems[indexPath.item]
        
        if let ind = self.selectedGenres.indexOf(genre) {
            self.selectedGenres.removeAtIndex(ind)
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let genre = genresDataSource.allItems[indexPath.item]
        let ind = self.selectedGenres.indexOf(genre)
        if ind == nil {
            self.selectedGenres.append(genre)
        }
    }
    func collectionView(collectionView: ASCollectionView, willDisplayNodeForItemAtIndexPath indexPath: NSIndexPath) {
        let genre = genresDataSource.allItems[indexPath.item]
        
        
        Async.main {
        
            var x : Bool
            if let _ = self.selectedGenres.indexOf(genre) {
                x = true
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            } else {
                x = false
                collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            }
            
            if let cell = collectionView.nodeForItemAtIndexPath(indexPath) as? GenreCellNode {
                cell.pop_removeAllAnimations()
                cell.state = x
            }
        }
    }
}

extension GenrePicker : GenresDataSourceDelegate {
    func genresDataSource(addedItem item: Genre, newIndexPath indexPath: NSIndexPath) {

    }
    func genresDataSource(movedItem item: Genre, fromIndexPath indexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {

    }
    
    func genresDataSource(removedItem item: Genre, fromIndexPath indexPath: NSIndexPath) {

    }
    func genresDataSource(updatedItem item: Genre, atIndexPath indexPath: NSIndexPath) {

    }
}

class GenrePickerNode : ASDisplayNode {
    var genreCollection : ASCollectionNode!
    var buttonHolder : GenreButtonHolderNode!
    
    override init() {
        super.init()

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 65, 5)
        layout.scrollDirection = .Vertical
        
        genreCollection = ASCollectionNode(collectionViewLayout: layout)
        genreCollection.flexGrow = true
        genreCollection.alignSelf = .Stretch
        genreCollection.view.allowsMultipleSelection = true
        
        buttonHolder = GenreButtonHolderNode()
        buttonHolder.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Percent, value: 1), ASRelativeDimension(type: .Points, value: 85))
        self.backgroundColor = UIColor.whiteColor()
        self.cornerRadius = 5
        self.clipsToBounds = true
        
        self.addSubnode(genreCollection)
        self.addSubnode(buttonHolder)
    }
    
    override func layout() {
        super.layout()
        buttonHolder.position.y = self.calculatedSize.height - (buttonHolder.calculatedSize.height / 2)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let stack = ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [genreCollection])
        let button = ASStaticLayoutSpec(children: [buttonHolder])
        return ASOverlayLayoutSpec(child: stack, overlay: button)
    }
}

class GenreButtonHolderNode : ASDisplayNode {
    
    var gradientLayer : CAGradientLayer!
    var doneButton : ButtonNode!
    
    override init() {
        super.init()
    
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        doneButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        doneButton.setAttributedTitle(NSAttributedString(string: "DONE", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu-Bold", size : 13)!, NSForegroundColorAttributeName : UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1)]), forState: ASControlState.Normal)
        doneButton.contentEdgeInsets = UIEdgeInsetsMake(8, 61, 12, 61)
        doneButton.borderColor = UIColor(red: 176/255, green: 219/255, blue: 223/255, alpha: 1).CGColor
        doneButton.borderWidth = 3
        doneButton.cornerRadius = 15
        
        self.addSubnode(doneButton)
        
        self.backgroundColor = .whiteColor()
        
        let layer = CAGradientLayer(layer: self.layer)
        layer.colors = [UIColor.whiteColor().colorWithAlphaComponent(0).CGColor, UIColor.whiteColor().colorWithAlphaComponent(1).CGColor]
        layer.startPoint = CGPointMake(0, 0)
        layer.endPoint = CGPointMake(0, 0.2)
        self.gradientLayer = layer
    }
    
    override func layoutDidFinish() {
        super.layoutDidFinish()
        gradientLayer.frame = self.view.bounds
        self.layer.mask = gradientLayer
    }
    
    override func layout() {
        super.layout()
        
        doneButton.position.x = self.calculatedSize.width / 2
        doneButton.position.y = self.calculatedSize.height / 2
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let x = ASStaticLayoutSpec(children: [doneButton])
        
        return x
    }
}