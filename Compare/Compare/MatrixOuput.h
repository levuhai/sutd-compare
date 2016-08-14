//
//  MatrixOuput.h
//  MFCCDemo
//
//  Created by Hai Le on 10/6/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#include <vector>
#include <math.h>

@interface MatrixOuput : UIView

@property (nonatomic, strong) UIColor* graphColor;
@property (nonatomic, assign) CGRect legend;

- (void)inputNormalizedDataW:(int)w matrixH:(int)h data:(std::vector< std::vector<float> >)data rect:(CGRect)rect maxVal:(float)maxVal;
- (void)inputFitQualityW:(int)w data:(std::vector<float>)data
                    rect:(CGRect)rect
                  maxVal:(float)maxVal
                   start:(int)start
                     end:(int)end;
- (UIImage*)drawImage;

@end
