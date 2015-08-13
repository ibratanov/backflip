//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Bolts
import Parse
import Fabric
import DigitsKit



@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
    
    //-------Branch
    var inviteImage = UIImage()
    var inviteViewController = InviteViewController(nibName: "InviteViewController", bundle: nil);
    //-------------

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		application.statusBarStyle = .LightContent
		application.setStatusBarStyle(.LightContent, animated: true)
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
		
		//-------New Relic
        NewRelic.startWithApplicationToken("AA19279b875ed9929545dabb319fece8d5b6d04f96")
        //-------Branch
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setImageViewNotification:", name: "MySetImageViewNotification", object: nil)
		

		
		//--------------------------------------
		// Setup Parse & Application appearance
		//--------------------------------------
		setupParse()
		setupApperance()
		
        
        Mixpanel.sharedInstanceWithToken("d2dd67060db2fd97489429fc418b2dea")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
		

        let defaultACL = PFACL();
        
        

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.

            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        //------------Parse Push Notifications------------------------------------
        /*if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }*/
        
        
        let userNotificationTypes = (UIUserNotificationType.Alert |  UIUserNotificationType.Badge |  UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
            // Store the deviceToken in the current Installation and save it to Parse
            let installation = PFInstallation.currentInstallation()
            installation.setDeviceTokenFromData(deviceToken)
            installation.saveInBackground()
        }

        // Used to add the device to the Parse push notification settings.
        PFInstallation.currentInstallation().saveInBackground()
		
		
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		
        //------------------------------------------------------------------------

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			Fabric.with([Digits()])
		});
        
        //--------------------------BRANCH.IO------------------------------------
        
        let branch: Branch = Branch.getInstance()
        //Now a connection can be established between a referring user and a referred user during anysession, not just the very first time a user opens the app.
        branch.initSessionWithLaunchOptions(launchOptions, isReferrable: true, andRegisterDeepLinkHandler: { params, error in
            if (error == nil) {
                // This can now count as a referred session even if this isn't
                // the first time a user has opened the app (aka an "Install").
                //Custom logic goes here --> dependent on access to cloud services
                if((params["referringOut"])  != nil){
                    //image ID
                    let eventIIden: AnyObject? = params["eventId"]
                    //let albumIIden: AnyObject? = params["albumId"]
                    let eventTitle: AnyObject? = params["eventTitle"]
                    
                    // Load information from parse db
                    var queryEvent = PFQuery(className: "Event")
                    queryEvent.limit = 1
                    queryEvent.whereKey("objectId", equalTo: eventIIden!)

                    var qArray = queryEvent.findObjects()
                    
                    if (qArray != nil && qArray!.count != 0) {
                    //self.checkinToEvent(object)
                        var objectE = qArray!.first as! PFObject
                        
                        let query = PFUser.query()
                        
                        if (PFUser.currentUser() != nil) {
                            query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
                                
                                if error != nil {
                                    println(error)
                                }
                                else
                                {
                                    
                                    // Subscribe user to the channel of the event for push notifications
                                    let currentInstallation = PFInstallation.currentInstallation()
                                    currentInstallation.addUniqueObject(("a" + objectE.objectId!) , forKey: "channels")
                                    //currentInstallation.saveInBackground()
                                    currentInstallation.save()
                                    
                                    // Store the relation
                                    let relation = objectE.relationForKey("attendees")
                                    relation.addObject(object!)
                                    
                                    objectE.save()
                                    
                                    // TODO: Check for existing event_list for eventName
                                    var listEvents = object!.objectForKey("savedEventNames") as! [String]
                                    if contains(listEvents, objectE["eventName"] as! String)
                                    {
                                        print("Event already in list")
                                    }
                                    else
                                    {
                                        // Add the event to the User object
                                        object?.addUniqueObject(objectE, forKey:"savedEvents")
                                        object?.addUniqueObject(objectE["eventName"] as! String, forKey:"savedEventNames")
                                        
                                        //object!.saveInBackground()
                                        object!.save()
                                        
                                        
                                        // Add the EventAttendance join table relationship for photos (liked and uploaded)
                                        var attendance = PFObject(className:"EventAttendance")
                                        attendance["eventID"] = objectE.objectId
                                        attendance["attendeeID"] = PFUser.currentUser()?.objectId
                                        attendance["photosLikedID"] = []
                                        attendance["photosLiked"] = []
                                        attendance["photosUploadedID"] = []
                                        attendance["photosUploaded"] = []
                                        attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                                        attendance.setObject(objectE, forKey: "event")
                                        
                                        //attendance.saveInBackground()
                                        attendance.save()
                                        
                                        println("Saved")
                                        let alert = UIAlertView()
                                        alert.title = "Event Invitation"
                                        alert.message = "You have been added to \(eventTitle!)"
                                        alert.addButtonWithTitle("Ok")
                                        
                                        alert.delegate = self
                                        alert.show()
                                    }
                                }
                            })
                        } else {
                            self.displayUnsuccessfulInvite()
                        }
// Part of SMS Invite functionality - temporarily disabled
//                    var topView = UIApplication.sharedApplication().keyWindow?.rootViewController
//                    while (topView?.presentedViewController != nil){
//                        topView = topView!.presentedViewController
//                    }
//
//                    topView?.presentViewController(self.inviteViewController, animated: true, completion: nil)
                    } else {
                        println("Event \(eventIIden!) not found in database")
                    }
                }
            }
        })
        return true
    }
    
    func displayUnsuccessfulInvite() {
        println("Object not found")
        let alert = UIAlertView()
        alert.title = "Event Invite Unsuccessful"
        alert.message = "Please log in and click the invite link again."
        alert.addButtonWithTitle("Ok")
        
        alert.delegate = self
        alert.show()
    }
    
    func checkinToEvent(event: PFObject) {
        let query = PFUser.query()
        
        println(PFUser.currentUser()!.objectId!)
        query!.getObjectInBackgroundWithId(PFUser.currentUser()!.objectId!, block: { (object, error) -> Void in
            
            if error != nil {
                println(error)
            }
            else
            {
            
                // Subscribe user to the channel of the event for push notifications
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.addUniqueObject(("a" + event.objectId!) , forKey: "channels")
                //currentInstallation.saveInBackground()
                currentInstallation.save()
                
                // Store the relation
                let relation = event.relationForKey("attendees")
                relation.addObject(object!)
                
                //                    event.saveInBackgroundWithBlock {
                //                        (success: Bool, error: NSError?) -> Void in
                //                        if (success) {
                //                            // The object has been saved.
                //                            println("\n\nSuccess, event saved \(event.objectId)")
                //                        } else {
                //                            // There was a problem, check error.description
                //                            println("\n\nFailed to save the event object \(error)")
                //                        }
                //                    }
                event.save()
                
                // TODO: Check for existing event_list for eventName
                var listEvents = object!.objectForKey("savedEventNames") as! [String]
                if contains(listEvents, event["eventName"] as! String)
                {
                    print("Event already in list")
                }
                else
                {
                    // Add the event to the User object
                    object?.addUniqueObject(event, forKey:"savedEvents")
                    object?.addUniqueObject(event["eventName"] as! String, forKey:"savedEventNames")
                    
                    //object!.saveInBackground()
                    object!.save()
                    
                    
                    // Add the EventAttendance join table relationship for photos (liked and uploaded)
                    var attendance = PFObject(className:"EventAttendance")
                    attendance["eventID"] = event.objectId
                    attendance["attendeeID"] = PFUser.currentUser()?.objectId
                    attendance["photosLikedID"] = []
                    attendance["photosLiked"] = []
                    attendance["photosUploadedID"] = []
                    attendance["photosUploaded"] = []
                    attendance.setObject(PFUser.currentUser()!, forKey: "attendee")
                    attendance.setObject(event, forKey: "event")
                    
                    //attendance.saveInBackground()
                    attendance.save()
                    
                    println("Saved")
                }
            }
        })
    }
    
    func setImageViewNotification(note: NSNotification){
        
        let userInfo = note.userInfo as! [String: UIImageView]
        let imageView = userInfo["imageView"]
        imageView?.image = self.inviteImage
        self.inviteViewController.imageView.image = self.inviteImage
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                println("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            //println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        println(url)
        println(url.host as String!)
        if(url.host == "events"){
            window?.rootViewController?.performSegueWithIdentifier("gotoEventScene", sender: nil)
        }
        // pass the url to the handle deep link call
        // if handleDeepLink returns true, and you registered a callback in initSessionAndRegisterDeepLinkHandler, the callback will be called with the data associated with the deep link
        if (!Branch.getInstance().handleDeepLink(url)) {
            // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
            println(url)
            println(url.host as String!)
        }
        return true
    }
    

	//--------------------------------------
	// MARK: Apperance
	//--------------------------------------
	
	func setupApperance()
	{
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		let config = PFConfig.currentConfig()
		
		var navigationBarAppearance = UINavigationBar.appearance()
		navigationBarAppearance.tintColor = UIColor.whiteColor()
		
		var bartintColor = "#108475"
		if (config["appearance_navigation_tint"] != nil) {
			bartintColor = config["appearance_navigation_tint"] as! String
		}
		
		navigationBarAppearance.barTintColor = UIColor(rgba: bartintColor)
		
		
		navigationBarAppearance.translucent = false;
		navigationBarAppearance.titleTextAttributes = [
			NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18)!,
			NSForegroundColorAttributeName: UIColor.whiteColor()
		]
		
		var tabBarAppearance = UITabBar.appearance()
		tabBarAppearance.tintColor = (config["appearance_tabbar_tint"] != nil) ? UIColor(rgba:config["appearance_tabbar_tint"] as! String) :  UIColor.whiteColor()
		tabBarAppearance.barTintColor = (config["appearance_tabbar_bartint"] != nil) ? UIColor(rgba:config["appearance_tabbar_bartint"] as! String) :  UIColor.blackColor()
		tabBarAppearance.translucent = true;
		
	}
	
	
	//--------------------------------------
	// MARK: Parse
	//--------------------------------------
	
	func setupParse()
	{
		// Local caching of query results
		Parse.enableLocalDatastore()
		
		#if DEBUG
			Parse.setApplicationId("2wR9cIAp9dFkFupEkk8zEoYwAwZyLmbgJDgX7SiV", clientKey: "3qxnKdbcJHchrHV5ZbZJMjfLpPfksGmHkOR9BrQf")
		#else
			Parse.setApplicationId("TA1LOs2VBEnqvu15Zdl200LyRF1uTiyS1nGtlqUX", clientKey: "maKpXMcM6yXBenaReRcF6HS5795ziWdh6Wswl8e4")
		#endif
		
		
		if (NetworkAvailable.networkConnection()) {
			PFConfig.getConfigInBackgroundWithBlock { (config, error) -> Void in
				self.setupApperance()
			}
		}
	}
	
}




