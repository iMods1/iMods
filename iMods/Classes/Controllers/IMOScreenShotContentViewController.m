//
//  IMOScreenShotContentViewController.m
//  iMods
//
//  Created by Ryan Feng on 11/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOScreenShotContentViewController.h"

@interface IMOScreenShotContentViewController ()

@end

@implementation IMOScreenShotContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.imageURL) {
        return;
    }
    self.view.backgroundColor = [UIColor clearColor];
    self.imageView.image = self.imageURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didTapOnImage:(id)sender {
    [self.delegate didFinishViewing:sender];
}

@end
