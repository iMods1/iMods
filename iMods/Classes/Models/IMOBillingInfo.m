//
//  BillingInfo.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "IMOBillingInfo.h"

@implementation IMOBillingInfo

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"bid": @"bid",
             @"uid": @"uid",
             @"address": @"address",
             @"zipcode": @"zipcode",
             @"state": @"state",
             @"country": @"country",
             @"currency": @"currency",
             @"paymentType": @"type_",
             @"masked_creditcard_number": @"cc_no",
             @"masked_cv_code": @"cc_cv",
             @"creditcard_expiration_date":@"cc_expr"
             };
}

+ (NSValueTransformer*) paymentTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
  @{
    @"creditcard": @(CreditCard),
    @"paypa": @(Paypal),
    }];
}

@end