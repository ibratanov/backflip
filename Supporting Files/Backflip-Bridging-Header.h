//
//  ParseStarterProject-Bridging-Header.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Branch/Branch.h>

#ifndef Bridging_Header
	#define Bridging_Header


	// If you are using Facebook, uncomment this line to get automatic import of the header inside your project.
	#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


	#import <SystemConfiguration/SystemConfiguration.h>
	#import <MobileCoreServices/MobileCoreServices.h>

	#import "AFNetworking.h"
	#import "UIKit+AFNetworking.h"

	// Analytics yo
	#import <Mixpanel/Mixpanel.h>
	#import "GoogleAnalytics.h"
	#import "NewRelicAgent/NewRelic.h"

	#import "MWPhotoBrowser.h"
	#import "MWPhotoBrowserPrivate.h"


#endif
