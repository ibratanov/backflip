//
//  BFBonjourClient.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import "BFBonjourClient.h"
#import "NSNetService+Bonjour.h"


@interface BFBonjourClient () <NSNetServiceBrowserDelegate, NSStreamDelegate>
{
	NSNetServiceBrowser *_serviceBrowser;
	
	NSInputStream *_inputStream;
	NSOutputStream *_outputStream;
	
	NSMutableData *_inputBuffer;
	NSMutableData *_outputBuffer;
}

@property (strong, nonatomic, readwrite) NSMutableArray *services; // (array) of `NSNetService`

@property (strong, nonatomic, readwrite) ServiceDiscoveredBlock discoveryBlock;

@end



@implementation BFBonjourClient


- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		self->_serviceBrowser = [[NSNetServiceBrowser alloc] init];
		self.services = [[NSMutableArray alloc] init];
		[self->_serviceBrowser setDelegate:self];
	}
	return self;
}


#pragma mark -
#pragma mark Public methods

- (void)startServiceBrowserWithDiscovery:(ServiceDiscoveredBlock)discoveryBlock
{
	if (discoveryBlock != NULL) {
		self.discoveryBlock = discoveryBlock;
	}
	
	[_serviceBrowser searchForServicesOfType:@"_backflip-tv._tcp." inDomain:@"local"];
}



#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

// We broadcast the willChangeValueForKey: and didChangeValueForKey: for the NSTableView binding to work.

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	#pragma unused(aNetServiceBrowser)
	#pragma unused(moreComing)
	if (![self.services containsObject:aNetService]) {
		
		if (self.discoveryBlock != NULL) {
			self.discoveryBlock(aNetService);
		}
		
		[self willChangeValueForKey:@"services"];
		[self.services addObject:aNetService];
		[self didChangeValueForKey:@"services"];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	#pragma unused(aNetServiceBrowser)
	#pragma unused(moreComing)
	if ([self.services containsObject:aNetService]) {
		[self willChangeValueForKey:@"services"];
		[self.services removeObject:aNetService];
		[self didChangeValueForKey:@"services"];
	}
}


#pragma mark -
#pragma mark Stream opening / closing

- (void)openStreamsForService:(NSNetService *)netService
{
	NSInputStream *istream;
	NSOutputStream *ostream;
	
	[self closeStreams];
	
	if ([netService bonjour_getInputStream:&istream outputStream:&ostream]) {
		self->_inputStream = istream;
		self->_outputStream = ostream;
		[self->_inputStream  setDelegate:self];
		[self->_outputStream setDelegate:self];
		[self->_inputStream  scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[self->_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[self->_inputStream  open];
		[self->_outputStream open];
	}
}

- (void)closeStreams
{
	[self->_inputStream  setDelegate:nil];
	[self->_outputStream setDelegate:nil];
	[self->_inputStream  close];
	[self->_outputStream close];
	[self->_inputStream  removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self->_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	self->_inputStream  = nil;
	self->_outputStream = nil;
	self->_inputBuffer  = nil;
	self->_outputBuffer = nil;
}



#pragma mark -
#pragma mark Stream comunication

- (void)streamText:(NSString *)string
{
	NSData *streamData = [[string stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
	if (self->_outputBuffer != nil) {
		BOOL streamEmpty = ([self->_outputBuffer length] == 0);
		[self->_outputBuffer appendData:streamData];
		if (streamEmpty) {
			[self startStreamOutput];
		}
	}
}

- (void)startStreamOutput
{
	assert([self->_outputBuffer length] != 0);
	
	NSInteger actuallyWritten = [self->_outputStream write:[self->_outputBuffer bytes] maxLength:[self->_outputBuffer length]];
	if (actuallyWritten > 0) {
		[self->_outputBuffer replaceBytesInRange:NSMakeRange(0, (NSUInteger) actuallyWritten) withBytes:NULL length:0];
		// If we didn't write all the bytes we'll continue writing them in response to the next
		// has-space-available event.
	} else {
		// A non-positive result from -write:maxLength: indicates a failure of some form; in this
		// simple app we respond by simply closing down our connection.
		[self closeStreams];
	}
}



#pragma mark -
#pragma mark Stream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent
{
	assert(aStream == self->_inputStream || aStream == self->_outputStream);
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
				[self startStreamOutput];
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
						// [self.responseField setStringValue:@"response not UTF-8"];
					} else {
						if (self.incomingBlock != NULL) {
							self.incomingBlock(string);
						}
						NSLog(@"Stream response '%@'", string);
						// [self.responseField setStringValue:string];
					}
					[self->_inputBuffer setLength:0];
				}
			} else {
				// A non-positive value from -read:maxLength: indicates either end of file (0) or
				// an error (-1).  In either case we just wait for the corresponding stream event
				// to come through.
			}
		} break;
			
		case NSStreamEventErrorOccurred:
		case NSStreamEventEndEncountered: {
			[self closeStreams];
		} break;
			
		default:
			break;
	}
}




@end
