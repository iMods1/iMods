//
//  IMOUpdatesViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"
#import "IMOUpdatesParentCell.h"
#import "IMOPackageManager.h"
#import "IMOUninstallationViewController.h"


@interface IMOUpdatesViewController : UIViewControllerNoAutorotate <UITableViewDataSource, UITableViewDelegate>

@property NSString *uninstallInvoker;

- (void)installationDidFinish:(IMOInstallationViewController *)installationViewController;

@end
