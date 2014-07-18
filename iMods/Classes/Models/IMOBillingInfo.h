//
//  BillingInfo.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOConstants.h"

@interface IMOBillingInfo : MTLModel <MTLJSONSerializing>

/* JSON fields */
@property (nonatomic, copy, readonly) NSNumber * bid;
@property (nonatomic, copy, readonly) NSNumber * uid;
@property (nonatomic, copy, readwrite) NSString * address;
@property (nonatomic, copy, readwrite) NSNumber * zipcode;
@property (nonatomic, copy, readwrite) NSString * state;
@property (nonatomic, copy, readwrite) NSString * country;
@property (nonatomic, copy, readwrite) NSString * currency; // TODO: Use a dedicated type for currency
@property (nonatomic, assign, readwrite) PaymentType paymentType; // paymentType -> "type_" in JSON

/* Non-JSON fields */
@end