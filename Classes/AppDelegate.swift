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


@UIApplicationMain
class AppDelegate : UIResponder, UIApplicationDelegate
{

    var window: UIWindow?
	

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
		setupCaching()
		setupBranch(launchOptions)
		setupCoreData()
		setupApperance()

		if FEATURE_ENABLE_BONJOUR {
			BonjourService.sharedService.registerService()
		}

		//--------------------------------------
		// Watchdog
		//--------------------------------------
		#if DEBUG
			let _ = Watchdog(threshold: 0.1) { duration in
				print("👮 Main thread was blocked for " + String(format:"%.2f", duration) + "s 👮")
			}
		#endif

		
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
			Fabric.with([Digits()])
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
		// Local caching of query results
		#if FEATURE_PARSE_LOCAL
			Parse.enableLocalDatastore()
		#endif


		if DEBUG_PARSE {
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveWillSendURLRequestNotification:", name: PFNetworkWillSendURLRequestNotification, object: nil)
			NSNotificationCenter.defaultCenter().addObserver(self, selector: "receiveDidReceiveURLResponseNotification:", name: PFNetworkDidReceiveURLResponseNotification, object: nil)

			Parse.setLogLevel(.Debug)
		}

		#if DEBUG
			Parse.setApplicationId("2wR9cIAp9dFkFupEkk8zEoYwAwZyLmbgJDgX7SiV", clientKey: "3qxnKdbcJHchrHV5ZbZJMjfLpPfksGmHkOR9BrQf")
		#else
			Parse.setApplicationId("TA1LOs2VBEnqvu15Zdl200LyRF1uTiyS1nGtlqUX", clientKey: "maKpXMcM6yXBenaReRcF6HS5795ziWdh6Wswl8e4")
		#endif


		
		// Default ACL
		let defaultACL = PFACL();
		defaultACL.setPublicReadAccess(true)
		PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
		
		if (Reachability.validNetworkConnection()) {
			PFConfig.getConfigInBackgroundWithBlock { (config, error) -> Void in
				self.setupApperance()
			}
		}
	}


	func receiveWillSendURLRequestNotification(notification: NSNotification)
	{
		guard notification.userInfo != nil else { return }

		let request = notification.userInfo![PFNetworkNotificationURLRequestUserInfoKey] as? NSURLRequest
		guard request != nil else { return }

		print("URL: \(request!.URL!.absoluteString)")
		print("Method: \(request!.HTTPMethod)")
		print("Headers: \(request!.allHTTPHeaderFields)")

		if (request?.HTTPBody != nil) {
			let httpBody = NSString(data: request!.HTTPBody!, encoding: NSUTF8StringEncoding)
			print("Request Body: \(httpBody)")
		}
	}

	func receiveDidReceiveURLResponseNotification(notification: NSNotification)
	{
		guard notification.userInfo != nil else { return }

		// let request = notification.userInfo![PFNetworkNotificationURLRequestUserInfoKey] as! NSURLRequest
		let response = notification.userInfo![PFNetworkNotificationURLResponseUserInfoKey] as! NSHTTPURLResponse
		let responseBody = notification.userInfo![PFNetworkNotificationURLResponseBodyUserInfoKey] as! NSString
		print("URL: \(response.URL!.absoluteString)")
		print("Status code: \(response.statusCode)")
		print("Headers: \(response.allHeaderFields)")
		print("Response Body: \(responseBody)")
	}





	//--------------------------------------
	// MARK: Analytics
	//--------------------------------------
	
	func setupAnalytics()
	{
		#if FEATURE_GOOGLE_ANALYTICS
		
            //-------Google Analytics
            // Configure tracker from GoogleService-Info.plist.
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            
            // Optional: configure GAI options.
            let gai = GAI.sharedInstance()
            gai.trackUncaughtExceptions = true  // report uncaught exceptions
            gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
            
            //-----------Google Analytics
            
            // var dimensionValue = "\(PFUser.currentUser()?.objectId)"
            // gai.set(GAIFields.customDimensionForIndex(1), value: PFUser.currentUser()?.objectId)
            //gai.set(customDimensionForIndex:1, value: dimensionValue)
            //method called when a user signs in to an authentication system
            //GAI.sharedInstance().defaultTracker.set("&uid", value: PFUser.currentUser()?.objectId)
        
		#endif
		
		if (FEATURE_INSTABUG) {
			Instabug.startWithToken("510f98f8d22d87efdf38fcdcaa64ce78", captureSource: IBGCaptureSourceUIKit, invocationEvent: IBGInvocationEventShake)
		}
			
		
		if (FEATURE_NEW_RELIC) {
			NewRelic.startWithApplicationToken("AA19279b875ed9929545dabb319fece8d5b6d04f96")
		}
		
		if (FEATURE_MIXPANEL) {
			Mixpanel.sharedInstanceWithToken("d2dd67060db2fd97489429fc418b2dea")
			let mixpanel: Mixpanel = Mixpanel.sharedInstance()
			mixpanel.track("App launched")
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
	// MARK: Caching
	//--------------------------------------
	
	func setupCaching()
	{
		#if DEBUG
			print("📁 Diskcache \(NSURLCache.sharedURLCache().currentDiskUsage) of \(NSURLCache.sharedURLCache().diskCapacity)")
			print("📁 Memorycache \(NSURLCache.sharedURLCache().currentMemoryUsage) of \(NSURLCache.sharedURLCache().memoryCapacity)")
		#endif
		
		
		let memoryCacheSize = 100*1024*1024 // 100 MB
		let diskCacheSize = 500*1024*1024 // 500 MB
		
		let sharedCache = NSURLCache(memoryCapacity: memoryCacheSize, diskCapacity: diskCacheSize, diskPath: "backflip-nsurl-cache")
		NSURLCache.setSharedURLCache(sharedCache)
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



