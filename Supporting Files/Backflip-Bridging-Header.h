//
//  Backflip-Bridging-Header.h
//
//  Copyright 2011-present Backflip Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Branch/Branch.h>
#import <CoreData/CoreData.h>


#import "PreProcessorMacros.h"


#ifndef Bridging_Header
	#define Bridging_Header

	#import "NSManagedObject+FetchOrCreate.h"
	#import "NSManagedObjectContext+Extensions.h"

	#import "ZAActivityBar.h"
	#import "BFDataWrapper.h"

	// Facebook
	#import <FBSDKCoreKit/FBSDKCoreKit.h>
	#import <FBSDKLoginKit/FBSDKLoginKit.h>

	// Analytics yo
	#import <Mixpanel/Mixpanel.h>
	#import <Google/Analytics.h>
	#import "NewRelicAgent/NewRelic.h"

	#import "MWPhotoBrowser.h"
	#import "MWPhotoBrowserPrivate.h"

	// Camera
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
