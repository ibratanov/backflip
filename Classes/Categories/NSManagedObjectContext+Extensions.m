//
//  NSManagedObjectContext+Extensions.m
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-25.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import "NSManagedObjectContext+Extensions.h"

@implementation NSManagedObjectContext(Extensions)



- (void)saveWithOptions:(NSInteger)options completion:(void(^)(BOOL contextDidSave, NSError *error))completion
{
	return [self MR_saveWithOptions:MRSaveParentContexts completion:completion];
}

- (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion
{
//	if (self.dataQueue == nil) {
//		self.dataQueue = dispatch_queue_create("com.backflip.dataQueue", DISPATCH_QUEUE_SERIAL);
//		 dispatch_set_target_queue(self.dataQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
//	}
	
	[self setUndoManager:nil];
	
	//dispatch_async(self.dataQueue, ^{
		
		[self performBlock:^{
			if (block)
				block(self);
			
			[self MR_saveWithOptions:MRSaveSynchronouslyExceptRootContext completion:completion];
		}];
		
	//});
}

@end
