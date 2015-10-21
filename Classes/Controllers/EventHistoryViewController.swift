//
//  EventHistoryViewController.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-09-23.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import MapleBacon
import Foundation


class EventHistoryViewController : UICollectionViewController
{
	
	private var events : [Event] = [];
	
	private let CELL_IDENTIFIER : String = "photo-cell-identifier"
	private let HEADER_IDENTIFIER : String = "header-identifier"
	
	
	
	//-------------------------------------
	// MARK: Collection View Datasource
	//-------------------------------------
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.title = "Event History"
		self.collectionView?.registerClass(EventHistoryHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HEADER_IDENTIFIER)
		
		fetchData()
	}
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        #if FEATURE_GOOGLE_ANALYTICS
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Event History View")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        #endif
    }
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		self.collectionView?.backgroundColor = UIColor.whiteColor()
		
		fetchData()
		
		// Layout -  Only run on the main thread
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.collectionView?.contentInset = UIEdgeInsetsMake(0.0, 0.0, 72.0, 0.0)
			
			let flow = self.collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
			flow.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 44);
			flow.itemSize = CGSizeMake((self.view.frame.size.width/5)-1, (self.view.frame.size.width/5)-1);
			flow.minimumInteritemSpacing = 1;
			flow.minimumLineSpacing = 1;
		})
	}
	
	
	
	
	//-------------------------------------
	// MARK: Collection View Datasource
	//-------------------------------------
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		
		//let predicate = NSPredicate(format: "ANY event.objectId == %@ && flagged == 0", self.events[section].objectId!)
		//let photos = Photo.MR_findAllWithPredicate(predicate) as? [Photo]
		
		let photos = self.events[section].photos!.allObjects as? [Photo]
		if (photos != nil && photos?.count < 11) {
			return photos!.count
		} else {
			return 10
		}
		
	}

	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EventAlbumCell.reuseIdentifier, forIndexPath: indexPath) as! EventAlbumCell
		
		
//		let predicate = NSPredicate(format: "ANY event.objectId == %@ && flagged == 0", self.events[indexPath.section].objectId!)
//		var photos = Photo.MR_findAllWithPredicate(predicate) as? [Photo]
		// var photos = self.events[indexPath.section].photos!.allObjects as! [Photo]
		// photos.sortInPlace{ $0.upvoteCount!.integerValue > $1.upvoteCount!.integerValue }
		
		
//		let imageUrl = NSURL(string: photos[indexPath.row].thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))
//		if (cell.imageUrl != imageUrl) {
//			cell.imageView?.image = nil
//		}
//		
//		cell.imageUrl = imageUrl
//		cell.imageView?.setImageWithURL(imageUrl!, placeholder: nil, crossFadePlaceholder: true, cacheScaled: true, completion: nil)
		
		return cell
	}
	
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
	{
		guard let cell = cell as? EventAlbumCell else { fatalError("Expected to display a `EventAlbumCell`.") }
		
		var photos = self.events[indexPath.section].photos!.allObjects as! [Photo]
		photos.sortInPlace{ $0.upvoteCount!.integerValue > $1.upvoteCount!.integerValue }
		cell.imageView.nk_prepareForReuse()
		let imageUrl = NSURL(string: photos[indexPath.row].image!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!
		cell.imageView.nk_setImageWithURL(imageUrl)
	}
	
	
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return self.events.count
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
	{
		let view : EventHistoryHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: HEADER_IDENTIFIER, forIndexPath: indexPath) as! EventHistoryHeaderView
		
		let event = self.events[indexPath.section]
		
		view.eventTitle?.text = event.name
		view.eventLocation?.text = event.venue
		if (event.createdAt != nil) {
			view.eventDate?.text = event.createdAt!.timeAgo
		}
		view.tag = indexPath.section
		
		let tapGestureRecognizer = UITapGestureRecognizer()
		tapGestureRecognizer.addTarget(self, action: "didSelectCollectionHeaderView:")
		view.addGestureRecognizer(tapGestureRecognizer)
		
		return view
	}
	
	override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		return false
	}

	
	
	//-------------------------------------
	// MARK: Collection View Delegate
	//-------------------------------------
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		// Clear in-memory cache
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
	}
	
	
	
	//-------------------------------------
	// MARK: Touch Handlers
	//-------------------------------------
	
	func didSelectCollectionHeaderView(sender: AnyObject?)
	{
		let tapGestureRecognizer = sender as! UITapGestureRecognizer
		let header = tapGestureRecognizer.view as! EventHistoryHeaderView
		var cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: header.tag))
		if (cell == nil) {
			cell = UICollectionViewCell()
			cell!.tag = header.tag
		}
		
		self.performSegueWithIdentifier("display-event-album", sender: cell)
	}
	
	
	
	//-------------------------------------
	// MARK: Segues
	//-------------------------------------
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if segue.identifier == "display-event-album" {
			
			var selectedPath = collectionView?.indexPathForCell(sender as! UICollectionViewCell)
			if (selectedPath == nil) {
				selectedPath = NSIndexPath(forRow: 0, inSection: sender!.tag)
			}
			
			let event = self.events[selectedPath!.section]
			let eventViewController = segue.destinationViewController as! EventAlbumViewController
			eventViewController.event = event
			
		}
	}
	
	
	
	//-------------------------------------
	// MARK: Data
	//-------------------------------------
	
	func fetchData()
	{
		var _events : [Event] = []
		
		let currentEventId : String? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id") as? String
		let user = PFUser.currentUser()!.objectId
		let attendances = Attendance.MR_findByAttribute("attendeeId", withValue: user) as! [Attendance]
		for attendance : Attendance in attendances {
			if (currentEventId == attendance.event?.objectId) {
				continue
			} else if (attendance.enabled != nil && Bool(attendance.enabled!) == true) {
				_events.append(attendance.event!)
			}
		}
		
		
		// Sort events
		_events.sortInPlace { if ($0.createdAt != nil && $1.createdAt != nil) { return $0.createdAt!.compare($1.createdAt!) == NSComparisonResult.OrderedDescending } else { return false } }
		
		self.events = _events;
		self.collectionView?.reloadData()
	}
	
}