//
//  NSFileManager+SUTD.h
//  Compare
//
//  Created by Hai Le on 8/6/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (SUTD)

+ (NSString*)documentFolder;
- (NSString*)documentFolder;
+ (BOOL)createFolderIn:(NSSearchPathDirectory)directory folder:(NSString*)folder;
- (BOOL)createFolderIn:(NSSearchPathDirectory)directory folder:(NSString*)folder;

@end
