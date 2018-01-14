//
//  IMOUpdatesParentCell.h
//  iMods
//
//  Created by Yannis on 8/5/15.
//  Copyright (c) 2015 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HTMLColors.h"
#import <CoreData/CoreData.h>

@interface IMOUpdatesParentCell : UITableViewCell

- (id)initWithItem:(NSDictionary *)item forIndex:(NSIndexPath *)indexPath withViewController:(UIViewController *)parentViewController;
- (void)installedTab:(BOOL)selected;

@end
