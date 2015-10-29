//
//  BFBonjourClient.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFBonjourClient : NSObject


typedef void (^ServiceDiscoveredBlock)(NSNetService *netService);
typedef void (^ServiceIncomingBlock)(NSString *incomingString);


@property (strong, nonatomic, readwrite) ServiceIncomingBlock incomingBlock;


- (void)startServiceBrowserWithDiscovery:(ServiceDiscoveredBlock)discoveryBlock;

- (void)openStreamsForService:(NSNetService *)netService;

- (void)streamText:(NSString *)string;

- (void)closeStreams;

@end
