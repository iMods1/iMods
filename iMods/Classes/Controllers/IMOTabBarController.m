//
//  IMOTabBarController.m
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOTabBarController.h"
#import "IMOResetPasswordViewController.h"
#import "IMOUserManager.h"
#import "UICKeyChainStore.h"
#import "AppDelegate.h"
#import "UIView+IMOAnimation.h"

@interface IMOTabBarController ()
@property (strong, nonatomic) UIView *selectedItemIndicatorView;

- (void)presentLoginViewController:(BOOL)animated;
- (CGPoint)getSelectedIndicatorCenterPoint;
- (CGPoint)getCenterPointForIndex:(NSUInteger)index;
@end

@implementation IMOTabBarController

- (BOOL)shouldAutorotate;
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIViewController * top;
    UIViewController * tab = self.selectedViewController;
    if([tab isKindOfClass:
        ([UINavigationController class])]) {
        top = [((UINavigationController *)tab)
               topViewController];
    }
    
    if ([top respondsToSelector:@selector(supportedInterfaceOrientations)])
        return [top supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedItemIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    self.selectedItemIndicatorView.backgroundColor = [UIColor darkGrayColor];
    self.selectedItemIndicatorView.layer.cornerRadius = 3;
    [self.view addSubview:self.selectedItemIndicatorView];
    
    [UITabBar appearance].selectedImageTintColor = [UIColor darkGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    self.selectedItemIndicatorView.center = [self getSelectedIndicatorCenterPoint];
    [self.view bringSubviewToFront:self.selectedItemIndicatorView];
    
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
            __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.center = self.view.center;
            [self.view addSubview:indicator];
            [indicator startAnimating];
            [manager userLogin: email password: password].then(^(IMOUser *user) {
                NSLog(@"User: %@ successfully logged in", user);
                [indicator stopAnimating];
                [indicator removeFromSuperview];
            }).catch(^(NSError *error) {
                NSLog(@"Login error: %@", error.localizedDescription);
                
                [indicator stopAnimating];
                [indicator removeFromSuperview];
                // Send user to the login view controller
                [self presentLoginViewController: YES];
            });
        } else {
            [self presentLoginViewController: YES];
        }
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    __block NSUInteger index = [self.tabBar.items indexOfObject:item] + 1;
    NSDictionary *animationOptions = @{
                                       IMOAnimationIDKey:self.description,
                                       IMOAnimationDurationKey:@(0.2),
                                       };
    [self.selectedItemIndicatorView animateWithBlock:^(UIView *view) {
        view.center = [self getCenterPointForIndex:index];
    } options:animationOptions];
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

- (CGPoint)getSelectedIndicatorCenterPoint {
    NSUInteger index = self.selectedIndex + 1;
    return [self getCenterPointForIndex:index];
}

- (CGPoint)getCenterPointForIndex:(NSUInteger)index {
    CGFloat tabMiddle = CGRectGetMidX([[self.tabBar.subviews objectAtIndex:index] frame]);
    
    //return CGPointMake(self.tabBar.frame.origin.y + self.tabBar.frame.size.height, tabMiddle);
    return CGPointMake(tabMiddle, self.tabBar.frame.origin.y + self.tabBar.frame.size.height);
}

@end
