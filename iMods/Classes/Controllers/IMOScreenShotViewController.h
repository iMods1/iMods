//
//  IMOScreenShotViewController.h
//  iMods
//
//  Created by Ryan Feng on 11/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOItem.h"
#import "IMOScreenShotContentViewController.h"

@interface IMOScreenShotViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, IMOScreenShotContentViewControllerDelegate>

@property IMOItem* item;
@end
