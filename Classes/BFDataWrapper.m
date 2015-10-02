//
//  BFDataWrapper.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-02.
//  Copyright © 2015 Backflip. All rights reserved.
//

@import Parse;
@import CoreData;
@import MagicalRecord;

#if DEBUG
	#import "Frontflip-Swift.h"
#else
	#import "Backflip-Swift.h"
#endif


#import "BFDataWrapper.h"
#import "NSManagedObject+FetchOrCreate.h"


@interface BFDataWrapper ()
{
	dispatch_queue_t _dataQueue;
	NSManagedObjectContext *_dataContext;
}

@end


@implementation BFDataWrapper


#pragma mark -
#pragma mark Singleton

+ (BFDataWrapper *)sharedWrapper
{
	static BFDataWrapper *singleton;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [BFDataWrapper new];
	});
	
	return singleton;
}


- (instancetype)init
{
	self = [super init];
	if (self) {
		
		// Anything that interacts with core data should be a serial queue.
		_dataQueue = dispatch_queue_create("com.getbackflip.dataQueue", DISPATCH_QUEUE_SERIAL);
		dispatch_set_target_queue(_dataQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
		
		dispatch_async(_dataQueue, ^{
			NSManagedObjectContext *mainContext  = [NSManagedObjectContext MR_defaultContext];
			_dataContext = [NSManagedObjectContext MR_contextWithParent:mainContext];
			[_dataContext setUndoManager:nil];
		});
		
		[self setup];
		
	}
	return self;
}

+ (void) setup
{
	[[BFDataWrapper sharedWrapper] setup];
}

- (void)setup
{
	NSManagedObjectContext *mainContext  = [NSManagedObjectContext MR_defaultContext];
	[mainContext setUndoManager:nil];
	
	_dataContext = [NSManagedObjectContext MR_contextWithParent:mainContext];
	[_dataContext setUndoManager:nil];
}



#pragma mark -
#pragma mark Coredata

- (BOOL)isValidValue:(id)value
{
	if (value == nil)
		return NO;
	
	if ([value isKindOfClass:[NSNull class]])
		return NO;
	
	return YES;
}


- (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion
{
	dispatch_async(_dataQueue, ^{
		[_dataContext performBlock:^{
			if (block)
				block(_dataContext);
			
			NSLog(@"CD SAVED");
			[_dataContext MR_saveWithOptions:MRSaveParentContexts completion:completion];
		}];
	});
}



#pragma mark -
#pragma mark (PUBLIC) Object saving

+ (void)processEvents:(NSArray *)events completion:(void (^)(void))completionBlock
{
	return [[BFDataWrapper sharedWrapper] processEvents:events completion:completionBlock];
}

+ (void)processPhotos:(NSArray *)photos completion:(void (^)(void))completionBlock
{
	return [[BFDataWrapper sharedWrapper] processPhotos:photos completion:completionBlock];
}


+ (void)processAttendance:(NSArray *)attendance completion:(void (^)(void))completionBlock
{
	return [[BFDataWrapper sharedWrapper] processAttendance:attendance completion:completionBlock];
}


#pragma mark -
#pragma mark (PRIVATE) Object saving


- (void)processEvents:(nullable NSArray *)events completion:(nullable void (^)(void))completionBlock
{
	if (events == NULL || events.count < 1) {
		if (completionBlock)
			return completionBlock();
		else
			return ;
	}
	NSLog(@"📝 Processing %li events..", events.count);
	

	[self saveWithBlock:^(NSManagedObjectContext *localContext) {
		
		for (PFObject *event in events) {
			
			Event *object = [Event fetchOrCreateWhereAttribute:@"objectId" isValue:event.objectId inContext:localContext];
			
			if (event.createdAt)
				[object setCreatedAt:event.createdAt];
			
			if (event.updatedAt)
				[object setUpdatedAt:event.updatedAt];
			
			if ([self isValidValue:event[@"enabled"]])
				[object setEnabled:@([event[@"enabled"] boolValue])];
			
			if ([self isValidValue:event[@"eventName"]])
				[object setName:event[@"eventName"]];
			
			if ([self isValidValue:event[@"isLive"]])
				[object setLive:@([event[@"isLive"] boolValue])];
			
			if ([self isValidValue:event[@"venue"]])
				[object setVenue:event[@"venue"]];
		
			if ([self isValidValue:event[@"startTime"]])
				[object setStartTime:(NSDate *)event[@"startTime"]];
			
			if ([self isValidValue:event[@"endTime"]])
				[object setStartTime:(NSDate *)event[@"endTime"]];
			
			if ([self isValidValue:event[@"owner"]]) {
				PFObject *owner = (PFObject *)event[@"owner"];
				[object setOwner:owner.objectId];
			}
			
			if ([self isValidValue:event[@"geoLocation"]]) {
				PFGeoPoint *geoObject = (PFGeoPoint *)event[@"geoLocation"];
				if (geoObject) {
					NSDictionary *attributes = @{@"latitude":@(geoObject.latitude), @"longitude": @(geoObject.longitude)};
					GeoPoint *geoPoint = [GeoPoint fetchOrCreateWithAttributesAndValues:attributes inContext:localContext];
					[object setGeoLocation:geoPoint];
				}
			}
		}
		
	} completion:^(BOOL contextDidSave, NSError *error) {
		
		if (error)
			NSLog(@"📛 Coredata error %@", error);
			
		if (completionBlock)
			return completionBlock();
		else
			return ;
		
	}];
}


- (void)processPhotos:(nullable NSArray *)photos completion:(nullable void (^)(void))completionBlock
{
	if (photos == NULL || photos.count < 1) {
		if (completionBlock)
			return completionBlock();
		else
			return ;
	}
	NSLog(@"📝 Processing %li photos..", photos.count);
	
	[self saveWithBlock:^(NSManagedObjectContext *localContext) {
		
		for (PFObject *photo in photos) {
			
			Photo *object = [Photo fetchOrCreateWhereAttribute:@"objectId" isValue:photo.objectId inContext:localContext];
			
			if (photo.createdAt)
				[object setCreatedAt:photo.createdAt];
			
			if (photo.updatedAt)
				[object setUpdatedAt:photo.updatedAt];
			
			if ([self isValidValue:photo[@"enabled"]])
				[object setEnabled:@([photo[@"enabled"] boolValue])];
			
			if ([self isValidValue:photo[@"flagged"]])
				[object setFlagged:@([photo[@"flagged"] boolValue])];
			
			if ([self isValidValue:photo[@"caption"]])
				[object setCaption:photo[@"caption"]];
				
			if ([self isValidValue:photo[@"reporter"]])
				[object setReporter:photo[@"reporter"]];
			
			if ([self isValidValue:photo[@"uploader"]])
				[object setUploader:((PFUser *)photo[@"uploader"]).objectId];
			
			if ([self isValidValue:photo[@"upvoteCount"]])
				[object setUpvoteCount:@([photo[@"upvoteCount"] integerValue])];
			
			if ([self isValidValue:photo[@"usersLiked"]])
				[object setUsersLiked:[((NSArray *)photo[@"usersLiked"]) componentsJoinedByString:@","]];
			
			
			if ([self isValidValue:photo[@"event"]]) {
				Event *event = [Event fetchOrCreateWhereAttribute:@"objectId" isValue:((PFObject *)photo[@"event"]).objectId inContext:localContext];
				[object setEvent:event];
			}
			
			if ([self isValidValue:photo[@"image"]]) {
				File *file = [File fetchOrCreateWhereAttribute:@"url" isValue:((PFFile *)photo[@"image"]).url inContext:localContext];
				[object setImage:file];
			}
			
			if ([self isValidValue:photo[@"thumbnail"]]) {
				File *file = [File fetchOrCreateWhereAttribute:@"url" isValue:((PFFile *)photo[@"thumbnail"]).url inContext:localContext];
				[object setThumbnail:file];
			}
		}
		
	} completion:^(BOOL contextDidSave, NSError *error) {
		
		if (error)
			NSLog(@"📛 Coredata error %@", error);
		
		if (completionBlock)
			return completionBlock();
		else
			return ;
		
	}];
	
}


- (void)processAttendance:(NSArray *)attendance completion:(void (^)(void))completionBlock
{
	if (attendance == NULL ||attendance.count < 1) {
		if (completionBlock)
			return completionBlock();
		else
			return ;
	}
	NSLog(@"📝 Processing %li attendees..", attendance.count);
	
	[self saveWithBlock:^(NSManagedObjectContext *localContext) {
		
		for (PFObject *attendee in attendance) {
			
			Attendance *object = [Attendance fetchOrCreateWhereAttribute:@"objectId" isValue:attendee.objectId inContext:localContext];
			
			if (attendee.createdAt)
				[object setCreatedAt:attendee.createdAt];
			
			if (attendee.updatedAt)
				[object setUpdatedAt:attendee.updatedAt];
			
			if ([self isValidValue:attendee[@"enabled"]])
				[object setEnabled:@([attendee[@"enabled"] boolValue])];
			
			if ([self isValidValue:attendee[@"attendeeID"]])
				[object setAttendeeId:attendee[@"attendeeID"]];
			
			
			if ([self isValidValue:attendee[@"event"]]) {
				Event *event = [Event fetchOrCreateWhereAttribute:@"objectId" isValue:((PFObject *)attendee[@"event"]).objectId inContext:localContext];
				[object setEvent:event];
			}
		}
		
	} completion:^(BOOL contextDidSave, NSError *error) {
		
		if (error)
			NSLog(@"📛 Coredata error %@", error);
		
		if (completionBlock)
			return completionBlock();
		else
			return ;
		
	}];

}


@end
