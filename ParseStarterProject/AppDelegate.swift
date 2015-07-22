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


// If you want to use any of the UI components, uncomment this line
// import ParseUI

// If you want to use Crash Reporting - uncomment this line
// import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //-------Branch
    var inviteImage = UIImage()
    var inviteViewController = InviteViewController(nibName: "InviteViewController", bundle: nil);
    //-------------

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //-------New Relic
        NewRelic.startWithApplicationToken("AA19279b875ed9929545dabb319fece8d5b6d04f96")
        //-------Branch
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setImageViewNotification:", name: "MySetImageViewNotification", object: nil)
        // Enable storing and querying data from Local Datastore.
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()

        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        
//        /* PROD */
//        Parse.setApplicationId("TA1LOs2VBEnqvu15Zdl200LyRF1uTiyS1nGtlqUX",
//            clientKey: "maKpXMcM6yXBenaReRcF6HS5795ziWdh6Wswl8e4")

        
        /* DEV */
        Parse.setApplicationId("2wR9cIAp9dFkFupEkk8zEoYwAwZyLmbgJDgX7SiV",
            clientKey: "3qxnKdbcJHchrHV5ZbZJMjfLpPfksGmHkOR9BrQf")

        
        Mixpanel.sharedInstanceWithToken("d2dd67060db2fd97489429fc418b2dea")
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("App launched")
        
        //
        // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
        // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
        // Uncomment the line inside ParseStartProject-Bridging-Header and the following line here:
        // PFFacebookUtils.initializeFacebook()
        // ****************************************************************************

        //PFUser.enableAutomaticUser()

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
        
        //------------------------------------------------------------------------

        Fabric.with([Digits()])
        
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
                        
                        //println(PFUser.currentUser()!.objectId!)
                        //issue
                        //fatal error: unexpectedly found nil while unwrapping an Optional value
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
                    //                    var topView = UIApplication.sharedApplication().keyWindow?.rootViewController
//                    while (topView?.presentedViewController != nil){
//                        topView = topView!.presentedViewController
//                    }
//                    
//                    
//                    topView?.presentViewController(self.inviteViewController, animated: true, completion: nil)
                    } else {
                        
                        println("Object not found")
                        let alert = UIAlertView()
                        alert.title = "Event Invite Failed"
                        alert.message = "Please log in and click the invite link again."
                        alert.addButtonWithTitle("Ok")
                        
                        alert.delegate = self
                        alert.show()
                        
                    }
                    
                }
            }
            
        })
        
        return true
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
            //SMSInviteMwars://events---id
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
    
    
    


    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    //     if application.applicationState == UIApplicationState.Inactive {
    //         PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
    //     }
    // }

    //--------------------------------------
    // MARK: Facebook SDK Integration
    //--------------------------------------

    ///////////////////////////////////////////////////////////
    // Uncomment this method if you are using Facebook
    ///////////////////////////////////////////////////////////
    // func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    //     return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication, session:PFFacebookUtils.session())
    // }
}
