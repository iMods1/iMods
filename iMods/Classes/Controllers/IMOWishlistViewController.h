//
//  IMOWishlistViewController.h
//  iMods
//
//  Created by Marcus Ferrario on 8/9/15.
//  Copyright © 2015 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewControllerNoAutorotate.h"

@interface IMOWishlistViewController : UIViewControllerNoAutorotate <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *wishlistTableView;
- (void)removeItemFromWishlist:(UIButton*)sender;
@end
