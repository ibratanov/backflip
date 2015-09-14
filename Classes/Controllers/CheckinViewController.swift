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
import CoreLocation



class CheckinViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FastttCameraDelegate
{
	var events : [Event] = []
	var doubleTapGesture : UITapGestureRecognizer?
	
	let CELL_REUSE_IDENTIFIER = "album-cell"

	
	@IBOutlet var pickerView : UIPickerView?
	@IBOutlet var collectionView : UICollectionView?
	
	@IBOutlet weak var previewLabel : UILabel!
    @IBOutlet weak var checkinButton: UIButton!
	@IBOutlet weak var activityIndicator : UIActivityIndicatorView!
	

	//-------------------------------------
	// MARK: View Delegate
	//-------------------------------------
	
	override func loadView()
	{
		super.loadView()

		// Backflip Logo
		self.navigationItem.titleView = UIImageView(image: UIImage(named: "backflip-logo-white"))
		
		self.doubleTapGesture = UITapGestureRecognizer(target: self, action: "processDoubleTap:")
		self.doubleTapGesture?.delaysTouchesBegan = true
		self.doubleTapGesture?.numberOfTapsRequired = 2
		self.view.addGestureRecognizer(self.doubleTapGesture!)
		
		self.navigationController?.tabBarController?.delegate = BFTabBarControllerDelegate.sharedDelegate
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
        
        checkinButton.layer.cornerRadius = 5

		UIApplication.sharedApplication().statusBarHidden = false
		
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
		
		let checkinTime = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_time") as? NSDate
		if (checkinTime == nil) {
			return
		}
		
		let expiryTime = checkinTime?.addHours(Int(checkoutDelay))
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
		self.activityIndicator.startAnimating()
		self.activityIndicator.hidden = false

        //TODO: refactor
        let checkinTime = NSUserDefaults.standardUserDefaults().objectForKey("checkin_event_time") as? NSDate
        if (checkinTime != nil) {
            // check for current event
            let config = PFConfig.currentConfig()
            var checkoutDelay = 8
            if (config["checkout_timeout"] != nil) {
                checkoutDelay = Int(config["checkout_timeout"] as! NSNumber)
            }
            
            let expiryTime = checkinTime?.addHours(Int(checkoutDelay))
            if (expiryTime != nil && NSDate().isGreaterThanDate(expiryTime!)) {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_name")
            } else if (checkinTime != nil) {
                self.performSegueWithIdentifier("display-event-album", sender: self)
                return
            }
        }

		// Data!!1!!!
		if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil) {
            fetchData()
        }
        
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Checkin view")
        tracker.set("&uid", value: PFUser.currentUser()?.objectId)

        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
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
			if (event.photos?.count > 5) {
				return 6
			} else {
				return 1 + event.photos!.count
			}
		}
		
		return 0
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as! AlbumViewCell
		
		let index = self.pickerView?.selectedRowInComponent(0)
		let event = self.events[Int(index!)]
		
		if ((1 + indexPath.row) == self.collectionView(collectionView, numberOfItemsInSection: 0)) {
			cell.imageView.image = UIImage(named: "check-in-screen-double-tap")
			
		} else if (event.photos!.count != 0 && event.photos!.count > indexPath.row) {
			let photo : Photo = event.photos!.allObjects[indexPath.row] as! Photo
			cell.imageView.setImageWithURL(NSURL(string: photo.thumbnail!.url!)!)
		}
		
		// cell.addGestureRecognizer(self.doubleTapGesture!)
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
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
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
                
                var storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                var customCameraFCF = storyboard.instantiateViewControllerWithIdentifier("customCameraFCF") as! CustomCamera
                customCameraFCF.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                self.presentViewController(customCameraFCF as UIViewController, animated: true, completion: nil)
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
		let alertController = UIAlertController(title: "Are you sure you want to logout?", message:"", preferredStyle: .Alert)
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
		
		self.checkinWithEvent(event)
	}
	
	
	func checkinWithEvent(event : Event)
	{
		// Display a HUD letting the user know we're checking them in
		PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Checking in..")
		PKHUD.sharedHUD.show()
		
		
		// Store channel for push notifications
		let currentInstallation = PFInstallation.currentInstallation()
		currentInstallation.addUniqueObject("a"+event.objectId!, forKey: "channels")
		currentInstallation.saveInBackground()
		
		
		// Create attendance object, save to parse; save to CoreData
		let attendance = PFObject(className:"EventAttendance")
		attendance["eventID"] = event.objectId
		attendance["attendeeID"] = PFUser.currentUser()?.objectId
		attendance["photosLikedID"] = []
		attendance["photosLiked"] = []
		attendance["photosUploadedID"] = []
		attendance["photosUploaded"] = []
		attendance["enabled"] = true
		attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
		attendance.setObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "event")
		
		
		attendance.saveInBackgroundWithBlock { (success, error) -> Void in
			
			let attendees : [PFObject] = [attendance] 
			BFDataProcessor.sharedProcessor.processAttendees(attendees, completion: { () -> Void in
				
				// Add attendee to event
				let account = PFUser.currentUser()
				account?.addUniqueObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "savedEvents")
				account?.addUniqueObject(event.name!, forKey: "savedEventNames")
				account?.saveInBackground()
				
				
				// Add user to Event objects relation
				let eventQuery = PFQuery(className: "Event")
				eventQuery.whereKey("eventName", equalTo: event.name!)
				eventQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
					
					let eventObj = objects!.first as! PFObject
					let relation = eventObj.relationForKey("attendees")
					relation.addObject(PFUser.currentUser()!)
					eventObj.saveInBackground()
					
				}
				
				
				// Store event details in user defaults
				NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
				NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: "checkin_event_time")
				NSUserDefaults.standardUserDefaults().setValue(event.name, forKey: "checkin_event_name")
				
				
				
				PKHUD.sharedHUD.hideAnimated()
				
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue()) {
					
					self.performSegueWithIdentifier("display-event-album", sender: self)
					
				}
			})
			

		}
		
	}
	
	
	@IBAction func checkIn123()
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
		let attendance = PFObject(className:"EventAttendance")
		attendance["eventID"] = event.objectId
		attendance["attendeeID"] = PFUser.currentUser()?.objectId
		attendance["photosLikedID"] = []
		attendance["photosLiked"] = []
		attendance["photosUploadedID"] = []
		attendance["photosUploaded"] = []
		attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
		attendance.setObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "event")
		
		attendance.saveInBackground()
		
		
		let account = PFUser.currentUser()
		account?.addUniqueObject(PFObject(withoutDataWithClassName: "Event", objectId: event.objectId), forKey: "savedEvents")
		account?.addUniqueObject(event.name!, forKey: "savedEventNames")
		account?.saveInBackground()
        
        // Add user to Event objects relation
        let eventQuery = PFQuery(className: "Event")
        eventQuery.whereKey("eventName", equalTo: event.name!)
        eventQuery.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]?, error: NSError?) -> Void in
            
			let eventObj = objects!.first as! PFObject
			let relation = eventObj.relationForKey("attendees")
			relation.addObject(PFUser.currentUser()!)
			eventObj.saveInBackground()
            
        }

		// Store event details in user defaults
		NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
		NSUserDefaults.standardUserDefaults().setValue(NSDate.new(), forKey: "checkin_event_time")
		NSUserDefaults.standardUserDefaults().setValue(event.name, forKey: "checkin_event_name")
		
		
		self.performSegueWithIdentifier("display-event-album", sender: self)
	}
	
	func processDoubleTap(sender: UITapGestureRecognizer)
	{
		
		let touchPoint = sender.locationInView(self.collectionView)
		let hitDetect = CGRectContainsPoint(self.collectionView!.bounds, touchPoint)
		if (hitDetect == true) {
			checkIn()
		}

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
				albumViewController.event = Event.fetchOrCreateWhereAttribute("objectId", isValue: currentEventId!) as? Event
			} else {
				let index = self.pickerView?.selectedRowInComponent(0)
				let event = self.events[Int(index!)]
				albumViewController.event = event;
			}
		}
		
	}
	
	
	override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
	{
		if (identifier == "create-event" && NetworkAvailable.networkConnection() == false) {
			
			let alert = NetworkAvailable.networkAlert("No Internet Connection", error: "Connect to the internet to create an event.")
			self.presentViewController(alert, animated: true, completion: nil)
			
			return false
		}
		
		return true
	}
	
	
	
	//-------------------------------------
	// MARK: Data
	//-------------------------------------
	
	func fetchData()
	{
		SwiftLocation.shared.currentLocation(Accuracy.Neighborhood, timeout: 20, onSuccess: { (location) -> Void in
			// location is a CLPlacemark
			print("We have a location!! ")
			print(location)
			

			let config = PFConfig.currentConfig()
			let _events = Event.MR_findAll() as! [Event]
			let nearbyEvents : NSMutableArray = NSMutableArray()
			
			let radius = config["nearby_events_radius"] != nil ? config["nearby_events_radius"]! as! NSNumber : 10 // Default: 10km (It's really in meters here 'cause of legacy, turns to Kms below)
			let region : CLCircularRegion = CLCircularRegion(center: location!.coordinate, radius: (radius.doubleValue * 1000), identifier: "nearby-events-region")
			
			// Filter by event location and attancance
			for event : Event in _events {
				if (event.geoLocation != nil && event.live != nil && Bool(event.live!) == true && event.enabled != nil && Bool(event.enabled!) == true) {
					let coordinate = CLLocationCoordinate2D(latitude: event.geoLocation!.latitude!.doubleValue, longitude: event.geoLocation!.longitude!.doubleValue)
					if (region.containsCoordinate(coordinate)) {
						
						var attended = false
						let attendees = event.attendees!.allObjects as! [Attendance]
						for attendee : Attendance in attendees {
							if (attendee.attendeeId == PFUser.currentUser()!.objectId!) {
								attended = true
								break
							}
						}
						
						if (attended == false) {
							nearbyEvents.addObject(event)
						}
						
					}
				}
			}
			
			
			// Sort by closest to furthest
			nearbyEvents.sortedArrayWithOptions(.Concurrent, usingComparator: { (event1, event2) -> NSComparisonResult in
				
				let location1 = CLLocation(latitude: (event1 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event1 as! Event).geoLocation!.longitude!.doubleValue)
				let location2 = CLLocation(latitude: (event2 as! Event).geoLocation!.latitude!.doubleValue, longitude: (event2 as! Event).geoLocation!.longitude!.doubleValue)
				
				let distance1 : NSNumber = NSNumber(double: location!.distanceFromLocation(location1))
				let distance2 : NSNumber = NSNumber(double: location!.distanceFromLocation(location2))
				
				return distance1.compare(distance2)
			})
			
			
			
			// Update UI
			self.events = (nearbyEvents.copy()) as! [Event]
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				
				self.activityIndicator.stopAnimating()
				self.activityIndicator.hidden = true
				
				self.pickerView?.reloadAllComponents()
				self.collectionView?.reloadData()
				self.pickerView?.hidden = false
				
			})
			
		}) { (error) -> Void in
			// something went wrong
			println("SwiftLocation error :(")
			print(error)
		}

	}
	
}