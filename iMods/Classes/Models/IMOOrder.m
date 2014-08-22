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
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>
#import "IMOOrder.h"

@implementation IMOOrder

- (instancetype) initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    
    IMOItem* item = nil;
    @try{
        item = [dictionaryValue valueForKey:@"item"];
    }@catch(NSException* e){
        
    }
    NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithDictionary:
                            @{ @"oid": @0,
                               @"uid": @0,
                               @"status": @(OrderPlaced),
                               @"quantity": @1,
                               @"orderDate": [NSDate date],
                               @"currency": @"USD"
                               }];
    if(item){
        [defaults setValue:@(item.item_id) forKey:@"item_id"];
    }
    return [super initWithDictionary:[defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue] error:error];
}

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"billing_id": @"billing_id",
             @"item_id": @"item_id",
             @"pkg_name": @"pkg_name",
             @"totalPrice": @"total_price",
             @"totalCharged": @"total_charged",
             // optional keys
             @"oid": @"oid",
             @"uid": @"uid",
             @"quantity": @"quantity",
             @"currency": @"currency",
             @"status": @"status",
             @"orderDate": @"order_date",
             @"billingInfo": @"billing",
             @"item": @"item"
             };
}

+ (NSDateFormatter*) dateFormatter{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    return dateFormatter;
}

+ (NSValueTransformer*) orderDateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString* str) {
        return [self.dateFormatter dateFromString:str];
    }reverseBlock:^(NSDate* date){
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer*) billingInfoJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:IMOBillingInfo.class];
}

+ (NSValueTransformer*) itemJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:IMOItem.class];
}

- (void) updateFromModel:(IMOOrder *)model {
    self->_oid = model.oid;
    self->_uid = model.uid;
    self->_quantity = model.quantity;
    self->_currency = model.currency;
    self->_status = model.status;
    self->_billing_id = model.billing_id;
    self->_totalPrice = model.totalPrice;
    self->_totalCharged = model.totalCharged;
    self->_orderDate = model.orderDate;
    if(!self.billingInfo){
        self.billingInfo = model.billingInfo;
    }
    if(!self.item){
        self.item = model.item;
    }
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOOrder.class]) {
        return NO;
    }
    return ((IMOOrder*)object).oid == self.oid;
}

@end