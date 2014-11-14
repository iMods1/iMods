//
//  IMORegistrationViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOUser.h"

@class IMOResetPasswordViewController;

@interface IMOResetPasswordViewController : UIViewController

- (void) prepareToResetPasswordFor:(NSString*)email token:(NSString*)token;

@end