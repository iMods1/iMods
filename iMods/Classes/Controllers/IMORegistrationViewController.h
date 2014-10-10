//
//  IMORegistrationViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/9/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOUser.h"

@class IMORegistrationViewController;

@protocol IMORegistrationDelegate <NSObject>

- (void)registrationDidFinish:(IMORegistrationViewController *)sender withEmail:(NSString *)email withPassword:(NSString *)password;

@end

@interface IMORegistrationViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) id<IMORegistrationDelegate> delegate;
@end
