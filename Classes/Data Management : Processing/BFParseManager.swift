//
//  BFParseManager.swift
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-15.
//  Copyright © 2015 Backflip. All rights reserved.
//

import Parse
import DigitsKit
import Foundation
import Crashlytics



public class BFParseManager : NSObject
{
	
	public static let sharedManager = BFParseManager.init()
	
	public var _fbLoginManager: FBSDKLoginManager?
	public var fbLoginManager: FBSDKLoginManager {
		get {
			if _fbLoginManager == nil {
				_fbLoginManager = FBSDKLoginManager()
			}
			return _fbLoginManager!
		}
	}
	
	
	private override init()
	{
		super.init()
	}
	
	
	
	/**
		Checkin to an event

		- Parameters:
			- eventId: event's ObjectId
			- uponComplretion: Completion handler
	*/
	public func checkin(eventId : String, uponCompletion completion: ((completed : Bool, error : NSError?) -> Void)?) -> Void
	{
		// Display a HUD letting the user know we're checking them in
		PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Checking in..")
		PKHUD.sharedHUD.show()
		
		
		let event = Event.MR_findFirstByAttribute("objectId", withValue: eventId)

		// Store channel for push notifications
		let currentInstallation = PFInstallation.currentInstallation()
		currentInstallation.addUniqueObject("a"+eventId, forKey: "channels")
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
				eventQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
					let eventObj = objects!.first
					let relation = eventObj!.relationForKey("attendees")
					relation.addObject(PFUser.currentUser()!)
					eventObj!.saveInBackground()
				})
				
				// Store event details in user defaults
				NSUserDefaults.standardUserDefaults().setValue(event.objectId!, forKey: "checkin_event_id")
				NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: "checkin_event_time")
				NSUserDefaults.standardUserDefaults().setValue(event.name, forKey: "checkin_event_name")
				NSUserDefaults.standardUserDefaults().synchronize()

				PKHUD.sharedHUD.hideAnimated()

				if (completion != nil) {
					completion!(completed: true, error: nil)
				}

				return
			})
			
		}
	}
	
	
	/**
		Event creation
	
		- Parameters:
			- name: Event name
			- address: Event address (will be Geocoded)
			- uponComplretion: Completion handler
	*/
	public func createEvent(name : String, address : String, uponCompletion completion: (completed : Bool, error : NSError?) -> Void) -> Void
	{
		// Network reachability checking
		guard Reachability.validNetworkConnection() else {
			return completion(completed: false, error: NSError(domain: "com.backflip.reachability.parse", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid network connection"]))
		}
		
		
		
		// Display HUD with event creation notice
		PKHUD.sharedHUD.contentView = PKHUDTextView(text: "Creating event..")
		PKHUD.sharedHUD.show()
		
		
		PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint, error) -> Void in
			
			guard geoPoint != nil else {
				print("📛 Parse error (geoPoint) \(error)")
				return completion(completed: false, error: NSError(domain: "com.backflip.parse", code: 500, userInfo: nil))
			}
			
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
				
				// Check event doesn't already exist
				var eventObjects : [PFObject]?
				let eventQuery = PFQuery(className: "Event")
				eventQuery.whereKey("eventName", equalTo: name)
				do {
					try eventObjects = eventQuery.findObjects()
				} catch {
					print("📛 Parse error (eventQuery) \(error)")
					return completion(completed: false, error: NSError(domain: "com.backflip.parse", code: 500, userInfo: nil))
				}
				
				
				// check if the event exists..
				guard eventObjects?.count < 1 else {
					return completion(completed: false, error:  NSError(domain: "com.backflip.parse.duplicate", code: 501, userInfo: [NSLocalizedDescriptionKey: "Event already exists, object = \(eventObjects?.first)"]))
				}
				
				
				let eventObject = PFObject(className: "Event")
				eventObject["geoLocation"] = geoPoint
				eventObject["eventName"] = name
				eventObject["venue"] = address
				eventObject["startTime"] = NSDate()
				eventObject["isLive"] = true
				eventObject["enabled"] = true
				eventObject["owner"] = PFUser.currentUser()
				
				let ACL = PFACL(user: PFUser.currentUser()!)
				ACL.setPublicReadAccess(true)
				ACL.setPublicWriteAccess(true)
				eventObject.ACL = ACL
				
				let relation = eventObject.relationForKey("attendees")
				relation.addObject(PFUser.currentUser()!)
				
				do {
					try eventObject.save()
				} catch {
					print("📛 Parse error (eventObject) \(error)")
					return completion(completed: false, error: NSError(domain: "com.backflip.parse", code: 500, userInfo: nil))
				}
				
				
				// Update the user
				PFUser.currentUser()?.addUniqueObject(eventObject, forKey:"savedEvents")
				PFUser.currentUser()?.addUniqueObject(name, forKey:"savedEventNames")
				PFUser.currentUser()?.saveInBackground()
				
				
				// Add the EventAttendance join table relationship for photos (liked and uploaded)
				let attendance = PFObject(className:"EventAttendance")
				attendance["eventID"] = eventObject.objectId
				attendance["attendeeID"] = PFUser.currentUser()?.objectId
				attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
				attendance.setObject(eventObject, forKey: "event")
				attendance["photosLikedID"] = []
				attendance["photosLiked"] = []
				attendance["photosUploadedID"] = []
				attendance["photosUploaded"] = []
				attendance["enabled"] = true
				
				attendance.saveInBackgroundWithBlock({ (success, error) -> Void in
					
					let attendees : [PFObject] = [attendance]
					BFDataProcessor.sharedProcessor.processEvents([eventObject], completion: { () -> Void in
						
						BFDataProcessor.sharedProcessor.processAttendees(attendees, completion: { () -> Void in
							
							// Store event details in user defaults
							NSUserDefaults.standardUserDefaults().setValue(eventObject.objectId!, forKey: "checkin_event_id")
							NSUserDefaults.standardUserDefaults().setValue(NSDate(), forKey: "checkin_event_time")
							NSUserDefaults.standardUserDefaults().setValue(name, forKey: "checkin_event_name")
							NSUserDefaults.standardUserDefaults().synchronize()
							
							dispatch_async(dispatch_get_main_queue(), { () -> Void in
								
								PKHUD.sharedHUD.hideAnimated()
								
								completion(completed: true, error: nil)
								
							})
							
						})
					})
					
				})
			})

		}
		
	}
	
	
	
	/**
		Login with provided credentials
	
		- Parameters:
			- digitsSession:
	*/
	public func login(digitsSession: DGTSession?, facebookResult: FBSDKLoginManagerLoginResult?, uponCompletion completion: (completed : Bool, error : NSError?) -> Void) -> Void
	{
		// Network reachability checking
		guard Reachability.validNetworkConnection() else {
			return completion(completed: false, error: NSError(domain: "com.backflip.reachability.parse", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid network connection"]))
		}
		
		
		// Login via Facebook
		if (facebookResult != nil && FBSDKAccessToken.currentAccessToken() != nil) {
			print("Facebook Result = \(facebookResult!.token.userID)")
			let graphRequest = FBSDKGraphRequest(graphPath: facebookResult!.token.userID!, parameters: ["fields": "id, about, email, first_name, last_name, name"])
			graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
					
				if (error != nil) {
					print("Facebook error \(error)")
					return completion(completed: false, error: error)
				} else {
					let facebookId = result.valueForKey("id") as? String
					let emailAddress = result.valueForKey("email") as? String
					let firstName = result.valueForKey("first_name") as? String
					let lastName = result.valueForKey("last_name") as? String
					
					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
						self.login(firstName, lastName: lastName, emailAddress: emailAddress, facebookId: facebookId, phoneNumber: nil, uponCompletion: completion)
					})
				}
			}
		} else if (digitsSession != nil) { // Login via Digits
				
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
				print("Login via digitsSession..")
				let phoneNumber = digitsSession!.phoneNumber
				self.login(nil, lastName: nil, emailAddress: nil, facebookId: nil, phoneNumber: phoneNumber, uponCompletion: completion)
			})
		}
			
	}
	
	
	
	private func login(firstName: String?, lastName: String?, emailAddress: String?, facebookId: String?, phoneNumber: String?, uponCompletion completion: (completed : Bool, error : NSError?) -> Void) -> Void
	{
		
		let deviceQuery = PFUser.query()
		deviceQuery?.whereKey("UUID", equalTo: UIDevice.currentDevice().uniqueDeviceIdentifier())
		deviceQuery?.limit = 1
		var devices : [PFUser]?
		do {
			try devices = deviceQuery?.findObjects() as? [PFUser]
		} catch {
			print("Error with deviceQuery #1")
		}
		
		// Not the first time, authenticate based on their device's UUID
		if (devices?.count < 1) {
		
			let userQuery = PFUser.query()
			print("facebook id = \(facebookId). phone Number = \(phoneNumber)")
			userQuery?.whereKey("username", equalTo: ((facebookId != nil) ? facebookId! : phoneNumber!) )
			var users : [PFUser]?
			do {
				try users = userQuery?.findObjects() as? [PFUser]
			} catch {
				print("Error with userQuery #1")
			}
			
			if (users?.count > 0) {
				
				let user = users?.first
				var password = (user!.username!.characters.contains("+") == false) ? "backflip-pass-"+user!.username! :  "Password"
				if (user != nil && user!["facebook_id"] != nil) {
					password = "backflip-pass-"+user!.username!
				}
				
				print("(devices.count < 1) Attemping to login with username \(user!.username!), password = \(password)")
				PFUser.logInWithUsernameInBackground(user!.username!, password: password, block: { (user : PFUser?, error) -> Void in
					
					if (error == nil && user != nil) {
						
						user!.password = "backflip-pass-"+user!.username!
						user!["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
						user!["password_updated"] = true
						
						if (phoneNumber != nil) {
							user!["phone"] = phoneNumber
						}
						
						if (facebookId != nil) {
							user!["facebook_id"] = NSNumber(integer: Int(facebookId!)!)
							user!["email"] = emailAddress
							user!["facebook_name"] = "\(firstName!) \(lastName!)"
						}
						
						user!.saveInBackgroundWithBlock(nil)
						
						self.loginAnalytics(user!["email"] as? String, objectId: user!.objectId!, fullName: user!["facebook_name"] as? String, phoneNumber: user!["phone"] as? String)
						
						return completion(completed: true, error: nil)
					} else {
						return completion(completed: false, error: error)
					}
					
				})
				
			} else {
				// First time sign-up
				self.createUser(firstName, lastName: lastName, emailAddress: emailAddress, facebookId: facebookId, phoneNumber: phoneNumber, uponCompletion: completion)
			}
			
		} else if (devices?.count > 0) {
			
			let user = devices?.first
			var password = (user!.username!.characters.contains("+") == false) ? "backflip-pass-"+user!.username! : "Password"
			if (user != nil && user!["facebook_id"] != nil) {
				password = "backflip-pass-"+user!.username!
			}
			
			if (user != nil && user!["password_updated"] != nil && (user!["password_updated"] as! Bool) == true) {
				password = "backflip-pass-"+user!.username!
			} else {
				password = "Password"
			}
			
			
			print("(devices.count > 0) Attemping to login with username \(user!.username!), password = \(password)")
			PFUser.logInWithUsernameInBackground(user!.username!, password: password, block: { (user : PFUser?, error) -> Void in
				
				if (error == nil && user != nil) {
					
					user!.password = "backflip-pass-"+user!.username!
					user!["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
					user!["password_updated"] = true
					
					if (phoneNumber != nil) {
						user!["phone"] = phoneNumber
					}
					
					if (facebookId != nil) {
						user!["facebook_id"] = NSNumber(double: Double(facebookId!)!)
						user!["email"] = emailAddress
						user!["facebook_name"] = "\(firstName!) \(lastName!)"
					}
					
					user!.saveInBackgroundWithBlock(nil)
					
					self.loginAnalytics(user!["email"] as? String, objectId: user!.objectId!, fullName: user!["facebook_name"] as? String, phoneNumber: user!["phone"] as? String)
					
					return completion(completed: true, error: nil)
				} else {
					return completion(completed: false, error: error)
				}
				
			})
			
		}
		
		
		
	}
	
	private func loginAnalytics(emailAddress: String?, objectId: String, fullName: String?, phoneNumber: String?)
	{
		Crashlytics.sharedInstance().setUserIdentifier(objectId)
		
		if (emailAddress != nil) {
			Crashlytics.sharedInstance().setUserEmail(emailAddress)
		}

		if (fullName != nil) {
			Crashlytics.sharedInstance().setUserName(fullName)
		}
		
		if (phoneNumber != nil) {
			Crashlytics.sharedInstance().setObjectValue("phoneNumber", forKey: phoneNumber!)
		}
	}
	
	
	private func createUser(firstName: String?, lastName: String?, emailAddress: String?, facebookId: String?, phoneNumber: String?, uponCompletion completion: (completed : Bool, error : NSError?) -> Void) -> Void
	{
		let user = PFUser()
		if (facebookId != nil) {
			user.username = facebookId
			user.password = "backflip-pass-\(facebookId!)"
			user["facebook_id"] = NSNumber(double: Double(facebookId!)!)
			user["email"] = emailAddress
			user["facebook_name"] = "\(firstName!) \(lastName!)"
		} else {
			user.username = phoneNumber
			user.password = "backflip-pass-\(phoneNumber!)"
			user["phone"] = phoneNumber
		}

		user["photosLiked"] = []
		user["savedEvents"] = []
		user["savedEventNames"] = []
		user["UUID"] = UIDevice.currentDevice().uniqueDeviceIdentifier()
		user["blocked"] = false
		user["firstUse"] = true
		user["password_updated"] = true
		
		print("Signing up with username '\(user.username!)', and password '\(user.password!)'.")
		user.signUpInBackgroundWithBlock({ (success, error) -> Void in
			
			if (error == nil) {
				return completion(completed: true, error: nil)
			} else {
				return completion(completed: false, error: error)
			}
			
		})
		
	}



	public func handleInviteLink(params: NSDictionary?, error: NSError?)
	{
		guard error == nil else { return print("🚨 Deep linking error \(error!)") }
		guard params != nil else { return print("🚨 Deep linking provided no params dictionary") }


		let params = params!
		let eventId = params["eventObject"] as? String

		if (params["referringOut"] != nil && eventId != nil) {

			let window : UIWindow? = UIApplication.sharedApplication().windows.first
			let event : Event = Event.MR_findFirstByAttribute("objectId", withValue: eventId!)
			let attendances = Attendance.MR_findByAttribute("attendeeId", withValue: PFUser.currentUser()?.objectId) as? [Attendance]
			if (attendances != nil || attendances?.count > 0) {
				for attendance in attendances! {
					if (attendance.event?.objectId == event.objectId) {

						// Previously attended, point them to where they can find it in their event history
						let alertController = UIAlertController(title: "Backflip Event Invitation", message: "You have been invited to join "+event.name!+". You've previously checked into this event. Find it in your 'Current Event' or 'Event History' below.", preferredStyle: .Alert)
						alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
						window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

						return
					}

				}
			}
			
			
			

			let currentlyCheckedIn = NSUserDefaults.standardUserDefaults().valueForKey("checkin_event_id")
			if (currentlyCheckedIn != nil) {
				let currentEvent = Event.MR_findFirstByAttribute("objectId", withValue: currentlyCheckedIn)

				
				let alertController = UIAlertController(title: "Backflip Event Invitation", message: "You have been invited to join \(event.name!). You're currently checked into \(currentEvent.name!). Do you want to leave this event and join \(event.name!)?", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in

					// Check out
					NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_id")
					NSUserDefaults.standardUserDefaults().removeObjectForKey("checkin_event_time")
					NSUserDefaults.standardUserDefaults().synchronize()

					self.checkin(event.objectId!, uponCompletion: { (completed, error) -> Void in
						if window?.rootViewController as? UITabBarController != nil {
							let tabbarController = window!.rootViewController as! UITabBarController
							let navigationController = tabbarController.viewControllers?.first as? UINavigationController
							
							let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
							let checkinViewController = storyboard.instantiateViewControllerWithIdentifier("CheckinViewController") as! CheckinViewController
							navigationController?.setViewControllers([checkinViewController], animated: false)
							
						}
					})
				}))
				window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

				return
			}



			// Standard check-in
			if (event.name != nil) {
				let alertController = UIAlertController(title: "Backflip Event Invitation", message: "You have been invited to join "+event.name!+", would you like to check in?", preferredStyle: .Alert)
				alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
				alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
					self.checkin(event.objectId!, uponCompletion: {  (completed, error) -> Void in
						
						if UIApplication.sharedApplication().windows.first!.rootViewController as? UITabBarController != nil {
							let tababarController = (UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController
							tababarController.selectedIndex = 0
						}
						
					})
				}))
				window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

				return
			}


			// Default to displaying an error otherwise
			let alertController = UIAlertController(title: "Backflip Event Invitation", message: "Oops! Appears theres an issue with this invite link. Please try again", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
			window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)


		}

	}

}
