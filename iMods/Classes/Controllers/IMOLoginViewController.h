//
//  IMOLoginViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/23/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMORegistrationViewController.h"
#import "UIViewControllerNoAutorotate.h"

@class IMOLoginViewController;

@protocol IMOLoginDelegate <NSObject>
- (void)loginViewControllerDidFinishLogin:(IMOLoginViewController *)lvc;
@end

@interface IMOLoginViewController : UIViewControllerNoAutorotate <UITextFieldDelegate, IMORegistrationDelegate>
@property (weak, nonatomic) id<IMOLoginDelegate>delegate;

- (void)registrationDidFinish:(IMORegistrationViewController *)sender withEmail:(NSString *)email withPassword:(NSString *)password;

- (IBAction)unwindToLogin:(UIStoryboardSegue *)sender;
@end