//
//  PreProcessorMacros.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-05.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Availability.h>
#import <Foundation/Foundation.h>


#pragma mark -
#pragma mark Analytics

// We disable analytics on DEBUG builds
#if !DEBUG

	BOOL const FEATURE_GOOGLE_ANALYTICS = YES;

	BOOL const FEATURE_NEW_RELIC = YES;

	BOOL const FEATURE_MIXPANEL = YES;

#endif


#pragma mark -
#pragma mark Coredata

#if DEBUG
	BOOL const FEATURE_COREDATA_SEED = NO;
#else
	BOOL const FEATURE_COREDATA_SEED = YES;
#endif


#pragma mark -
#pragma mark Parse

#if DEBUG
	BOOL const FEATURE_PARSE_LOCAL_DATASTORE = NO;
#else
	BOOL const FEATURE_PARSE_LOCAL_DATASTORE = YES;
#endif


#pragma mark -
#pragma mark Facebook

BOOL const FEATURE_FACEBOOK = YES;

