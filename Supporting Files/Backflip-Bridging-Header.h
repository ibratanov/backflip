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

	// If you are using Facebook, uncomment this line to get automatic import of the header inside your project.
	#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


	#import <SystemConfiguration/SystemConfiguration.h>
	#import <MobileCoreServices/MobileCoreServices.h>

	#import "NSManagedObject+FetchOrCreate.h"
	#import "NSManagedObjectContext+Extensions.h"
	#import "NSManagedObject+MagicalAggregation.h"

	#import "ZAActivityBar.h"

	#import "AFNetworking.h"
	#import "UIKit+AFNetworking.h"
	#import "UIImageView+AFNetworking.h"

	// Analytics yo
	#import <Mixpanel/Mixpanel.h>
	//#import "GoogleAnalytics.h"
    #import <Google/Analytics.h>
	#import "NewRelicAgent/NewRelic.h"

	#import "MWPhotoBrowser.h"
	#import "MWPhotoBrowserPrivate.h"
    #import <FastttFilterCamera.h>

    #import "UIImage+FastttCamera.h"
    #import "AVCaptureDevice+FastttCamera.h"
    #import "FastttFocus.h"
    #import "FastttFilter.h"
    #import "FastttFilterCamera.h"
    #import "FastttCapturedImage+Process.h"
    #import "FastttLookupFilter.h"
    #import "FastttEmptyFilter.h"


#endif
