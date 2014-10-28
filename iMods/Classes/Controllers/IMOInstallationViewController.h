//
//  IMOMockInstallationViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"
#import "IMOTask.h"

@protocol IMOInstallationDelegate;

@interface IMOInstallationViewController : UIViewController
@property (weak, nonatomic) IBOutlet DACircularProgressView *progressView;
@property (weak, nonatomic) id<IMOInstallationDelegate> delegate;
@property (strong, nonatomic) IMOTask *task;
@end

@protocol IMOInstallationDelegate <NSObject>
- (IMOTask *)taskForInstallation:(IMOInstallationViewController *)installationViewController withOptions: (NSDictionary *)options;
- (void)installationDidFinish:(IMOInstallationViewController *)installationViewController;
- (void)installationDidDismiss:(IMOInstallationViewController *)installationViewController;
@end