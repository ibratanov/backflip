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

	// Facebook
	#if TARGET_OS_IOS
		#import <FBSDKCoreKit/FBSDKCoreKit.h>
		#import <FBSDKLoginKit/FBSDKLoginKit.h>
	#endif

	#if TARGET_OS_IOS
		// Analytics yo
		#import <Instabug/Instabug.h>
		#import <Mixpanel/Mixpanel.h>
		#import <Google/Analytics.h>
		#import "NewRelicAgent/NewRelic.h"

		// #import "MWPhotoBrowser.h"
		// #import "MWPhotoBrowserPrivate.h"
	#endif

#endif
