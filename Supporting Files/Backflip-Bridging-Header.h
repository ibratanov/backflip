//
//  Backflip-Bridging-Header.h
//
//  Copyright 2011-present Backflip Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#if TARGET_OS_IOS
	#import <Branch/Branch.h>
#endif


#import "PreProcessorMacros.h"


#ifndef Bridging_Header
	#define Bridging_Header

	#import "NSManagedObject+FetchOrCreate.h"

	#import "ZAActivityBar.h"
	#import "BFDataWrapper.h"

	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <unistd.h>


	// iOS 9 only..
	#if TARGET_OS_IOS && __IPHONE_9_0
		@import SafariServices;
	#endif


	// SVProgressHUD
	#if TARGET_OS_TV
		#import "SVProgressHUD.h"
	#endif

	// Facebook
	#if TARGET_OS_IOS
		#import <FBSDKCoreKit/FBSDKCoreKit.h>
		#import <FBSDKLoginKit/FBSDKLoginKit.h>
	#endif

	#if TARGET_OS_IOS
		// Analytics yo
		#import <Instabug/Instabug.h>
		#import <Mixpanel/Mixpanel.h>
		#import "Flurry.h"
		#import "NewRelicAgent/NewRelic.h"
	#endif


	// Bonjour
	#if TARGET_OS_TV
		#import "BFBonjourServer.h"
		#import "BFBonjourConnection.h"
	#else
		#import "BFBonjourClient.h"
	#endif

#endif
