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
import FBSDKCoreKit
import MagicalRecord



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
		setupCoreData()
		setupApperance()
        
        setupBranch(launchOptions) // Branch.io
        
        
		
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        Mixpanel.sharedInstanceWithToken("d2dd67060db2fd97489429fc418b2dea")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
		

        let defaultACL = PFACL();
        
        

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)

        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)

		
		//--------------------------------------
		// CoreData
		//--------------------------------------
		BFDataFetcher.sharedFetcher.fetchData(true);
		
		
		
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
                let listEvents = object!.objectForKey("savedEventNames") as! [String]
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
                    let attendance = PFObject(className:"EventAttendance")
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
                println("Backflip successfully subscribed to push notifications on the broadcast channel.");
            } else {
                println("Backflip failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
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

        return FBSDKApplicationDelegate.sharedInstance().application(application,
                    openURL: url,
                    sourceApplication: sourceApplication,
                    annotation: annotation)

    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    

	//--------------------------------------
	// MARK: Apperance
	//--------------------------------------
	
	func setupApperance()
	{
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		
		let config = PFConfig.currentConfig()
		
		let navigationBarAppearance = UINavigationBar.appearance()
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
		
		let barButtonAppearance = UIBarButtonItem.appearance()
		barButtonAppearance.tintColor = UIColor.whiteColor()
		
		let tabBarAppearance = UITabBar.appearance()
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
	
	
	//--------------------------------------
	// MARK: CoreData
	//--------------------------------------
	func setupCoreData()
	{
		MagicalRecord.setupCoreDataStack()
	}
	
    
    
    //--------------------------------------
    // MARK: Branch.io
    //--------------------------------------
    func setupBranch(launchOptions: [NSObject: AnyObject]?)
    {
        
        let branch: Branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions, isReferrable: true, andRegisterDeepLinkHandler: { params, error in
            
            if (error == nil) {
                
                if ((params["referringOut"])  != nil) {
                    
                    let eventId =  params["eventId"] as? String
                    if (eventId != nil) {
                        
                        let event : Event = Event.fetchOrCreateWhereAttribute("objectId", isValue: eventId) as! Event
                        var alertController = UIAlertController(title: "Backflip Event Invitation", message: "You have been invited to join "+event.name!+", would you like to check in?", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: "Join", style: .Default, handler: { (alertAction) -> Void in
                            
                            let checkinController : CheckinViewController = CheckinViewController()
                            // checkinController.checkIn(event)
                            
                        }))
                        
                    } else {
                     
                        var alertController = UIAlertController(title: "Backflip Event Invitation", message: "Oops! Appears theres an issue with this invite link. Please try again", preferredStyle: .Alert)
                        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                      
                        let window : UIWindow? = UIApplication.sharedApplication().windows.first! as? UIWindow
                        window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
            }
        })

    }
    
	
}



