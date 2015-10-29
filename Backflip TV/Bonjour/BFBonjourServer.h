//
//  BFBonjourServer.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFBonjourServer : NSObject


@property (assign, nonatomic, readonly) NSUInteger portNumber; // the actual port bound to, valid after -start


- (BOOL)startServer;
- (void)stopServer;

@end
