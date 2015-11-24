//
//  AppDelegate.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit

import Parse
import Fabric
import DigitsKit
import FBSDKCoreKit
import Crashlytics


@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
	var bonjourClient = BFBonjourClient()

    //--------------------------------------
    // MARK: - UIApplicationDelegate
    //--------------------------------------

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
				
		//--------------------------------------
		// Setup Parse & Application appearance
		//--------------------------------------
		setupAnalytics()
		setupParse()
		setupBranch(launchOptions)
		setupCoreData()
		setupApperance()

		
		//--------------------------------------
		// Coredata
		//--------------------------------------
		BFDataFetcher.sharedFetcher.fetchData(false);
		
		
		//--------------------------------------
		// Facebook
		//--------------------------------------
		FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		
		
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
		
		#if arch(i386) || arch(x86_64)
			print("📲 Disabling push notifications for the simulator")
		#else
			let userNotificationTypes: UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]);
        
			let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
			application.registerUserNotificationSettings(settings)
			application.registerForRemoteNotifications()
		#endif
			
		PFInstallation.currentInstallation().saveInBackground()
		
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			// Fabric.sharedSDK().debug = true
			Fabric.with([Digits.self, Crashlytics.self])
		});
        
		
        return true
    }

    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
	{
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("", block: { (succeeded: Bool, error: NSError?) -> Void in
            if succeeded {
                print("Backflip successfully subscribed to push notifications on the broadcast channel.");
            } else {
                print("Backflip failed to subscribe to push notifications on the broadcast channel with error = %@.", error)
            }
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
	{
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject])
	{
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }


	//--------------------------------------
	// MARK: Deep linking
	//--------------------------------------

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
	{
		
        if (!Branch.getInstance().handleDeepLink(url)) {
            // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
            print(url)
            print(url.host as String!)
        }

		
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                    openURL: url,
                    sourceApplication: sourceApplication,
                    annotation: annotation)

    }
	
	
	func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool
	{
		if #available(iOS 9.0, OSX 10.10, watchOS 2, *) {
			Branch.getInstance().continueUserActivity(userActivity);
		}
			
		return true
	}
	
	
    func applicationDidBecomeActive(application: UIApplication)
	{
        FBSDKAppEvents.activateApp()
    }

    

	//--------------------------------------
	// MARK: Apperance
	//--------------------------------------
	
	func setupApperance()
	{
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
		
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
		if DEBUG_PARSE {
			Parse.setLogLevel(.Debug)
		}
		
		#if DEBUG
			Parse.setApplicationId("2wR9cIAp9dFkFupEkk8zEoYwAwZyLmbgJDgX7SiV", clientKey: "3qxnKdbcJHchrHV5ZbZJMjfLpPfksGmHkOR9BrQf")
		#else
			Parse.setApplicationId("TA1LOs2VBEnqvu15Zdl200LyRF1uTiyS1nGtlqUX", clientKey: "maKpXMcM6yXBenaReRcF6HS5795ziWdh6Wswl8e4")
		#endif
		
		// Default ACL
		let defaultACL = PFACL();
		defaultACL.publicReadAccess = true
		defaultACL.publicWriteAccess = true
		PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
		
		if (Reachability.validNetworkConnection()) {
			PFConfig.getConfigInBackgroundWithBlock { (config, error) -> Void in
				self.setupApperance()
			}
		}
	}





	//--------------------------------------
	// MARK: Analytics
	//--------------------------------------
	
	func setupAnalytics()
	{
		if (FEATURE_INSTABUG) {
			Instabug.startWithToken("510f98f8d22d87efdf38fcdcaa64ce78", captureSource: IBGCaptureSourceUIKit, invocationEvent: IBGInvocationEventShake)
		}
			
		
		if (FEATURE_MIXPANEL) {
			Mixpanel.sharedInstanceWithToken("d2dd67060db2fd97489429fc418b2dea")
			let mixpanel: Mixpanel = Mixpanel.sharedInstance()
			mixpanel.track("App launched")
		}
        
        if (FEATURE_FLURRY) {
            Flurry.startSession("5ZH2SGGPCVDPDKS5KS83")
            Flurry.logEvent("User:\(PFUser.currentUser()?.objectId) Started Application")
        }
	}
	
	
	
	//--------------------------------------
	// MARK: CoreData
	//--------------------------------------
	
	func setupCoreData()
	{
		BFDataMananger.sharedManager.setupDatabase()
	}
	
	
    //--------------------------------------
    // MARK: Branch.io
    //--------------------------------------
	
    func setupBranch(launchOptions: [NSObject: AnyObject]?)
    {
		Branch.getInstance().initSessionWithLaunchOptions(launchOptions, isReferrable: true, andRegisterDeepLinkHandler: { params, error in
			BFParseManager.sharedManager.handleInviteLink(params, error: error)
		})
    }
    
	
}



