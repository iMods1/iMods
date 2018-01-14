//
//  IMOItemDetailViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOInstallationViewController.h"
#import "IMOUninstallationViewController.h"
#import "UIViewControllerNoAutorotate.h"
#import "IMOKeychainManager.h"
#import <LocalAuthentication/LocalAuthentication.h>

@class IMOItem;

@interface IMOItemDetailViewController : UIViewControllerNoAutorotate <IMOInstallationDelegate, UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, IMOUninstallationDelegate>

@property (strong, nonatomic) IMOItem *item;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSString *pass;
- (IBAction)unwindToItemDetailViewController:(UIStoryboardSegue *)sender;
- (void)setUpNavigationBarItemsForCategory:(NSString*)categoryName icon:(UIImage*)categoryIcon;
- (void)setupNavigationBarItemsForSearchResult;
- (void)setupItem:(IMOItem*)item;
- (void) populateIMOItemWithId:(NSString *)pkg_name;
@end
