//
//  MatrixController.m
//  MFCCDemo
//
//  Created by Hai Le on 11/25/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "MatrixController.h"


@interface MatrixController ()

@end

@implementation MatrixController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateImage {
    self.upperImageView.image = [self.upperView drawImage];
    self.lowerImageView.image = [self.lowerView drawImage];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
