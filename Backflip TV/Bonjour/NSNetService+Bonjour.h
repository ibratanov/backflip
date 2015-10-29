//
//  NSNetService+Bonjour.h
//  Backflip for iOS
//
//  Created by Jack Perry on 2015-10-29.
//  Copyright © 2015 Backflip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNetService (Bonjour)

- (BOOL)bonjour_getInputStream:(out NSInputStream **)inputStreamPtr outputStream:(out NSOutputStream **)outputStreamPtr;

@end
