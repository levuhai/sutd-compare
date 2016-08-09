//
//  NSFileManager+SUTD.m
//  Compare
//
//  Created by Hai Le on 8/6/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import "NSFileManager+SUTD.h"

@implementation NSFileManager (SUTD)

+ (NSString *)documentFolder {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return doc;
}

- (NSString *)documentFolder {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return doc;
}

+ (BOOL)createFolderIn:(NSSearchPathDirectory)directory folder:(NSString *)folder {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *creatingFolder = [doc stringByAppendingPathComponent:folder];
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:creatingFolder
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
}

- (BOOL)createFolderIn:(NSSearchPathDirectory)directory folder:(NSString *)folder {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *creatingFolder = [doc stringByAppendingPathComponent:folder];
    
    return [[NSFileManager defaultManager] createDirectoryAtPath:creatingFolder
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
}

@end
