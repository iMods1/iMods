//
//  User.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Mantle/MTLModel.h>
#include <Mantle/MTLJSONAdapter.h>
#include "Constants.h"

@interface IMOUser : MTLModel <MTLJSONSerializing>

/* JSON fields */
@property (nonatomic, copy, readonly) NSNumber *uid;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, assign, readonly) UserRole role;
@property (nonatomic, copy, readwrite) NSString *fullname;
@property (nonatomic, copy, readwrite) NSNumber *age;
@property (nonatomic, copy, readonly) NSString *author_id;

/* Non-JSON fields */

@end

@implementation IMOUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uid": @"url",
             @"email": @"email",
             @"fullname": @"fullname",
             @"age": @"age",
             @"author_id": @"author_id",
             @"role": @"role",
             };
}

@end