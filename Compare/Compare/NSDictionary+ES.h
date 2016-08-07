//
//  NSDictionary+ES.h
//  Bone
//
//  Created by Hai Le on 4/16/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ES)

+ (NSDictionary *)dictionaryFromJSON:(NSString*)fileLocation;
- (NSString *)stringForKey:(NSString*)key;
- (int)intForKey:(NSString*)key;
- (id)objectForCaseInsensitiveKey:(NSString *)key;
- (NSArray *)sortedKeys;
- (NSArray *)allValuesSortedByKey;
- (id)firstKey;
- (id)firstValue;
- (BOOL)existKey:(NSString *)key;

@end
