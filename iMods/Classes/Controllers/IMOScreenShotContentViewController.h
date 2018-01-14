//
//  IMOScreenShotContentViewController.h
//  iMods
//
//  Created by Ryan Feng on 11/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMOScreenShotContentViewControllerDelegate <NSObject>

- (void) didFinishViewing:(id)sender;

@end

@interface IMOScreenShotContentViewController : UIViewController

@property (assign) NSUInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSData* imageURL;
@property (weak, nonatomic) UIViewController<IMOScreenShotContentViewControllerDelegate>* delegate;

@end