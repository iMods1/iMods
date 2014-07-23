//
//  Device.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMODevice.h"

@implementation IMODevice

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"dev_id": @"dev_id",
             @"uid": @"uid",
             @"device_name": @"device_name",
             @"UDID": @"udid",
             @"IMEI": @"imei",
             @"model": @"model",
             };
}

@end