extension UIColor {
	public convenience init(rgba: String) {
		var red:   CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue:  CGFloat = 0.0
		var alpha: CGFloat = 1.0
		
		if rgba.hasPrefix("#") {
			let index   = advance(rgba.startIndex, 1)
			let hex     = rgba.substringFromIndex(index)
			let scanner = NSScanner(string: hex)
			var hexValue: CUnsignedLongLong = 0
			if scanner.scanHexLongLong(&hexValue) {
				switch (count(hex)) {
				case 3:
					red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
					green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
					blue  = CGFloat(hexValue & 0x00F)              / 15.0
				case 4:
					red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
					green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
					blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
					alpha = CGFloat(hexValue & 0x000F)             / 15.0
				case 6:
					red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
					green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
					blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
				case 8:
					red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
					green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
					blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
					alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
				default:
					print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
				}
			} else {
				println("Scan hex error")
			}
		} else {
			print("Invalid RGB string, missing '#' as prefix")
		}
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
}


extension NSDate
{
	func isGreaterThanDate(dateToCompare : NSDate) -> Bool
	{
		//Declare Variables
		var isGreater = false
		
		//Compare Values
		if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
		{
			isGreater = true
		}
		
		//Return Result
		return isGreater
	}
	
	
	func isLessThanDate(dateToCompare : NSDate) -> Bool
	{
		//Declare Variables
		var isLess = false
		
		//Compare Values
		if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
		{
			isLess = true
		}
		
		//Return Result
		return isLess
	}
	
	
	
	func addDays(daysToAdd : Int) -> NSDate
	{
		var secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
		var dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
		
		//Return Result
		return dateWithDaysAdded
	}
	
	
	func addHours(hoursToAdd : Int) -> NSDate
	{
		var secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
		var dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
		
		//Return Result
		return dateWithHoursAdded
	}
}
