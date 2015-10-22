//
//  DetailViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-20.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class DetailViewController: UICollectionViewController
{
	
	private let cellComposer = DataItemCellComposer()
	
	// MARK: UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let collectionView = collectionView else { return }
		
		/*
		Add a gradient mask to the collection view. This will fade out the
		contents of the collection view as it scrolls beneath the transparent
		navigation bar.
		*/
		collectionView.maskView = GradientMaskView(frame: CGRect(origin: CGPoint.zero, size: collectionView.bounds.size))
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		guard let collectionView = collectionView, maskView = collectionView.maskView as? GradientMaskView else { return }
		
		/*
		Update the mask view to have fully faded out any collection view
		content above the navigation bar's label.
		*/
		maskView.maskPosition.end = topLayoutGuide.length * 0.8
		
		/*
		Update the position from where the collection view's content should
		start to fade out. The size of the fade increases as the collection
		view scrolls to a maximum of half the navigation bar's height.
		*/
		let maximumMaskStart = maskView.maskPosition.end + (topLayoutGuide.length * 0.5)
		let verticalScrollPosition = max(0, collectionView.contentOffset.y + collectionView.contentInset.top)
		maskView.maskPosition.start = min(maximumMaskStart, maskView.maskPosition.end + verticalScrollPosition)
		
		/*
		Position the mask view so that it is always fills the visible area of
		the collection view.
		*/
		maskView.frame = CGRect(origin: CGPoint(x: 0, y: collectionView.contentOffset.y), size: collectionView.bounds.size)
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		// The collection view shows all items in a single section.
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		// Dequeue a cell from the collection view.
		return collectionView.dequeueReusableCellWithReuseIdentifier(DataItemCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		guard let cell = cell as? DataItemCollectionViewCell else { fatalError("Expected to display a `DataItemCollectionViewCell`.") }
		
		// let item = items[indexPath.row]
		
		// Configure the cell.
		cellComposer.composeCell(cell, withDataItem: nil)
	}
}
