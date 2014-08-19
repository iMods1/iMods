//
//  Order.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOConstants.h"

@class  IMOBillingInfo;

@interface IMOOrder : MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, assign, readonly) NSInteger oid;
@property (nonatomic, assign, readonly) NSInteger uid;
@property (nonatomic, copy, readonly) NSString * pkg_name;
@property (nonatomic, assign, readwrite) NSInteger quantity; // quantity doesn't much sense for apps, but we might add in-app purchase or other items that can be purchased multiple times
@property (nonatomic, copy, readonly) NSString * currency; // TODO: Use a dedicated currency type
@property (nonatomic, assign, readonly) OrderStatus status;  // Order status will be ignored when submitted to the server, but it's useful when user wants to check their order history.
@property (nonatomic, assign, readonly) NSInteger billing_id;
@property (nonatomic, assign, readwrite) float total_price; // total_price is calculated by the client and verified by the server
@property (nonatomic, assign, readwrite) float total_charged; // total_charged is ignored when submitted to the server, it's an estimated value, the server will return a correct value before payment.
@property (nonatomic, copy, readonly) NSDate * order_date;

/* Non-JSON data fields */
@property (readwrite) IMOBillingInfo * billingInfo; // IMOBillingInfo object for current order.
@end