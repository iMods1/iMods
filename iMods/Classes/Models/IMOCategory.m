//
//  Category.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMOCategory.h"

@implementation IMOCategory

@synthesize description;

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"cid": @"cid",
             @"parent_id": @"parent",
             @"name": @"name",
             @"desc": @"description",
             };
}

- (id) init:(NSNumber *)cid parent:(NSNumber *)parent_id name:(NSString *)name desc:(NSString *)desc {
    self = [self.class init];
    if(self == nil) return nil;
    
    self->_cid = cid;
    self->_parent_id = parent_id;
    self->_name = name;
    self->_desc = desc;
    return self;
}
@end