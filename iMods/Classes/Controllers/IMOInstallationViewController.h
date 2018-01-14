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
#import "IMOTask.h"
#import "IMOItem.h"

enum IMOInstallationFinishStatus {
    FinishedSuccessfully = 0x1,
    FinishedWithError = 0x2,
    Running = 0x4,
    Unknown = 0xFFFF
};

@protocol IMOInstallationDelegate;

@interface IMOInstallationViewController : UIViewControllerNoAutorotate <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet MRCircularProgressView* progressView;
@property (weak, nonatomic) id<IMOInstallationDelegate> delegate;
@property (assign, nonatomic) enum IMOInstallationFinishStatus status;
@end

@protocol IMOInstallationDelegate <NSObject>
- (void)installationDidFinish:(IMOInstallationViewController *)installationViewController;
- (IMOItem*) item;
@end