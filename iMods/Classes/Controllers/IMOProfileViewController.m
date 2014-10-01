//
//  IMOProfileViewController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOProfileViewController.h"

@interface IMOProfileViewController ()

@end

@implementation IMOProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"imods-assets-profile-background"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    
    self.tabBarController.tabBar.hidden = NO;
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

@end
