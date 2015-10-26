//
//  DetailViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-20.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Nuke
import UIKit
import Parse
import Foundation

class DetailViewController: UICollectionViewController
{
	
	private let cellComposer = DataItemCellComposer()

	private var photos : [PFObject] = []
	
	
	
	// --------------------------------------
	//  MARK: Setters
	// --------------------------------------
	
	private var _event : PFObject?
	var event : PFObject? {
		set {
			_event = newValue
			
			SVProgressHUD.show()
			self.fetchData()
		}
		get {
			return _event
		}
	}
	
	
	
	// --------------------------------------
	//  MARK: Data fetching
	// --------------------------------------
	
	func fetchData()
	{
		let photoQuery = PFQuery(className: "Photo")
		photoQuery.whereKey("enabled", equalTo: true)
		photoQuery.whereKey("flagged", equalTo: false)
		photoQuery.whereKey("event", equalTo: PFObject(withoutDataWithClassName: "Event", objectId: event?.objectId))
		photoQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
			
			guard objects?.count > 0 else { return }
			
			self.photos.removeAll()
			self.photos = objects!
			
			SVProgressHUD.dismissWithDelay(0.1)
			
			self.collectionView?.reloadData()
		}
		
	}
	
	
	
	
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
	
	
	
	
	// --------------------------------------
	//  MARK: Collection View
	// --------------------------------------
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.photos.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EventAlbumCell.reuseIdentifier, forIndexPath: indexPath)
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		guard let cell = cell as? EventAlbumCell else { fatalError("Expected to display a `EventAlbumCell`.") }
		
		let photo = self.photos[Int(indexPath.row)]
		let image = photo["image"] as? PFFile
		
		if (image != nil) {
			cell.imageView?.nk_prepareForReuse()
			let imageUrl = NSURL(string: image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
			print("Image URL = \(imageUrl)")
			cell.imageView.nk_setImageWithURL(imageUrl)
		}
		
		if (photo["caption"] != nil && (photo["caption"] as? String) != "Camera roll upload") {
			cell.label.text = photo["caption"] as? String
		}
	}
	
}
