//
//  FetchOrCreate.h
//  Frequencies for iOS
//
//  Created by Jack Perry on 31/07/2014.
//  Copyright (c) 2014 Yoshimi Robotics. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject(FetchOrCreate)


+ (id) firstObjectSortedBy:(NSString *)attribute ascending:(BOOL)ascending;
+ (id) fetchOrCreateWhereAttribute:(NSString *)key isValue:(id)value;
+ (id) fetchOrCreateWhereAttribute:(NSString *)key isValue:(id)value inContext:(NSManagedObjectContext *)context;
+ (id) fetchOrCreateWithAttributesAndValues:(NSDictionary *)attributeDict;
+ (id) fetchOrCreateWithAttributesAndValues:(NSDictionary *)attributeDict inContext:(NSManagedObjectContext *)context;


@end
