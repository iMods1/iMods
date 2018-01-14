//
//  IMOCategoryChooser.h
//  iMods
//
//  Created by Marcus Ferrario on 12/25/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"
#import "IMOChartsViewController.h"

@interface IMOCategoryChooser : UIViewControllerNoAutorotate <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (void) initWithCharts:(IMOChartsViewController*)root;
@end
