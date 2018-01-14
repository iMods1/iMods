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
@property (nonatomic, assign, readonly) NSInteger bid;
@property (nonatomic, assign, readonly) NSInteger uid;
@property (nonatomic, copy, readonly) NSString * address;
@property (nonatomic, assign, readonly) NSInteger zipcode;
@property (nonatomic, copy, readonly) NSString * city;
@property (nonatomic, copy, readonly) NSString * state;
@property (nonatomic, copy, readonly) NSString * country;

// Fields below are credit card information, they should only be used when submitting to the server,
@property (nonatomic, copy, readonly) NSString * creditcardName;
@property (nonatomic, copy, readonly) NSString * creditcardNumber; // credit card number
@property (nonatomic, copy, readonly) NSString * creditcardCVV; // credit card cv code
@property (nonatomic, copy, readonly) NSDate * creditcardExpiration;
@property (nonatomic, assign, readonly) PaymentType paymentType; // paymentType -> "type_" in JSON
@property (nonatomic, copy, readonly) NSString* paypalAuthCode; // Only for submission

/* Non-JSON fields */

- (void) maskCreditCardInfo;
- (void) updateFromModel:(IMOBillingInfo*) model;
- (BOOL) isEqual:(id)object;
@end