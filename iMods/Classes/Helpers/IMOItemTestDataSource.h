//
//  IMOItemTestDataSource.h
//  iMods
//
//  Created by Brendon Roberto on 7/22/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMOItemTestDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSMutableArray * items;

- (instancetype) init;
- (instancetype) initWithDictionary:(NSDictionary *)dictionary;

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
