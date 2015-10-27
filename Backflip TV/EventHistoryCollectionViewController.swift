//
//  EventHistoryCollectionViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation


class EventHistoryCollectionViewController : UICollectionViewController
{

	private var events = [PFObject] = []
	
	private static let minimumEdgePadding = CGFloat(90.0)
	
	
	override func viewDidLoad()
	{
		// Make sure their is sufficient padding above and below the content.
		guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		
		collectionView.contentInset.top = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.top
		collectionView.contentInset.bottom = CollectionViewContainerViewController.minimumEdgePadding - layout.sectionInset.bottom
	}
	
	
	// --------------------------------------
	//  MARK: Collection View
	// --------------------------------------
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.events.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		return collectionView.dequeueReusableCellWithReuseIdentifier(EventHistoryCollectionViewCell.reuseIdentifier, forIndexPath: indexPath)
	}
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		guard let cell = cell as? EventHistoryCollectionViewCell else { fatalError("Expected to display a `EventHistoryCollectionViewCell`.") }
		
		cell.configureCell(events[indexPath.row])
	}
	
	override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
	{
		self.performSegueWithIdentifier("presentPhotoBrowser", sender: self)
	}
	
}
