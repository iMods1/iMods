//
//  TweaksDataSource.m
//  iMods
//
//  Created by Brendon Roberto on 9/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "TweaksDataSource.h"
#import "IMOItem.h"
#import "IMOItemManager.h"

@interface TweaksDataSource ()

@property NSArray *items;

@end

@implementation TweaksDataSource

#pragma mark - IMOItemDataSource

- (IMOItem *)retrieveItemForIndexPath:(NSIndexPath *)path {
    
}

- (void)refresh {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
