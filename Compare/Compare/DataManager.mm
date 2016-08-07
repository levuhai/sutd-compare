//
//  DataManager.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "DataManager.h"
#import "NSFileManager+SUTD.h"

#define DITHER_16_MAX_ERROR 3.0/323768.0f
#define DELTA 4*DITHER_16_MAX_ERROR

@implementation DataManager {
    NSString* _soundsDBPath;
    NSString* _soundFolder;
}

static DataManager *sharedInstance = nil;

#pragma mark - Singleton
+ (id)shared {
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            sharedInstance = [[DataManager alloc] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance; // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        // Init files array
        self.files = [NSMutableArray new];
        
        // Document folder
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString *doc = [fm documentFolder];
        
        // Sounds folder
        _soundFolder = [doc stringByAppendingPathComponent:@"sounds"];
        
        // Copy sounds folder to document
        NSString* soundFolderBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"sounds"];
        [fm copyItemAtPath:soundFolderBundlePath
                    toPath:_soundFolder error:nil];
        
        // Generate database
        [self _generateDB];
    }
    return self;
}

- (void)_generateDB {
    NSFileManager* fm = [NSFileManager defaultManager];
    
    // Read files in Sounds folder
    NSArray *ls =  [fm contentsOfDirectoryAtPath:_soundFolder error:nil];
    
    // Add file paths to array
    for (NSString *file in ls) {
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [_soundFolder stringByAppendingPathComponent:file];
            [_files addObject:filePath];
        }
    }
    
    NSLog(@"%@",_files);
}



@end
