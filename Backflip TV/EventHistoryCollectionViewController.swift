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

	private var events : [PFObject] = []
	
	private static let minimumEdgePadding = CGFloat(90.0)
	
	
	override func viewDidLoad()
	{
		// Make sure their is sufficient padding above and below the content.
		guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		
		collectionView.contentInset.top = EventHistoryCollectionViewController.minimumEdgePadding - layout.sectionInset.top
		collectionView.contentInset.bottom = EventHistoryCollectionViewController.minimumEdgePadding - layout.sectionInset.bottom
	}
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		let userId = NSUserDefaults.standardUserDefaults().objectForKey("account.objectId") as? String
		if (userId != nil) {
			SVProgressHUD.show()
			self.fetchData()
		} else {
			// Show login screen..
			let storyboard = UIStoryboard(name: "Main-TV", bundle: NSBundle.mainBundle())
			let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
			
			let window = UIApplication.sharedApplication().windows.first
			if (window != nil) {
				window?.rootViewController?.presentViewController(loginViewController, animated: true, completion: nil)
			}
		}
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
	
	override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
	{
		/*
			Return `false` because we don't want this `collectionView`'s cells to
			become focused. Instead the `UICollectionView` contained in the cell
			should become focused.
		*/
		return false
	}
	
	
	
	// --------------------------------------
	//  MARK: Data retrival
	// --------------------------------------
	
	func fetchData()
	{
		guard Reachability.validNetworkConnection() else {
			print("Not fetching data due to lack of network connection")
			SVProgressHUD.dismiss()
			return
		}
		
		let attendee = NSUserDefaults.standardUserDefaults().objectForKey("account.objectId") as? String
		print("Attendee = \(attendee)")
		let attendanceQuery = PFQuery(className: "EventAttendance")
		attendanceQuery.whereKey("attendeeID", equalTo:attendee!)
		attendanceQuery.includeKey("event")
		attendanceQuery.findObjectsInBackgroundWithBlock { (attendances, error) -> Void in
			
			print("We have \(attendances?.count) results..")
			SVProgressHUD.dismissWithDelay(0.1)
			
			guard attendances?.count > 0 else { return }
			
			self.events.removeAll()
			for attendance in attendances! {
				if (attendance["event"] != nil) {
					self.events.append((attendance["event"] as! PFObject))
				}
			}
			
			self.collectionView!.reloadData()
		}
		
	}

	
}
