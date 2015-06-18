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

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Enable storing and querying data from Local Datastore. 
        // Remove this line if you don't want to use Local Datastore features or want to use cachePolicy.
        Parse.enableLocalDatastore()

        // ****************************************************************************
        // Uncomment this line if you want to enable Crash Reporting
        // ParseCrashReporting.enable()
        //
        // Uncomment and fill in with your Parse credentials:
        Parse.setApplicationId("TA1LOs2VBEnqvu15Zdl200LyRF1uTiyS1nGtlqUX",
            clientKey: "maKpXMcM6yXBenaReRcF6HS5795ziWdh6Wswl8e4")
        
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
            }
        })
        //------------------------------------------------------------------------

        return true
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
