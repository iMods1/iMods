//
//  BillingInfo.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>
#import "IMOBillingInfo.h"

@implementation IMOBillingInfo

- (instancetype) initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary* defaults = @{
                               @"paypalAuthCode": @"",
                               @"creditcardNumber": @"",
                               @"creditcardName": @"",
                               @"creditcardName": @"",
                               @"creditcardCVV": @"",
                               };
    return [super initWithDictionary:[defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue] error:error];
}

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"bid": @"bid",
             @"uid": @"uid",
             @"address": @"address",
             @"zipcode": @"zipcode",
             @"city": @"city",
             @"state": @"state",
             @"country": @"country",
             @"paymentType": @"type_",
             @"creditcardNumber": @"cc_no",
             @"creditcardName": @"cc_name",
             @"creditcardExpiration":@"cc_expr",
             @"creditcardCVV": @"cc_cvv",
             @"paypalAuthCode": @"pp_auth_code",
             };
}

#pragma mark -
#pragma mark JSONTransformers

+ (NSValueTransformer*) paymentTypeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:
  @{
    @"creditcard": @(CreditCard),
    @"paypal": @(Paypal),
    }];
}

+ (NSValueTransformer*) creditcardExpirationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString* str){
        return [[self dateFormatter] dateFromString:str];
    }reverseBlock:^(NSDate* date){
        return [[self dateFormatter] stringFromDate:date];
    }];
}

#pragma mark -
#pragma mark Utilities

- (void) maskCreditCardInfo {
    if(self.creditcardNumber && [self->_creditcardNumber length] > 4){
        self->_creditcardNumber = [self.creditcardNumber substringFromIndex:[self.creditcardNumber length] - 4];
    }
    if(self->_creditcardCVV != 0){
        self->_creditcardCVV = 0;
    }
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.dateFormat = @"MM/yy";
    return dateFormatter;
}

- (void) updateFromModel:(IMOBillingInfo*) model{
    self->_bid = model.bid;
    self->_uid = model.uid;
    self->_address = model.address;
    self->_zipcode = model.zipcode;
    self->_city = model.city;
    self->_state = model.state;
    self->_country = model.country;
    self->_paymentType = model.paymentType;
}

- (BOOL) isEqual:(id)object {
    if(![object isKindOfClass:IMOBillingInfo.class]){
        return NO;
    }
    return ((IMOBillingInfo*)object).bid == self.bid;
}
@end