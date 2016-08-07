//
//  NSDictionary+ES.m
//  Bone
//
//  Created by Hai Le on 4/16/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "NSDictionary+ES.h"

@implementation NSDictionary (ES)

+ (NSDictionary *)dictionaryFromJSON:(NSString*)fileLocation {
    NSData* data = [NSData dataWithContentsOfFile:fileLocation];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:&error];
    // Be careful here. You add this as a category to NSDictionary
    // but you get an id back, which means that result
    // might be an NSArray as well!
    if (error != nil) return nil;
    return result;
}

- (NSString *)stringForKey:(NSString*)key {
    NSString* value = self[key];
    if ([self[key] isKindOfClass:[NSNull class]]) {
        return @"";
    }
    value = [value stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    value = [value stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value;
}

- (int)intForKey:(NSString*)key {
    if ([self[key] isKindOfClass:[NSNull class]]) {
        return 0;
    }
    return [self[key] intValue];
}

- (id)objectForCaseInsensitiveKey:(NSString *)key {
    NSArray *allKeys = [self allKeys];
    for (NSString *str in allKeys) {
        if ([key caseInsensitiveCompare:str] == NSOrderedSame) {
            return [self objectForKey:str];
        }
    }
    return nil;
}

-(NSArray *) sortedKeys {
    return [[self allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

-(NSArray *) allValuesSortedByKey {
    return [self objectsForKeys:self.sortedKeys notFoundMarker:[NSNull null]];
}

-(id) firstKey {
    return [self.sortedKeys firstObject];
}

-(id) firstValue {
    return [self valueForKey: [self firstKey]];
}

- (BOOL)existKey:(NSString *)key
{
    id obj = [self objectForKey:key];
    return obj && ![obj isEqual:[NSNull null]];
}

@end
