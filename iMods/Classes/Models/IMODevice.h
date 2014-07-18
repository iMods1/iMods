//
//  Device.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

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