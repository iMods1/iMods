//
//  IMOItemTableViewCell.h
//  iMods
//
//  Created by Brendon Roberto on 11/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOItem.h"


@interface IMOCategoryItemTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *priceBadge;

- (void)configureWithItem:(IMOItem *)item;
@end
