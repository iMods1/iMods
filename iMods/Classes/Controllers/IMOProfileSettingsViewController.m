//
//  IMOProfileSettingsViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOProfileSettingsViewController.h"
#import "UICKeychainStore.h"
#import "IMOLoginViewController.h"
#import "IMOTabBarController.h"
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"settings_login_modal"]) {
        ((IMOLoginViewController *)segue.destinationViewController).delegate = self;
    }
}


- (IBAction)logOutButtonTapped:(id)sender {
    [UICKeyChainStore removeAllItems];
    [[IMOUserManager sharedUserManager] userLogout];
    [self performSegueWithIdentifier:@"settings_login_modal" sender:self];
}

#pragma mark - IMOLoginDelegate

- (void)loginViewControllerDidFinishLogin:(IMOLoginViewController *)lvc {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}
@end
