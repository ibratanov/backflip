//
//  FetchOrCreate.m
//  Frequencies for iOS
//
//  Created by Jack Perry on 31/07/2014.
//  Copyright (c) 2014 Yoshimi Robotics. All rights reserved.
//

#import "NSManagedObject+FetchOrCreate.h"
#import <MagicalRecord/MagicalRecord.h>

@implementation NSManagedObject(FetchOrCreate)

+ (id) fetchOrCreateWhereAttribute:(NSString *)key isValue:(id)value {
    NSManagedObjectContext *context =[NSManagedObjectContext MR_defaultContext];
    [context setUndoManager:nil];
    return [self fetchOrCreateWhereAttribute:key isValue:value inContext:context];
}

+ (id) fetchOrCreateWhereAttribute:(NSString *)key isValue:(id)value inContext:(NSManagedObjectContext *)context {
    [context setUndoManager:nil];
    id instanceVar = [self MR_findFirstByAttribute:key withValue:value inContext:context];

    if (!instanceVar) {
        instanceVar = [self MR_createEntityInContext:context];
        [instanceVar setValue:value forKey:key];
    }

    return instanceVar;
}

+ (id) fetchOrCreateWithAttributesAndValues:(NSDictionary *)attributeDict {
    return [self fetchOrCreateWithAttributesAndValues:attributeDict inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (id) fetchOrCreateWithAttributesAndValues:(NSDictionary *)attributeDict inContext:(NSManagedObjectContext *)context {
    [context setUndoManager:nil];
    NSArray *allKeys = [attributeDict allKeys];
    NSMutableString *formatString = [NSMutableString new];
    for (NSString *key in allKeys) {
        BOOL isFirst = formatString.length == 0;
        [formatString appendFormat:@"%@(%@ == %@)", (isFirst ? @"" : @" AND "), key, attributeDict[key]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString];

    id instanceVar = [self MR_findFirstWithPredicate:predicate inContext:context];
    if (!instanceVar) {
        instanceVar = [self MR_createEntityInContext:context];
        for (NSString *key in allKeys) {
			[instanceVar setValue:attributeDict[key] forKey:key];
        }
    }

    return instanceVar;
}

+ (id)firstObjectSortedBy:(NSString *)attribute ascending:(BOOL)ascending
{
	return [self MR_findFirstOrderedByAttribute:attribute ascending:ascending];
}

@end
