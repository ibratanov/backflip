//
//  CheckinViewControllerNew.swift
//  Backflip
//
//  Created by Jack Perry on 2015-08-10.
//  Copyright (c) 2015 Backflip. All rights reserved.
//

import Parse
import DigitsKit
import Foundation



class CheckinViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	var events : [Event] = []
	
	let CELL_REUSE_IDENTIFIER = "album-cell"
	
	@IBOutlet var pickerView : UIPickerView?
	@IBOutlet var collectionView : UICollectionView?
	
    @IBOutlet weak var checkinButton: UIButton!
	
	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func loadView()
	{
		super.loadView()

		// Backflip Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
		
		
//		viewController.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yourimage.png"]];
//		UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yourimage2.jpg"]]];
//		viewController.navigationItem.rightBarButtonItem = item;
		
		self.navigationController?.tabBarController?.delegate = BFTabBarControllerDelegate.sharedDelegate
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()

		// Login validation
		if (PFUser.currentUser() == nil) {
			Digits.sharedInstance().logOut() // We do this to stop the un-sandbox'd digits data
			self.performSegueWithIdentifier("display-login-popover", sender: self)
			return
		}
		
		// check for current event
		let config = PFConfig.currentConfig()
		var checkoutDelay = 8
		if (config["checkout_timeout"] != nil) {
			checkoutDelay = Int(config["checkout_timeout"] as! NSNumber)
		}
		
		var checkinTime = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_time") as? NSDate
		if (checkinTime == nil) {
			return
		}
		
		var expiryTime = checkinTime?.addHours(Int(checkoutDelay))
		if (expiryTime != nil && NSDate().isGreaterThanDate(expiryTime!)) {
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_name")
		} else if (checkinTime != nil) {
			self.performSegueWithIdentifier("display-event-album", sender: self)
			return
		}
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)

        self.pickerView?.hidden = true

        //TODO: refactor
        var checkinTime = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_time") as? NSDate
        if (checkinTime == nil) {
            return
        }

        // check for current event
        let config = PFConfig.currentConfig()
        var checkoutDelay = 8
        if (config["checkout_timeout"] != nil) {
            checkoutDelay = Int(config["checkout_timeout"] as! NSNumber)
        }

        var expiryTime = checkinTime?.addHours(Int(checkoutDelay))
        if (expiryTime != nil && NSDate().isGreaterThanDate(expiryTime!)) {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_name")
        } else if (checkinTime != nil) {
            self.performSegueWithIdentifier("display-event-album", sender: self)
            return
        }

		// Data!!1!!!
		if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil) {
            fetchData()
        }
	}
	
	//-------------------------------------
	// MARK: UICollectioViewDataSource
	//-------------------------------------
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		let index = self.pickerView?.selectedRowInComponent(0)
		if (self.events.count == 0 || self.events.count < index) {
			return 0
		}
		
		let event = self.events[Int(index!)]
		if (event.photos?.count > 0) {
			return event.photos!.count
		}
		
		return 0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		
		let index = self.pickerView?.selectedRowInComponent(0)
		let event = self.events[Int(index!)]
		
		if (event.photos!.count != 0 && event.photos!.count > indexPath.row) {
			let photo = event.photos![indexPath.row]
			cell.imageView.file = photo.thumbnail
			cell.imageView.loadInBackground()
		}
		
		cell.layer.shouldRasterize = true
		cell.layer.rasterizationScale = UIScreen.mainScreen().scale
		
		return cell
	}
	
	
	
	//-------------------------------------
	// MARK: UIPickerViewDelegate
	//-------------------------------------
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		if (self.events.count < 1) {
			return 1
		} else {
			return self.events.count
		}
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
	{
        //self.pickerView?.selectRow(0, inComponent: 0, animated: true)
        if (self.events.count < 1) {
            checkinButton.enabled = false
			return "No nearby events"
		} else {
            checkinButton.enabled = true
			return self.events[row].name!
		}
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		if (self.events.count < row) {
			return
		}
		
		self.collectionView?.reloadData()
	}
	
	
	//-------------------------------------
	// MARK: Tabbar Delegate
	//-------------------------------------
	
	
	func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
	{
		let selectedIndex = tabBarController.viewControllers?.indexOf(viewController)
		if (selectedIndex == 1) {
			
			let currentEvent: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id")
			if (currentEvent == nil) {
				var alertController = UIAlertController(title: "Take Photo", message: "Please check in or create an event before uploading photos.", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (alertAction) -> Void in
					println("Should switch back to 'current event' tab")
				}))
				
				self.presentViewController(alertController, animated: true, completion: nil)
			} else {
			
				//let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
				//dispatch_after(dispatchTime, dispatch_get_main_queue(), {
					
					var testCamera = CustomCamera()
					if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
						
						let index = self.pickerView?.selectedRowInComponent(0)
						let event = self.events[Int(index!)]
						testCamera.event = event
						
						testCamera.delegate = self
						testCamera.modalPresentationStyle = UIModalPresentationStyle.FullScreen
						testCamera.sourceType = .Camera
						testCamera.allowsEditing = false
						testCamera.showsCameraControls = false
						testCamera.cameraViewTransform = CGAffineTransformMakeTranslation(0.0, 71.0)
						testCamera.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0.0, 71.0), 1.333333, 1.333333)
						
						self.presentViewController(testCamera, animated: true, completion: nil)
					}
				
				//})
			}
			
			return false
		}
		
		return true
	}
	
	
	//-------------------------------------
	// MARK: Actions
	//-------------------------------------
	
	@IBAction func logout()
	{
		var alertController = UIAlertController(title: "Are you sure you want to logout?", message:"", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { (alertAction) -> Void in
			PFUser.logOut()
			Digits.sharedInstance().logOut()
			self.performSegueWithIdentifier("display-login-popover", sender: self)
		}))
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	@IBAction func checkIn()
	{
		if (self.events.count < 1) {
			return
		}
		
		let index = self.pickerView?.selectedRowInComponent(0)
		let event = self.events[Int(index!)]
		
		// subscribe to event push notifications
		let currentInstallation = PFInstallation.currentInstallation()
		currentInstallation.addUniqueObject(("a" + event.objectId!) , forKey: "channels")
		currentInstallation.saveInBackground()
		
		// Create & save attendance object
		var attendance = PFObject(className:"EventAttendance")
		attendance["eventID"] = event.objectId
		attendance["attendeeID"] = PFUser.currentUser()?.objectId
		attendance["photosLikedID"] = []
		attendance["photosLiked"] = []
		attendance["photosUploadedID"] = []
		attendance["photosUploaded"] = []
		attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
		attendance.setObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "event")
		
		attendance.saveInBackground()
		
		
		var account = PFUser.currentUser()
		account?.addUniqueObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "savedEvents")
		account?.addUniqueObject(event.name!, forKey: "savedEventNames")
		account?.saveInBackground()
		
		
		// Store event details in user defaults
		NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
		NSUserDefaults.standardUserDefaults().setValue(NSDate.new(), forKey: "checkin_event_time")
		NSUserDefaults.standardUserDefaults().setValue(event.name, forKey: "checkin_event_name")
		
		
		self.performSegueWithIdentifier("display-event-album", sender: self)
	}
	
	
	//-------------------------------------
	// MARK: Segues
	//-------------------------------------
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if (segue.identifier == "display-event-album") {
			let albumViewController : EventAlbumViewController = segue.destinationViewController as! EventAlbumViewController
			let currentEventId: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_id")
			if (currentEventId != nil) {
				albumViewController.eventId = currentEventId as? String
				albumViewController.eventTitle =  NSUserDefaults.standardUserDefaults().valueForKey("checkin_event_name") as? String
			} else {
				let index = self.pickerView?.selectedRowInComponent(0)
				let event = self.events[Int(index!)]
				albumViewController.eventId = event.objectId
				albumViewController.eventTitle = event.name
			}
		}
		
	}
	
	
	//-------------------------------------
	// MARK: Data
	//-------------------------------------
	
	func fetchData()
	{
		let config = PFConfig.currentConfig()
		PFGeoPoint.geoPointForCurrentLocationInBackground({ (geopoint, error) -> Void in
			
			let query = PFQuery(className: "Event")
			let radius = config["nearby_events_radius"] != nil ? config["nearby_events_radius"]! as! NSNumber : 10 // Default: 10 kms
			query.whereKey("geoLocation", nearGeoPoint: geopoint!, withinKilometers:Double(radius))
			query.limit = config["nearby_events_limit"] != nil ? Int(config["nearby_events_limit"]! as! NSNumber) : 60 // Default: 60 events
			query.whereKey("isLive", equalTo:true)
			var objects = query.findObjects()
			if (objects == nil) {
				return
			}
			
			var account = PFQuery.getUserObjectWithId(PFUser.currentUser()!.objectId!)
			var eventHistory: [String] = account!.objectForKey("savedEventNames") as! [String]
			
			
			var content = [Event]()
			for object in objects as! [PFObject] {
				let pastEvent = contains(eventHistory, object["eventName"] as! String)
				if (pastEvent) {
					continue
				}
				
				var event = Event()
				event.objectId = object.objectId
				event.name = object["eventName"] as? String
				event.geoLocation = object["geoLocation"] as? PFGeoPoint
				event.isLive = object["isLive"] as? Boolean
				event.startTime = object["startTime"] as? NSDate
				event.venue = object["venue"] as? String
				event.photos = [Image]()
				
				let photoQuery : PFQuery = object.relationForKey("photos").query()!
				photoQuery.findObjectsInBackgroundWithBlock({ (photos, error) -> Void in
					
					for photo in photos as! [PFObject] {
						let image = Image(text: "Check out this photo!")
						image.objectId = photo.objectId
						image.likes = photo["upvoteCount"] as! Int
						image.image = photo["image"] as! PFFile
						image.thumbnail = photo["thumbnail"] as! PFFile
						image.createdAt = photo.createdAt
						image.likedBy = photo["usersLiked"] as! [String]
						event.photos?.append(image)
					}
					
					self.pickerView(self.pickerView!, didSelectRow: self.pickerView!.selectedRowInComponent(0), inComponent: 0)
					self.collectionView?.reloadData()
				})
				
				content.append(event)
			}
			
			
			self.events = content
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.pickerView?.reloadAllComponents()
				self.collectionView?.reloadData()
                self.pickerView?.hidden = false
			})
			
		})
	}
	
}