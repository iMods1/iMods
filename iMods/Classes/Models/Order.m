//
//  Order.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "Constants.h"

@class  IMOBillingInfo;

@interface IMOOrder : MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, copy, readonly) NSNumber * oid;
@property (nonatomic, copy, readonly) NSNumber * uid;
@property (nonatomic, copy, readonly) NSString * pkg_name;
@property (nonatomic, copy, readwrite) NSNumber * quantity; // quantity doesn't much sense for apps, but we might add in-app purchase or other items that can be purchased multiple times
@property (nonatomic, copy, readonly) NSString * currency; // TODO: Use a dedicated currency type
@property (nonatomic, assign, readonly) OrderStatus status;  // Order status will be ignored when submitted to the server, but it's useful when user wants to check their order history.
@property (nonatomic, copy, readonly) NSNumber * billing_id;
@property (nonatomic, assign, readwrite) float total_price; // total_price is calculated by the client and verified by the server
@property (nonatomic, assign, readwrite) float total_charged; // total_charged is ignored when submitted to the server, it's an estimated value, the server will return a correct value before payment.
@property (nonatomic, copy, readonly) NSDate * order_date;

/* Non-JSON data fields */
@property (nonatomic, copy, readwrite) IMOBillingInfo * billingInfo; // IMOBillingInfo object for current order.
@end

@implementation IMOOrder

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"oid": @"oid",
             @"uid": @"uid",
             @"pkg_name": @"pkg_name",
             @"quantity": @"quantity",
             @"currencty": @"currency",
             @"status": @"status",
             @"billing_id": @"billing_id",
             @"total_price": @"total_price",
             @"total_charged": @"total_charged",
             @"order_date": @"order_date",
             @"billingInfo": NSNull.null,
             };
}

+ (NSDateFormatter*) dateFormatter{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSValueTransformer*) order_dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString* str) {
        return [self.dateFormatter dateFromString:str];
    }reverseBlock:^(NSDate* date){
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end