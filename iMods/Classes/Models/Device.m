//
//  Device.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <Mantle/MTLModel.h>
#include <Mantle/MTLJSONAdapter.h>

@interface IMODevice : MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, copy, readonly) NSNumber * dev_id;
@property (nonatomic, copy, readonly) NSNumber * uid;
@property (nonatomic, copy, readonly) NSString * device_name;
@property (nonatomic, copy, readonly) NSString * IMEI;
@property (nonatomic, copy, readonly) NSString * UDID;
@property (nonatomic, copy, readonly) NSString * model;

/* Non-JSON data fields */

@end

@implementation IMODevice

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"dev_id": @"dev_id",
             @"uid": @"uid",
             @"device_name": @"device_name",
             @"udid": @"UDID",
             @"imei": @"IMEI",
             @"model": @"model",
             };
}

@end