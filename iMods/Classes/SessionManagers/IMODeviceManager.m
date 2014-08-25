//
//  IMODeviceManager.m
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMODeviceManager.h"
@import UIKit;

@implementation IMODeviceManager

+ (IMODevice*) currentDevice {
    static IMODevice* device = nil;
    if(device){
        return device;
    }
    NSString* name = [UIDevice currentDevice].name;
    NSString* model = [UIDevice currentDevice].model;
    NSString* udid = (NSString*)([UIDevice currentDevice].identifierForVendor);
    NSString* imei = @"not available";
    NSDictionary* data = @{
                           @"imei": imei,
                           @"udid": udid,
                           @"model": model,
                           @"name": name
                           };
    NSError* error = nil;
    device = [MTLJSONAdapter modelOfClass:IMODevice.class fromJSONDictionary:data error:&error];
    if(!error){
        NSLog(@"Cannot create device object.");
        return nil;
    }
    return device;
}

@end
