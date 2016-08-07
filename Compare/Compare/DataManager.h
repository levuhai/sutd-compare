//
//  DataManager.h
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property (nonatomic, strong) NSMutableArray* files;

// Singleton methods
+ (id) shared;

@end
