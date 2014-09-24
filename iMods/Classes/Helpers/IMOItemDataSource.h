//
//  IMOItemDataSource.h
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IMOItem;

@protocol IMOItemDataSource <UITableViewDataSource>

- (IMOItem *)retrieveItemForIndexPath:(NSIndexPath *)path;
- (void)refresh;

@end
