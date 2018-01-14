//
//  IMOWishlistTableViewCell.h
//  iMods
//
//  Created by Marcus Ferrario on 7/9/15.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOItem.h"


@interface IMOWishlistTableViewCell : UITableViewCell
@property (strong, nonatomic) UIButton *priceBadge;

- (void)configureWithItem:(IMOItem *)item forIndex:(NSIndexPath *)indexPath withViewController:(UIViewController *)parentViewController;
@end
