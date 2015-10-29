//
//  BFBonjourServer.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#include <unistd.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "NSNetService+Bonjour.h"
#import "BFBonjourServer.h"
#import "BFBonjourConnection.h"


@interface BFBonjourServer () <NSStreamDelegate>
{
	CFSocketRef             _ipv4socket;
	CFSocketRef             _ipv6socket;
}

@property (strong, nonatomic, readwrite) NSNetService *netService;

@property (strong, nonatomic, readonly) NSMutableSet *connections; // (set) of `BFBonjourConnection`s

@end



@implementation BFBonjourServer


#pragma mark -
#pragma mark Initialization

- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		_connections = [[NSMutableSet alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[self stopServer];
}


#pragma mark -
#pragma mark Start / Stop server


- (BOOL)startServer
{
	assert(_ipv4socket == NULL && _ipv6socket == NULL);       // don't call -start twice!
	
	CFSocketContext socketCtxt = {0, (__bridge void *) self, NULL, NULL, NULL};
	_ipv4socket = CFSocketCreate(kCFAllocatorDefault, AF_INET,  SOCK_STREAM, 0, kCFSocketAcceptCallBack, &BFBonjourServerAcceptCallBack, &socketCtxt);
	_ipv6socket = CFSocketCreate(kCFAllocatorDefault, AF_INET6, SOCK_STREAM, 0, kCFSocketAcceptCallBack, &BFBonjourServerAcceptCallBack, &socketCtxt);
	
	if (NULL == _ipv4socket || NULL == _ipv6socket) {
		[self stopServer];
		return NO;
	}
	
	static const int yes = 1;
	(void) setsockopt(CFSocketGetNative(_ipv4socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
	(void) setsockopt(CFSocketGetNative(_ipv6socket), SOL_SOCKET, SO_REUSEADDR, (const void *) &yes, sizeof(yes));
	
	// Set up the IPv4 listening socket; port is 0, which will cause the kernel to choose a port for us.
	struct sockaddr_in addr4;
	memset(&addr4, 0, sizeof(addr4));
	addr4.sin_len = sizeof(addr4);
	addr4.sin_family = AF_INET;
	addr4.sin_port = htons(0);
	addr4.sin_addr.s_addr = htonl(INADDR_ANY);
	if (kCFSocketSuccess != CFSocketSetAddress(_ipv4socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr4 length:sizeof(addr4)])) {
		[self stopServer];
		return NO;
	}
	
	// Now that the IPv4 binding was successful, we get the port number
	// -- we will need it for the IPv6 listening socket and for the NSNetService.
	NSData *addr = (__bridge_transfer NSData *)CFSocketCopyAddress(_ipv4socket);
	assert([addr length] == sizeof(struct sockaddr_in));
	_portNumber = ntohs(((const struct sockaddr_in *)[addr bytes])->sin_port);
	
	// Set up the IPv6 listening socket.
	struct sockaddr_in6 addr6;
	memset(&addr6, 0, sizeof(addr6));
	addr6.sin6_len = sizeof(addr6);
	addr6.sin6_family = AF_INET6;
	addr6.sin6_port = htons(_portNumber);
	memcpy(&(addr6.sin6_addr), &in6addr_any, sizeof(addr6.sin6_addr));
	if (kCFSocketSuccess != CFSocketSetAddress(_ipv6socket, (__bridge CFDataRef) [NSData dataWithBytes:&addr6 length:sizeof(addr6)])) {
		[self stopServer];
		return NO;
	}
	
	// Set up the run loop sources for the sockets.
	CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4socket, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source4, kCFRunLoopCommonModes);
	CFRelease(source4);
	
	CFRunLoopSourceRef source6 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv6socket, 0);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source6, kCFRunLoopCommonModes);
	CFRelease(source6);
	
	assert(_portNumber > 0 && _portNumber < 65536);
	self.netService = [[NSNetService alloc] initWithDomain:@"local" type:@"_backflip-tv._tcp." name:[[UIDevice currentDevice] name] port:(int)_portNumber];
	[self.netService publishWithOptions:0];
	
	NSLog(@"Server started on `local` domain with type `_backflip-tv._tcp.`, name `%@`, port number `%li`", [[UIDevice currentDevice] name], _portNumber);
	
	return YES;
}


- (void)stopServer
{
	[self.netService stop];
	self.netService = nil;
	
	// Closes all the open connections.  The EchoConnectionDidCloseNotification notification will ensure
	// that the connection gets removed from the self.connections set.  To avoid mututation under iteration
	// problems, we make a copy of that set and iterate over the copy.
	for (BFBonjourConnection * connection in [self.connections copy]) {
		[connection closeConnection];
	}
	
	if (_ipv4socket != NULL) { // IPv4
		CFSocketInvalidate(_ipv4socket);
		CFRelease(_ipv4socket);
		_ipv4socket = NULL;
	}
	
	if (_ipv6socket != NULL) { // IPv6
		CFSocketInvalidate(_ipv6socket);
		CFRelease(_ipv6socket);
		_ipv6socket = NULL;
	}
}



#pragma mark -
#pragma mark Acception Callback

/**
 * This function is called by CFSocket when a new connection comes in.
 * We gather the data we need, and then convert the function call to a method
 * invocation on BFBonjourServer.
*/
static void BFBonjourServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
	assert(type == kCFSocketAcceptCallBack);
	#pragma unused(type)
	#pragma unused(address)
	
	BFBonjourServer *server = (__bridge BFBonjourServer *)info;
	assert(socket == server->_ipv4socket || socket == server->_ipv6socket);
	#pragma unused(socket)
	
	// For an accept callback, the data parameter is a pointer to a CFSocketNativeHandle.
	[server acceptConnection:*(CFSocketNativeHandle *)data];
}

- (void)acceptConnection:(CFSocketNativeHandle)nativeSocketHandle
{
	CFReadStreamRef readStream = NULL;
	CFWriteStreamRef writeStream = NULL;
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
	if (readStream && writeStream) {
		CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		
		BFBonjourConnection *connection = [[BFBonjourConnection alloc] initWithInputStream:(__bridge NSInputStream *)readStream outputStream:(__bridge NSOutputStream *)writeStream];
		[self.connections addObject:connection];
		[connection openConnection];
		
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidCloseNotification:) name:BFBonjourConnectionDidCloseNotification object:connection];
		
		NSLog(@"Added connection.");
	} else {
		// On any failure, we need to destroy the CFSocketNativeHandle
		// since we are not going to use it any more.
		(void) close(nativeSocketHandle);
	}
	
	if (readStream) CFRelease(readStream);
	if (writeStream) CFRelease(writeStream);
}


#pragma mark -
#pragma mark Notifications

- (void)connectionDidCloseNotification:(NSNotification *)note
{
	BFBonjourConnection *connection = [note object];
	assert([connection isKindOfClass:[BFBonjourConnection class]]);
	
	[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self name:BFBonjourConnectionDidCloseNotification object:connection];
	[self.connections removeObject:connection];
	
	NSLog(@"Connection closed.");
}


@end
