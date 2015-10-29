//
//  BFBonjourConnection.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFBonjourConnection : NSObject

// This notification is posted when the connection closes, either because you called
// -close or because of on-the-wire events (the client closing the connection, a network
// error, and so on).
extern NSString *BFBonjourConnectionDidCloseNotification;


- (instancetype)initWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream;


@property (strong, nonatomic, readonly) NSInputStream *inputStream;
@property (strong, nonatomic, readonly) NSOutputStream *outputStream;


- (BOOL)openConnection;
- (void)closeConnection;

@end
