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

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"cid": @"cid",
             @"parent_id": @"parent",
             @"name": @"name",
             @"description": @"description",
             };
}

- (id) init:(NSNumber *)cid parent:(NSNumber *)parent_id name:(NSString *)name desc:(NSString *)description {
    self = [self.class init];
    if(self == nil) return nil;
    
    self->_cid = cid;
    self->_parent_id = parent_id;
    self->_name = name;
    self->_description = description;
    return self;
}
@end