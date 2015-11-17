//
//  BFPreviewViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-11-17.
//  Copyright © 2015 Backflip. All rights reserved.
//

import UIKit
import Foundation

class BFPreviewViewController : UIViewController, UICollectionViewDataSource
{
	
	/**
	 * Collection View
	*/
	var collectionView: UICollectionView!
	
	
	
	override func loadView()
	{
		super.loadView()
		
		self.view.backgroundColor = UIColor.whiteColor()
		
		self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
		self.collectionView.registerClass(BFPreviewLocationCell.self, forCellWithReuseIdentifier: BFPreviewLocationCell.reuseIdentifier)
		self.collectionView.dataSource = self
		self.view.addSubview(self.collectionView)
	}
	
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
		flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
		flow.itemSize = CGSizeMake(self.view.frame.width, 40);
		flow.minimumInteritemSpacing = 1;
		flow.minimumLineSpacing = 1;
	}
	
	
	override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		self.collectionView.frame = self.view.bounds
	}
	
	
	
	// ----------------------------------------
	//  MARK: - Collection View (Data source)
	// ----------------------------------------
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		let numberOfItems = 1
		return numberOfItems
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	@available(iOS 6.0, *)
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(BFPreviewLocationCell.reuseIdentifier, forIndexPath: indexPath) as! BFPreviewLocationCell
		
		
		return cell
	}
	
	@available(iOS 6.0, *)
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		print("Selected cell \(indexPath.row)")
	}
	
	@available(iOS 6.0, *)
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
//		if (indexPath.row > 0) {
//			guard let cell = cell as? BFPreviewLocationCell else { fatalError("Expected to display a `BFFeaturedEventCell`.") }
//			
//			let event = self.events[indexPath.row]
//			
//			cell.imageView.nk_prepareForReuse()
//			if (event.featureImage != nil) {
//				let imageUrl = NSURL(string: event.featureImage!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
//				cell.imageView.nk_setImageWithURL(imageUrl!)
//			}
//		}
	}

	
	
}
