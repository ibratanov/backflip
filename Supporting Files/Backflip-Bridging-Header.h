//
//  Backflip-Bridging-Header.h
//
//  Copyright 2011-present Backflip Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Branch/Branch.h>
#import <CoreData/CoreData.h>


#ifndef Bridging_Header
	#define Bridging_Header

	#import "NSManagedObject+FetchOrCreate.h"
	#import "NSManagedObjectContext+Extensions.h"

	#import "ZAActivityBar.h"

	//#if FEATURE_FACEBOOK
		#import <FBSDKCoreKit/FBSDKCoreKit.h>
		#import <FBSDKLoginKit/FBSDKLoginKit.h>
	//#endif


	// Analytics yo
	#if FEATURE_MIXPANEL
		#import <Mixpanel/Mixpanel.h>
	#endif

	#if FEATURE_GOOGLE_ANALYTICS
		#import <Google/Analytics.h>
	#endif

	#if FEATURE_NEW_RELIC
		#import "NewRelicAgent/NewRelic.h"
	#endif

	#import "MWPhotoBrowser.h"
	#import "MWPhotoBrowserPrivate.h"

    #import "FastttFilterCamera.h"
	#import "FastttCamera.h"
    #import "UIImage+FastttCamera.h"
    #import "AVCaptureDevice+FastttCamera.h"
    #import "FastttFocus.h"
    #import "FastttFilter.h"
    #import "FastttFilterCamera.h"
    #import "FastttCapturedImage+Process.h"
    #import "FastttLookupFilter.h"
    #import "FastttEmptyFilter.h"


#endif
