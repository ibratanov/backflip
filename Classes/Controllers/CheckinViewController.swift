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
import MapleBacon
import CoreLocation



class CheckinViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource
{
	var shakeCount : Int = 0
	var events : [Event] = []
	var doubleTapGesture : UITapGestureRecognizer?
	
	let CELL_REUSE_IDENTIFIER = "album-cell"
	
	@IBOutlet var pickerView : UIPickerView?
	@IBOutlet var collectionView : UICollectionView?
	
	@IBOutlet weak var previewLabel : UILabel!
    @IBOutlet weak var checkinButton: UIButton!
	@IBOutlet weak var activityIndicator : UIActivityIndicatorView!
	

	//-------------------------------------
	// MARK: Memory
	//-------------------------------------
	
	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		
		MapleBaconStorage.sharedStorage.clearMemoryStorage()
	}
	
	
	
	//-------------------------------------
	// MARK: Pop, lock and shake
	//-------------------------------------
	
	override func canBecomeFirstResponder() -> Bool
	{
		return true
	}
	
	override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?)
	{
		if motion == .MotionShake {
			shakeCount++
			if (shakeCount > 3) {
				self.presentViewController(GameViewController(), animated: true, completion: nil)
				shakeCount = 0
			}
		}
	}
	
	
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
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("fetchData"), name: nEventObjectsUpdated, object: nil)
		
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

		if (PFUser.currentUser() != nil && PFUser.currentUser()?.objectId != nil) {
            fetchData()
			
			BFDataFetcher.sharedFetcher.fetchDataInBackground({ (completed) -> Void in
				self.fetchData()
			})
        }
		
		
		#if FEATURE_GOOGLE_ANALYTICS
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Checkin view")
            //tracker.set("&uid", value: PFUser.currentUser()?.objectId)
            tracker.set(GAIFields.customDimensionForIndex(2), value: PFUser.currentUser()?.objectId)
            
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])

		#endif
	}
	
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
	
        // Useful when dismissing a dialogue on the checkin screen - updates nearby events.
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
			cell.imageView!.image = UIImage(named: "check-in-screen-double-tap")
			
		} else if (event.photos!.count != 0 && event.photos!.count > indexPath.row) {
			let photo : Photo = event.photos!.allObjects[indexPath.row] as! Photo
			cell.imageView!.setImageWithURL(NSURL(string: photo.thumbnail!.url!.stringByReplacingOccurrencesOfString("http://", withString: "https://"))!)
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
			let authorizationStatus = CLLocationManager.authorizationStatus()
			if (authorizationStatus != .AuthorizedWhenInUse) {
				return "Unable to get location"
			} else {
				return "No nearby events"
			}
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
	// MARK: Actions
	//-------------------------------------
	
	@IBAction func logout()
	{
		let alertController = UIAlertController(title: "Are you sure you want to logout?", message:"", preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
		alertController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { (alertAction) -> Void in
			PFUser.logOut()
			
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
			NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
			NSUserDefaults.standardUserDefaults().synchronize()
			
			FBSDKLoginManager().logOut()
			FBSDKAccessToken.setCurrentAccessToken(nil)
			
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
				let event = Event.MR_findFirstByAttribute("objectId", withValue: currentEventId!)
				albumViewController.event = event
				// albumViewController.event = Event.fetchOrCreateWhereAttribute("objectId", isValue: currentEventId!) as? Event
			} else {
				let index = self.pickerView?.selectedRowInComponent(0)
				let event = self.events[Int(index!)]
				albumViewController.event = event;
			}
		}
	}
	
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
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
		let authorizationStatus = CLLocationManager.authorizationStatus()
		if (authorizationStatus == .NotDetermined) {
			
			if (PFUser.currentUser() != nil) {
				var onceToken: dispatch_once_t = 0
				dispatch_once(&onceToken) {
					BFLocationManager.sharedManager.requestAuthorization({ (status, error) -> Void in
					
						if (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
							self.fetchData()
						} else {
							self.handleLocationError(error)
						}
					
					})
				}
			}

			// We return to stop attemping to call .fetchLocation
			return
		}


		BFLocationManager.sharedManager.fetchLocation(.House) { (location, error) -> Void in
			
			if (error != nil) {
				return self.handleLocationError(error)
			}
			
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
							if (PFUser.currentUser() != nil && attendee.attendeeId == PFUser.currentUser()!.objectId!) {
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
			
		}
	}
	
	
	
	func handleLocationError(error : NSError?)
	{
		
		let authorizationStatus = CLLocationManager.authorizationStatus()
		if (authorizationStatus == .Denied || authorizationStatus == .Restricted) {
			let alertController = UIAlertController(title: "Location Services", message: "We require location services to find nearby events, Please enable Location Services in settings", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
				
				let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
				dispatch_after(delayTime, dispatch_get_main_queue()) {
					if (UIApplication.sharedApplication().canOpenURL(NSURL(string: UIApplicationOpenSettingsURLString)!) == true) {
						UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
					}
				}
				
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			
			self.presentViewController(alertController, animated: true, completion: nil)
		} else {
			
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				
				self.fetchData()
				
			}
			
		}
	}
	
}