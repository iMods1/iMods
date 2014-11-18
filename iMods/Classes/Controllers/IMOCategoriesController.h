//
//  IMOCategoriesController.h
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"

@interface IMOCategoriesController : UIViewControllerNoAutorotate <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *categoriesTableView;

@end
