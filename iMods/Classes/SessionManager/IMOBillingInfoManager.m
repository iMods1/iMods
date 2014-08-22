//
//  IMOBillingInfoManager.m
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOBillingInfoManager.h"
#import "IMOSessionManager.h"
#import "IMOUserManager.h"

@implementation IMOBillingInfoManager

static IMOSessionManager* sessionManager = nil;
static IMOUserManager* currentUser = nil;

- (instancetype) init{
    self = [super init];
    if (self) {
        sessionManager = [IMOSessionManager sharedSessionManager];
        currentUser = [IMOUserManager sharedUserManager];
    }
    return self;
}

- (IMOBillingInfo*) billingWithID:(NSUInteger)bid {
    if(!self.billingMethods){
        return nil;
    }
    NSUInteger index = -1;
    index = [self.billingMethods indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
        IMOBillingInfo* billing = obj;
        if(billing.bid == bid){
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if(index == NSNotFound){
        return nil;
    }
    return [self.billingMethods objectAtIndex:index];
}

- (PMKPromise*) addNewBillingMethod:(IMOBillingInfo*)billing {
    NSDictionary* data = [MTLJSONAdapter JSONDictionaryFromModel:billing];
    return [sessionManager postJSON:@"billing/add" data:data]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            NSLog(@"Error occurred when adding billing info");
            return;
        }
        IMOBillingInfo* billingInfo = response.result;
        if (!billingInfo) {
            NSLog(@"Error occurred when converting response result to billing info.");
            return;
        }
        IMOBillingInfo* newBilling = [[IMOBillingInfo alloc] init];
        [newBilling mergeValuesForKeysFromModel:billing];
        [newBilling updateFromModel:billingInfo];
        [newBilling maskCreditCardInfo];
        if (self.billingMethods != nil) {
            [self.billingMethods addObject:newBilling];
        }else{
            self.billingMethods = [NSMutableArray arrayWithObject:newBilling];
        }
        
        // TODO: Verify credit card
    });
}

- (PMKPromise*) updateBillingMethod:(IMOBillingInfo*)newBillingInfo {
    if (!currentUser.userLoggedIn) {
        NSLog(@"User not logged in when adding new billing method.");
        return nil;
    }
    return [sessionManager postJSON:@"billing/update" urlParameters:@[@(newBillingInfo.bid)] data:[MTLJSONAdapter JSONDictionaryFromModel:newBillingInfo]]
    .then(^(OVCResponse* response, NSError* error){
        if (error) {
            return;
        }
        if (newBillingInfo.paymentType == CreditCard) {
            [newBillingInfo maskCreditCardInfo];
        }
        // IMOBillingInfo.isEqual: is overrided, it only compares bid
        NSUInteger index = -1;
        @try {
            index = [self.billingMethods indexOfObject:newBillingInfo];
        }
        @catch (NSException *exception) {
            @throw exception;
            NSLog(@"Billing record not found.");
        }
        [self.billingMethods replaceObjectAtIndex:index withObject:newBillingInfo];
    });
}

- (PMKPromise*) removeBillingMethod:(IMOBillingInfo *)billingInfo {
    if(!billingInfo){
        NSLog(@"'nil' billing info received. Return.");
        return nil;
    }
    if(!currentUser.userLoggedIn){
        NSLog(@"User not logged in when removing billing information.");
        return nil;
    }
    if (![self.billingMethods containsObject:billingInfo]) {
        NSLog(@"Billing info is not registered. Cannot remove it.");
        return nil;
    }
    return [sessionManager getJSON:@"billing/delete" urlParameters:@[@(billingInfo.bid)] parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if (error) {
            return;
        }
        [self.billingMethods removeObject:billingInfo];
    });
}

- (PMKPromise*) removeBillingMethodAtIndex:(NSInteger)index {
    IMOBillingInfo* billing = nil;
    
    @try {
        billing = [self.billingMethods objectAtIndex:index];
    }
    @catch (NSException *e) {
        if ([e.name isEqual:@"NSRangeException"]) {
            NSLog(@"Error occurred when removing billing method: object not found");
            return nil;
        }
    }
    if(billing == nil){
        return nil;
    }
    return [self removeBillingMethod:billing];
}

- (PMKPromise*) refreshBillingMethods {
    if(!currentUser.userLoggedIn){
        NSLog(@"User not logged in when refreshing billing information.");
        return nil;
    }
    return [sessionManager getJSON:@"billing/list" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSArray * billingInfoList = response.result;
        self.billingMethods = [NSMutableArray arrayWithArray:billingInfoList];
        return billingInfoList;
    });
}

@end
