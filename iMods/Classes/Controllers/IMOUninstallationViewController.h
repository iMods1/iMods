//
//  IMOInstallationViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MRProgress.h>
#import "UIViewControllerNoAutorotate.h"
#import "IMOInstallationViewController.h"
#import "IMOTask.h"
#import "IMOItem.h"
#import "AppDelegate.h"

@protocol IMOUninstallationDelegate;

@interface IMOUninstallationViewController : UIViewControllerNoAutorotate <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MRCircularProgressView* progressView;
@property (weak, nonatomic) id<IMOUninstallationDelegate> delegate;
@property NSString *pkg_name;
@property (assign, nonatomic) enum IMOInstallationFinishStatus status;
@end

@protocol IMOUninstallationDelegate <NSObject>
- (void)removalDidFinish:(IMOUninstallationViewController *)uninstallationViewController;
- (IMOItem*) item;
@end