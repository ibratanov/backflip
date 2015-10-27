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
	 * Event object
	*/
	private weak var event : PFObject?
	
	/**
	 * Photos for this event
	*/
	private weak var photos : [PFObject] = []
	
	
	
	func init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		
		
		
		// Layout -  Only run on the main thread
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			// self.collectionView?.contentInset = UIEdgeInsetsMake(0.0, 0.0, 72.0, 0.0)
			
			let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
			flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
			flow.itemSize = CGSizeMake((self.view.frame.size.width/5)-1, (self.view.frame.size.width/5)-1);
			flow.minimumInteritemSpacing = 1;
			flow.minimumLineSpacing = 1;
		})
	}
	
	
	
	// --------------------------------------
	//  MARK: Cell configuration
	// --------------------------------------
	
	func configureCell(event: PFObject?)
	{
		self.event = event
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
			
			print("We have \(self.photos.count) photos for '\(event!["eventName"]!)'..")
			
			self.collectionView?.reloadData()
		}
		
	}
}
