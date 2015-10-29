//
//  BFBonjourConnection.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import "BFBonjourConnection.h"


NSString *BFBonjourConnectionDidCloseNotification = @"BFBonjourConnectionDidCloseNotification";


@interface BFBonjourConnection () <NSStreamDelegate>
{
	NSInputStream *_inputStream;
	NSOutputStream *_outputStream;
	
	NSMutableData *_inputBuffer;
	NSMutableData *_outputBuffer;
}
@end


@implementation BFBonjourConnection


#pragma mark -
#pragma mark Initialization

- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
	self = [super init];
	if (self != nil) {
		self->_inputStream = inputStream;
		self->_outputStream = outputStream;
	}
	return self;
}


#pragma mark -
#pragma mark Opening / Closing connection

- (BOOL)openConnection
{
	[self.inputStream  setDelegate:self];
	[self.outputStream setDelegate:self];
	[self.inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.inputStream  open];
	[self.outputStream open];
	
	return YES;
}

- (void)closeConnection
{
	[self.inputStream  setDelegate:nil];
	[self.outputStream setDelegate:nil];
	[self.inputStream  close];
	[self.outputStream close];
	[self.inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] postNotificationName:BFBonjourConnectionDidCloseNotification object:self];
}



#pragma mark -
#pragma mark Stream processing

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
	assert(aStream == self.inputStream || aStream == self.outputStream);
	#pragma unused(aStream)
	
	switch(streamEvent) {
		case NSStreamEventOpenCompleted: {
			// We don't create the input and output buffers until we get the open-completed events.
			// This is important for the output buffer because -outputText: is a no-op until the
			// buffer is in place, which avoids us trying to write to a stream that's still in the
			// process of opening.
			if (aStream == self->_inputStream) {
				self->_inputBuffer = [[NSMutableData alloc] init];
			} else {
				self->_outputBuffer = [[NSMutableData alloc] init];
			}
		} break;
			
		case NSStreamEventHasSpaceAvailable: {
			if ([self->_outputBuffer length] != 0) {
				// [self startStreamOutput];
			}
		} break;

			
		case NSStreamEventHasBytesAvailable: {
			
			uint8_t buffer[2048];
			NSInteger actuallyRead = [self->_inputStream read:buffer maxLength:sizeof(buffer)];
			if (actuallyRead > 0) {
				[self->_inputBuffer appendBytes:buffer length:(NSUInteger)actuallyRead];
				// If the input buffer ends with CR LF, show it to the user.
				if ([self->_inputBuffer length] >= 2 && memcmp((const char *) [self->_inputBuffer bytes] + [self->_inputBuffer length] - 2, "\r\n", 2) == 0) {
					NSString * string = [[NSString alloc] initWithData:self->_inputBuffer encoding:NSUTF8StringEncoding];
					if (string == nil) {
						NSLog(@"response not UTF-8");
					} else {
						[self processIncomingString:string];
					}
					
					[self->_inputBuffer setLength:0];
				}
			} else {
				// A non-positive value from -read:maxLength: indicates either end of file (0) or
				// an error (-1).  In either case we just wait for the corresponding stream event
				// to come through.
			}
		} break;
			
		case NSStreamEventEndEncountered:
		case NSStreamEventErrorOccurred: {
			[self closeConnection];
		} break;

			
		default: {
			// do nothing
		} break;
	}
}


#pragma mark -
#pragma mark Response handling

- (void)processIncomingString:(NSString *)string
{
	string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	NSLog(@"We have a string of '%@'", string);
	if (string.length > 8 && [[string substringToIndex:7] isEqualToString:@"base64:"]) {
		
		NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:[string substringFromIndex:7] options:0];

		NSError *jsonError;
		NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:base64Data options:0 error:&jsonError];
		if (payload != nil && payload[@"account"] != nil) {
			NSDictionary *account = payload[@"account"];
			
			[[NSUserDefaults standardUserDefaults] setValue:account[@"objectId"] forKey:@"account.objectId"];
			[[NSUserDefaults standardUserDefaults] setValue:account[@"full_name"] forKey:@"account.fullName"];
			[[NSUserDefaults standardUserDefaults] setValue:account[@"phone_number"] forKey:@"account.phoneNumber"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"BFBonjourServerAccountDidLogin" object:NULL];
		}
	}
	
}


@end
