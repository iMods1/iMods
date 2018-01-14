//
//  Category.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>
#import "IMOCategory.h"

@implementation IMOCategory

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"cid": @"cid",
             @"parent_id": @"parent_id",
             @"name": @"name",
             @"desc": @"description",
             @"parent": @"parent",
             @"children": @"children"
             };
}

- (id) init:(NSInteger)cid parent_id:(NSInteger)parent_id name:(NSString *)name description:(NSString *)description {
    self = [super init];
    if(self == nil) return nil;
    
    self->_cid = cid;
    self->_parent_id = parent_id;
    self->_name = name;
    self->_desc = description;
    return self;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOCategory.class]) {
        return NO;
    }
    return ((IMOCategory*)object).cid == self.cid;
}

@end