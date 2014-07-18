//
//  Category.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Mantle/MTLModel.h>
#include <Mantle/MTLJSONAdapter.h>

@interface IMOCategory: MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, copy, readonly) NSNumber * cid;
@property (nonatomic, copy, readonly) NSNumber * parent_id;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSString * description;

/* Non-JSON data fields */

@end

@implementation IMOCategory

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"cid": @"cid",
             @"parent": @"parent_id",
             @"name": @"name",
             @"description": @"description",
             };
}

@end