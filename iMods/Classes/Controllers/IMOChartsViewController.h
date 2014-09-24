//
//  IMOChartsTableViewController.h
//  iMods
//
//  Created by Brendon Roberto on 9/15/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMOChartsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (IBAction)unwindToCharts:(UIStoryboardSegue *)segue;

@end
