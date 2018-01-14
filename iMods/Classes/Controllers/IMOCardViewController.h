//
//  IMOCardViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/5/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOBillingInfo.h"
#import "UIViewControllerNoAutorotate.h"

@protocol IMOCardDelegate;

@interface IMOCardViewController : UIViewControllerNoAutorotate <UITextFieldDelegate>

@property (weak, nonatomic) id<IMOCardDelegate> delegate;

@end

@protocol IMOCardDelegate

- (void)cardControllerDidCancel:(IMOCardViewController *)cardController;
- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withBillingInfo:(IMOBillingInfo *)info;

@end