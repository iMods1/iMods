//
//  IMOTabBarController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOTabBarController.h"
#import "IMOUserManager.h"
#import "UICKeyChainStore.h"
#import "AppDelegate.h"

@interface IMOTabBarController ()
- (void)presentLoginViewController:(BOOL)animated;
@end

@implementation IMOTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    IMOUserManager *manager = [IMOUserManager sharedUserManager];
    NSString *email = [UICKeyChainStore stringForKey: @"email"];
    NSString *password = [UICKeyChainStore stringForKey: @"password"];
    
    NSLog(@"User login status: %d", manager.userLoggedIn);
    
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    if (delegate.isRunningTest) {
        return;
    }
    
    if (!manager.userLoggedIn) {
        NSLog(@"User not logged in");
        if (email && password) {
            [self.view setUserInteractionEnabled:NO];
            __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.center = self.view.center;
            [self.view addSubview:indicator];
            [indicator startAnimating];
            [manager userLogin: email password: password].then(^(IMOUser *user) {
                NSLog(@"User: %@ successfully logged in", user);
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                [self.view setUserInteractionEnabled:YES];
            }).catch(^(NSError *error) {
                NSLog(@"Login error: %@", error.localizedDescription);
                
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                [self.view setUserInteractionEnabled:YES];
                // Send user to the login view controller
                [self presentLoginViewController: YES];
            });
        } else {
            [self presentLoginViewController: YES];
        }
    }
}

#pragma mark - IMOLoginViewDelegate

- (void)loginViewControllerDidFinishLogin:(IMOLoginViewController *)lvc {
    [lvc performSegueWithIdentifier:@"login_exit" sender: self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"tab_bar_login_modal"]) {
        if ([[segue destinationViewController] isKindOfClass: [IMOLoginViewController class]]) {
            IMOLoginViewController *lvc = [segue destinationViewController];
            lvc.delegate = self;
        }
    }
}

#pragma mark - Misc

- (void)presentLoginViewController:(BOOL)animated {
    [self performSegueWithIdentifier: @"tab_bar_login_modal" sender: self];
}

- (IBAction)unwindToTabBarController:(UIStoryboardSegue *)sender {
}

@end
