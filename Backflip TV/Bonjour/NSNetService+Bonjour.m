//
//  NSNetService+Bonjour.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import "NSNetService+Bonjour.h"

@implementation NSNetService (Bonjour)


/**
 * The following works around three problems with
 * -[NSNetService getInputStream:outputStream:]:
 *
 * o <rdar://problem/6868813> -- Currently the returns the streams with
 * +1 retain count, which is counter to Cocoa conventions and results in
 * leaks when you use it in ARC code.
 *
 * o <rdar://problem/9821932> -- If you create two pairs of streams from
 * one NSNetService and then attempt to open all the streams simultaneously,
 * some of the streams might fail to open.
 *
 * o <rdar://problem/9856751> -- If you create streams using
 * -[NSNetService getInputStream:outputStream:], start to open them, and
 * then release the last reference to the original NSNetService, the
 * streams never finish opening.  This problem is exacerbated under ARC
 * because ARC is better about keeping things out of the autorelease pool.
*/
- (BOOL)bonjour_getInputStream:(out NSInputStream **)inputStreamPtr outputStream:(out NSOutputStream **)outputStreamPtr
{
	
	BOOL                result;
	CFReadStreamRef     readStream;
	CFWriteStreamRef    writeStream;
	
	result = NO;
	
	readStream = NULL;
	writeStream = NULL;
	
	if ( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) ) {
		CFNetServiceRef     netService;
		
		netService = CFNetServiceCreate(
										NULL,
										(__bridge CFStringRef) [self domain],
										(__bridge CFStringRef) [self type],
										(__bridge CFStringRef) [self name],
										0
										);
		if (netService != NULL) {
			CFStreamCreatePairWithSocketToNetService(
													 NULL,
													 netService,
													 ((inputStreamPtr  != nil) ? &readStream  : NULL),
													 ((outputStreamPtr != nil) ? &writeStream : NULL)
													 );
			CFRelease(netService);
		}
		
		// We have failed if the client requested an input stream and didn't
		// get one, or requested an output stream and didn't get one.  We also
		// fail if the client requested neither the input nor the output
		// stream, but we don't get here in that case.
		
		result = ! ((( inputStreamPtr != NULL) && ( readStream == NULL)) ||
					((outputStreamPtr != NULL) && (writeStream == NULL)));
	}
	if (inputStreamPtr != NULL) {
		*inputStreamPtr  = CFBridgingRelease(readStream);
	}
	if (outputStreamPtr != NULL) {
		*outputStreamPtr = CFBridgingRelease(writeStream);
	}
	
	return result;
}

@end
