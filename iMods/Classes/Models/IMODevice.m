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

- (BOOL) isEqual:(id)object {
    if(![object isKindOfClass:IMODevice.class]){
        return NO;
    }
    return ((IMODevice*)object).dev_id == self.dev_id;
}

- (void) updateFromModel:(IMODevice *)model {
    self->_dev_id = model.dev_id;
    self->_uid = model.uid;
}
@end