//
//  BFDataWrapper.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-02.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFDataWrapper : NSObject


+ (BFDataWrapper * _Nonnull)sharedWrapper;


+ (void)processEvents:(nullable NSArray *)events completion:(nullable void (^)(void))completionBlock;
+ (void)processPhotos:(nullable NSArray *)photos completion:(nullable void (^)(void))completionBlock;
+ (void)processAttendance:(nullable NSArray *)attendance completion:(nullable void (^)(void))completionBlock;
+ (void)processEventFeatures:(nullable NSArray *)features completion:(nullable void (^)(void))completionBlock;

@end
