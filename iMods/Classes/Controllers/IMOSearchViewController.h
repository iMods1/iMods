//
//  IMOSearchViewController.h
//  iMods
//
//  Created by Brendon Roberto on 10/1/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"

@interface IMOSearchViewController : UIViewControllerNoAutorotate <UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate> {
    UIImageView *sBarHairlineImageView;
}
- (void) initWithController:(UIViewController*)root;
- (void) initWithColor:(UIColor *)color;
@end
