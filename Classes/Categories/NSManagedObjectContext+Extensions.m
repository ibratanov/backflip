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
	[self performBlock:^{
		if (block)
			block(self);
		
		[self MR_saveWithOptions:MRSaveParentContexts completion:completion];
	}];
}

@end
