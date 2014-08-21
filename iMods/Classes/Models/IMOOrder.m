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
#import "IMOOrder.h"

@implementation IMOOrder

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"oid": @"oid",
             @"uid": @"uid",
             @"pkg_name": @"pkg_name",
             @"quantity": @"quantity",
             @"currencty": @"currency",
             @"status": @"status",
             @"billingID": @"billing_id",
             @"totalPrice": @"total_price",
             @"totalCharged": @"total_charged",
             @"orderDate": @"order_date",
             //@"billingInfo": NSNull.null,
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

- (void) updateFromModel:(IMOOrder *)model {
    self->_oid = model.oid;
    self->_uid = model.uid;
    self->_quantity = model.quantity;
    self->_currency = model.currency;
    self->_status = model.status;
    self->_bid = model.bid;
    self->_totalPrice = model.totalPrice;
    self->_totalCharged = model.totalCharged;
    self->_orderDate = model.orderDate;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOOrder.class]) {
        return NO;
    }
    return ((IMOOrder*)object).oid == self.oid;
}

@end