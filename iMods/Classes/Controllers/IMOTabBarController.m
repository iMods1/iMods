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
#import "IMOKeychainManager.h"
#import "AppDelegate.h"
#import "UIView+IMOAnimation.h"
#import "UIColor+HTMLColors.h"
#import "UIImage+Overlay.h"
#import "IMOSessionManager.h"

@interface IMOTabBarController ()
@property (weak) IMOSessionManager* sessionManager;

- (void)presentLoginViewController:(BOOL)animated;
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

- (void)appendSelector {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    for(UITabBarItem *item in self.tabBar.items) {
        item.image = [[item.selectedImage imageWithColor:[UIColor colorWithHexString:@"ACB3BA"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.selectedItemIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(10, self.tabBar.frame.size.height, 6, 6)];
    self.selectedItemIndicatorView.backgroundColor = [UIColor colorWithHexString:@"4F5A64"];
    self.selectedItemIndicatorView.layer.cornerRadius = 3;
    [self.tabBar addSubview:self.selectedItemIndicatorView];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithHexString:@"4F5A64"]];
    [UITabBar appearance].backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [UITabBar appearance].barTintColor = [UIColor colorWithHexString:@"D9D9D9"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"E8E8E8"];
    [UITabBar appearance].opaque = YES;
    [UITabBar appearance].translucent = NO;
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc] init]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    self.sessionManager = [IMOSessionManager sharedSessionManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    self.selectedItemIndicatorView.center = [self getSelectedIndicatorCenterPoint];
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


#pragma mark - Navigation

- (IBAction)unwindToTabBarController:(UIStoryboardSegue *)sender {
}

- (CGPoint)getSelectedIndicatorCenterPoint {
    NSUInteger index = self.selectedIndex + 1;
    return [self getCenterPointForIndex:index];
}

- (CGPoint)getCenterPointForIndex:(NSUInteger)index {
    CGFloat tabMiddle = CGRectGetMidX([[self.tabBar.subviews objectAtIndex:index] frame]);
    
    //return CGPointMake(self.tabBar.frame.origin.y + self.tabBar.frame.size.height, tabMiddle);
    return CGPointMake(tabMiddle, self.tabBar.frame.size.height);
}

@end
