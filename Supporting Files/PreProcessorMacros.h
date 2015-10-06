//
//  PreProcessorMacros.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-05.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef PreProcessorMacros

	#define PreProcessorMacros


	#pragma mark -
	#pragma mark Analytics

	extern BOOL const FEATURE_GOOGLE_ANALYTICS;

	extern BOOL const FEATURE_NEW_RELIC;

	extern BOOL const FEATURE_MIXPANEL;


	#pragma mark -
	#pragma mark Coredata

	extern BOOL const FEATURE_COREDATA_SEED;


	#pragma mark -
	#pragma mark Parse

	extern BOOL const FEATURE_PARSE_LOCAL_DATASTORE;


	#pragma mark -
	#pragma mark Facebook

	extern BOOL const FEATURE_FACEBOOK;

#endif
