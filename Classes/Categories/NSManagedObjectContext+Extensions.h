//
//  NSManagedObjectContext+Extensions.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-08-25.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

@interface NSManagedObjectContext(Extensions)


- (void)saveWithOptions:(NSInteger)options completion:(void(^)(BOOL contextDidSave, NSError *error))completion;
- (void)saveWithBlock:(void(^)(NSManagedObjectContext *localContext))block completion:(MRSaveCompletionHandler)completion;


@end
