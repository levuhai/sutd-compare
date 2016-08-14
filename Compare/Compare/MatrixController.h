//
//  MatrixController.h
//  MFCCDemo
//
//  Created by Hai Le on 11/25/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixOuput.h"

@interface MatrixController : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *lowerImageView;
@property (nonatomic, weak) IBOutlet UIImageView *upperImageView;
@property (nonatomic, weak) IBOutlet MatrixOuput *upperView;
@property (nonatomic, weak) IBOutlet MatrixOuput *lowerView;

- (void)generateImage;

@end
