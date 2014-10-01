//
//  IMOLoginViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/23/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMOLoginViewController;

@protocol IMOLoginViewDelegate <NSObject>
- (void)loginViewControllerDidFinishLogin:(IMOLoginViewController *)lvc;
@end

@interface IMOLoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) id<IMOLoginViewDelegate>delegate;
@end