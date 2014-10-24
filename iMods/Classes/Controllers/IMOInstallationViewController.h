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

@protocol IMOMockInstallationDelegate;

@interface IMOMockInstallationViewController : UIViewController
@property (weak, nonatomic) IBOutlet DACircularProgressView *progressView;
@property (weak, nonatomic) id<IMOMockInstallationDelegate> delegate;
@property (strong, nonatomic) IMOTask *task;
@end

@protocol IMOMockInstallationDelegate <NSObject>
- (IMOTask *)taskForMockInstallation:(IMOMockInstallationViewController *)installationViewController withOptions: (NSDictionary *)options;
- (void)installationDidFinish:(IMOMockInstallationViewController *)installationViewController;
- (void)installationDidDismiss:(IMOMockInstallationViewController *)installationViewController;
@end