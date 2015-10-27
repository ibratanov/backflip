//
//  EventHistoryCollectionViewCell.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-27.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import Foundation

class EventHistoryCollectionViewCell : UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate
{
	/**
	 * Collection view cell reuse identifier
	*/
	static let reuseIdentifier = "EventHistoryCollectionViewCell"

	/**
	 * Collection View
	*/
	@IBOutlet weak var collectionView : UICollectionView!
	
	/**
	 * Event Label
	*/
	@IBOutlet weak var eventLabel : UILabel!
	
	/**
	 * Event Date Label
	*/
	@IBOutlet weak var eventDateLabel : UILabel!
	
	
	/**
	 * Event object
	*/
	private weak var event : PFObject?
	
	/**
	 * Photos for this event
	*/
	private var photos : [PFObject] = []
	
	
	
	// --------------------------------------
	//  MARK: Cell configuration
	// --------------------------------------
	
	func configureCell(event: PFObject?)
	{
		self.event = event
		
		self.eventLabel.text = event?["eventName"] as? String
		if (event?.createdAt != nil) {
			self.eventDateLabel.text = event!.createdAt!.timeAgo
		}
		
		self.fetchData()
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
			
			self.collectionView?.reloadData()
		}
		
	}
	
	
	// --------------------------------------
	//  MARK: Collection View
	// --------------------------------------
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return self.photos.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		return collectionView.dequeueReusableCellWithReuseIdentifier(EventAlbumCell.reuseIdentifier, forIndexPath: indexPath)
	}
	
	func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		guard let cell = cell as? EventAlbumCell else { fatalError("Expected to display a `EventAlbumCell`.") }
		
		let photo = self.photos[Int(indexPath.row)]
		cell.imageView.nk_prepareForReuse()
		
		let file = photo["image"] as? PFFile
		if (file != nil) {
			let imageUrl = NSURL(string: file!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
			cell.imageView.nk_setImageWithURL(imageUrl)
		}
	}
	
	func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
	{
		let storyboard = UIStoryboard(name: "Main-TV", bundle: NSBundle.mainBundle())
		let photoBrowserViewController = storyboard.instantiateViewControllerWithIdentifier("PhotoBrowserViewController") as! PhotoBrowserViewController
		
		photoBrowserViewController.photos = self.photos
		photoBrowserViewController.initialPageIndex = indexPath.row
		
		let window = UIApplication.sharedApplication().windows.first
		if (window != nil) {
			window?.rootViewController?.presentViewController(photoBrowserViewController, animated: true, completion: nil)
		}
	}
	
}
