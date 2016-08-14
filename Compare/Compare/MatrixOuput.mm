//
//  MatrixOuput.m
//  MFCCDemo
//
//  Created by Hai Le on 10/6/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "MatrixOuput.h"


@implementation MatrixOuput {
    int _w;
    int _h;
    std::vector< std::vector<float> > _dataV;
    std::vector<float> _fitDataV;
    float _paddingLeft;
    CGRect _frameRect;
    int _size;
    float _maxVal;
    BOOL _drawFit;
    int _start, _end;
}

- (void)awakeFromNib {
    _graphColor = [UIColor redColor];
}

- (void)inputNormalizedDataW:(int)w
                     matrixH:(int)h
                        data:(std::vector< std::vector<float> >)data
                        rect:(CGRect)rect
                      maxVal:(float)maxVal {
    _w = w;
    _h = h;
    _dataV = data;
    _frameRect = rect;
    _size = 1;
    _maxVal = maxVal;
    _drawFit = NO;
    _maxVal = 0.0;
    for (int i = 0; i <_h; i++) {
        for (int j = 0; j<_w; j++) {
            _maxVal = fmax(_dataV[i][j],_maxVal);
        }
    }
    
    //[self setNeedsDisplay];
}

- (void)inputFitQualityW:(int)w data:(std::vector<float>)data
                    rect:(CGRect)rect
                  maxVal:(float)maxVal
                   start:(int)start
                     end:(int)end {
    _w = w;
    _fitDataV = data;
    _size = w==0?1:MAX((int)rect.size.width / w, 1);
    _maxVal = maxVal;
    _drawFit = YES;
    _start = start;
    _end = end;
    _maxVal = 0.0;
    for (int i = 0; i <_h; i++) {
        for (int j = 0; j<_w; j++) {
            _maxVal = fmax(_dataV[i][j],_maxVal);
        }
    }
   
    //[self setNeedsDisplay];
}


- (UIImage*)drawImage {
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_w, _h), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    if (!_drawFit) {
        _maxVal = 1;
        _size = 1;//MAX(self.bounds.size.width/_w, 1);
        // Drawing code
        for (int i = 0; i <_h; i++) {
            for (int j = 0; j<_w; j++) {
                float temp = _dataV[i][j]/_maxVal;
                CGRect rectangle = CGRectMake(j*_size, i*_size , _size, _size);
                
                CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
                [_graphColor getRed:&red green:&green blue:&blue alpha:&alpha];
                if (temp == 999) {
                    CGContextSetRGBFillColor(context, 0, 1, 1, 0.0);
                } else
                    CGContextSetRGBFillColor(context, red, green, blue, 0.01 + temp);   //this is the transparent color
                CGContextFillRect(context, rectangle);
                
            }
        }
        // Draw legend
        CGContextSetRGBFillColor(context, 1, 1, 0, 0.1);
        CGRect similarityLegend = CGRectMake(_legend.origin.x*_size, 0, (_legend.origin.y-_legend.origin.x)*_size,_h*_size);
        CGContextFillRect(context, similarityLegend);
        
        CGContextSetRGBFillColor(context, 0, 1, 1, 0.1);
        CGRect fitqualityLegend = CGRectMake(0, _legend.size.width*_size, _w*_size,(_legend.size.height-_legend.size.width)*_size);
        CGContextFillRect(context, fitqualityLegend);
        
        
    } else {
        float maxH = self.bounds.size.height - 20;
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:CGPointMake(0.0, maxH)];
        for (int i = 0; i<_w; i++) {
            [aPath addLineToPoint:CGPointMake(i*_size, maxH-(_fitDataV[i]/_maxVal*maxH)+10)];
        }
        [aPath moveToPoint:CGPointMake((_w-1)*_size, maxH-(_fitDataV[(_w-1)]/_maxVal*maxH)+10)];
        [aPath closePath];
        [_graphColor setStroke];
        [aPath stroke];
        
        
        // Draw Start line
        UIBezierPath *sPath = [UIBezierPath bezierPath];
        [sPath moveToPoint:CGPointMake(_start*_size, maxH)];
        [sPath addLineToPoint:CGPointMake(_start*_size, 0.0)];
        [sPath moveToPoint:CGPointMake(_start*_size, 0.0)];
        [sPath closePath];
        [[UIColor greenColor] setStroke];
        [sPath stroke];
        
        // Draw End line
        UIBezierPath *ePath = [UIBezierPath bezierPath];
        [ePath moveToPoint:CGPointMake(_end*_size, maxH)];
        [ePath addLineToPoint:CGPointMake(_end*_size, 0.0)];
        [ePath moveToPoint:CGPointMake(_end*_size, 0.0)];
        [ePath closePath];
        [[UIColor greenColor] setStroke];
        [ePath stroke];
    }
    
    CGContextRestoreGState(context);
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!_drawFit) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        _maxVal = 1;
        _size = 1;//MAX(self.bounds.size.width/_w, 1);
        // Drawing code
        for (int i = 0; i <_h; i++) {
            for (int j = 0; j<_w; j++) {
                float temp = _dataV[i][j]/_maxVal;
                CGRect rectangle = CGRectMake(j*_size, i*_size , _size, _size);
                
                CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
                [_graphColor getRed:&red green:&green blue:&blue alpha:&alpha];
                if (temp == 999) {
                    CGContextSetRGBFillColor(context, 0, 1, 1, 0.0);
                } else
                    CGContextSetRGBFillColor(context, red, green, blue, 0.01 + temp);   //this is the transparent color
                CGContextFillRect(context, rectangle);
                
            }
        }
        // Draw legend
        CGContextSetRGBFillColor(context, 1, 1, 0, 0.1);
        CGRect similarityLegend = CGRectMake(_legend.origin.x*_size, 0, (_legend.origin.y-_legend.origin.x)*_size,_h*_size);
        CGContextFillRect(context, similarityLegend);
        
        CGContextSetRGBFillColor(context, 0, 1, 1, 0.1);
        CGRect fitqualityLegend = CGRectMake(0, _legend.size.width*_size, _w*_size,(_legend.size.height-_legend.size.width)*_size);
        CGContextFillRect(context, fitqualityLegend);
        

    } else {
        float maxH = self.bounds.size.height - 20;
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:CGPointMake(0.0, maxH)];
        for (int i = 0; i<_w; i++) {
            [aPath addLineToPoint:CGPointMake(i*_size, maxH-(_fitDataV[i]/_maxVal*maxH)+10)];
        }
        [aPath moveToPoint:CGPointMake((_w-1)*_size, maxH-(_fitDataV[(_w-1)]/_maxVal*maxH)+10)];
        [aPath closePath];
        [_graphColor setStroke];
        [aPath stroke];
        
        
        // Draw Start line
        UIBezierPath *sPath = [UIBezierPath bezierPath];
        [sPath moveToPoint:CGPointMake(_start*_size, maxH)];
        [sPath addLineToPoint:CGPointMake(_start*_size, 0.0)];
        [sPath moveToPoint:CGPointMake(_start*_size, 0.0)];
        [sPath closePath];
        [[UIColor greenColor] setStroke];
        [sPath stroke];
        
        // Draw End line
        UIBezierPath *ePath = [UIBezierPath bezierPath];
        [ePath moveToPoint:CGPointMake(_end*_size, maxH)];
        [ePath addLineToPoint:CGPointMake(_end*_size, 0.0)];
        [ePath moveToPoint:CGPointMake(_end*_size, 0.0)];
        [ePath closePath];
        [[UIColor greenColor] setStroke];
        [ePath stroke];
    }
}


@end
