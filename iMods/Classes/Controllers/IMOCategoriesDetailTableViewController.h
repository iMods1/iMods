//
//  IMOCategoriesDetailTableViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMOCategoriesDetailTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) UIImage *categoryIcon;

@end
