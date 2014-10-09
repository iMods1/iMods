//
//  IMOProfileSettingsViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOProfileSettingsViewController.h"
#import "UICKeychainStore.h"
#import "IMOUserManager.h"

@interface IMOProfileSettingsViewController ()
- (IBAction)logOutButtonTapped:(id)sender;

@end

@implementation IMOProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)logOutButtonTapped:(id)sender {
    [UICKeyChainStore removeAllItems];
    [[IMOUserManager sharedUserManager] userLogout];
    [self performSegueWithIdentifier:@"settings_login_modal" sender:self];
}
@end
