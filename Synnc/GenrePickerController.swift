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

protocol GenrePickerDelegate {
    func pickedGenres(genres: [Genre])
    func didCancel()
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
        
        node.buttonHolder.yesButton.addTarget(self, action: #selector(GenrePicker.selectGenres(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
        node.buttonHolder.noButton.addTarget(self, action: #selector(GenrePicker.cancelGenrePicker(_:)), forControlEvents: ASControlNodeEvent.TouchUpInside)
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
    
    func cancelGenrePicker(sender : ButtonNode) {
        self.delegate?.didCancel()
        self.closeView(true)
    }
    
    func selectGenres(sender : ButtonNode) {
        self.delegate?.pickedGenres(self.selectedGenres)
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
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func collectionView(collectionView: ASCollectionView, willDisplayNodeForItemAtIndexPath indexPath: NSIndexPath) {
        let genre = genresDataSource.allItems[indexPath.item]
        // dodowarningsoru isareti koydum 3 satir alta
        if let _ = self.selectedGenres.indexOf(genre) {
            self.node.genreCollection.view.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            if let node = self.node?.genreCollection.view.nodeForItemAtIndexPath(indexPath) {
                node.selected = true
            }
            
        } else {
            
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
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        layout.scrollDirection = .Vertical
        
        genreCollection = ASCollectionNode(collectionViewLayout: layout)
        genreCollection.flexGrow = true
        genreCollection.alignSelf = .Stretch
        genreCollection.view.allowsMultipleSelection = true
        
        buttonHolder = GenreButtonHolderNode()
        
        self.backgroundColor = UIColor.whiteColor()
        self.cornerRadius = 5
        self.clipsToBounds = true
        
        self.addSubnode(genreCollection)
        self.addSubnode(buttonHolder)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [genreCollection, buttonHolder])
    }
}

class GenreButtonHolderNode : ASDisplayNode {
    var yesButton : ButtonNode!
    var noButton : ButtonNode!
    var line : ASDisplayNode!
    
        override init() {
        super.init()
    
        let paragraphAtrributes = NSMutableParagraphStyle()
        paragraphAtrributes.alignment = .Center
        
        line = ASDisplayNode()
        line.backgroundColor = UIColor(red: 83/255, green: 83/255, blue: 83/255, alpha: 1)
        
        yesButton = ButtonNode(normalColor: .SynncColor(), selectedColor: .SynncColor())
        yesButton.setAttributedTitle(NSAttributedString(string: "Yes Please", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor(red: 1, green: 1, blue: 1, alpha: 1), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        noButton = ButtonNode(normalColor: .whiteColor(), selectedColor: .whiteColor())
        noButton.setAttributedTitle(NSAttributedString(string: "Nope", attributes: [NSFontAttributeName : UIFont(name: "Ubuntu", size : 16)!, NSForegroundColorAttributeName : UIColor.SynncColor(), NSKernAttributeName : 0.3, NSParagraphStyleAttributeName : paragraphAtrributes]), forState: ASControlState.Normal)
        
        self.addSubnode(line)
        self.addSubnode(noButton)
        self.addSubnode(yesButton)
    }
    
    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        yesButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width / 2), ASRelativeDimension(type: .Points, value: 50))
        noButton.sizeRange = ASRelativeSizeRangeMakeWithExactRelativeDimensions(ASRelativeDimension(type: .Points, value: constrainedSize.max.width / 2), ASRelativeDimension(type: .Points, value: 50))
        
        let buttonSpec = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [ASStaticLayoutSpec(children: [noButton]), ASStaticLayoutSpec(children: [yesButton])])
        
        line.flexBasis = ASRelativeDimension(type: .Points, value: 1)
        line.alignSelf = .Stretch
        
        return ASStackLayoutSpec(direction: .Vertical, spacing: 0, justifyContent: .Center, alignItems: .Center, children: [line, buttonSpec])
    }
}