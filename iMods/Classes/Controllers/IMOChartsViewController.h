//
//  IMOChartsTableViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"

@interface IMOChartsViewController : UIViewControllerNoAutorotate <UITableViewDataSource, UITableViewDelegate>

- (IBAction)unwindToCharts:(UIStoryboardSegue *)segue;
- (void) setCategory:(NSString *)category;

@end
