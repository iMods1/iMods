//
//  IMOItemTestDataSource.m
//  iMods
//
//  Created by Brendon Roberto on 7/22/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemTestDataSource.h"
#import "IMOItem.h"
#import <Mantle/MTLJSONAdapter.h>

@implementation IMOItemTestDataSource

+ (NSDictionary *) dictionary {
    static NSDictionary * dictionary = nil;
    
    if (nil == dictionary) {
        dictionary = @{
            @"iid": @1,
            @"category_id": @1,
            @"author_id": @1,
            @"pkg_name": @"tstpkg",
            @"pkg_version": @"0.0.1",
            @"pkg_assets_path": @"http://i.imgur.com/SrwZy.jpg",
            @"pkg_signature": @"asdfghjkl",
            @"pkg_depenndencies": @"",
            @"display_name": @"Test Package",
            @"price": @0.99,
            @"summary": @"This is a test package for testing purposes.",
            @"description": @"This is a description of Test Package. It includes Lorem Ipsum filler text to make it longer. Lorem ipsum dolor amet sit.",
            @"add_date": [NSDate date],
            @"last_update_date": [NSDate date]
        };
    }
    return dictionary;
}


- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        NSError * error = nil;
        
        IMOItem * item = [MTLJSONAdapter modelOfClass:[IMOItem class]
                                         fromJSONDictionary:dictionary
                                         error:&error];
        if (error) {
            NSLog(@"Could not successfully create IMOItem.");
            NSLog(@"%@", error.debugDescription);
        } else {
            [self.items addObject: item];
        }
    }
    
    return self;
}

- (instancetype) init {
    return [self initWithDictionary: [[self class] dictionary]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = ((IMOItem *)self.items[indexPath.row]).display_name;
    cell.detailTextLabel.text = ((IMOItem *)self.items[indexPath.row]).summary;
    
    return cell;
}

@end
