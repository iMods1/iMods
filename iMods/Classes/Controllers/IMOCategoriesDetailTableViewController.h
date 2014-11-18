//
//  IMOCategoriesDetailTableViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"

@interface IMOCategoriesDetailTableViewController : UIViewControllerNoAutorotate <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) UIImage *categoryIcon;

@end
