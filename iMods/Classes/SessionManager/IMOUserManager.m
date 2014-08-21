//
//  IMOUserManager.m
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOSessionManager.h"
#import "IMOUserManager.h"
#import "IMOOrder.h"

@implementation IMOUserManager

static IMOSessionManager* sessionManager = nil;
static IMOUser* currentUser = nil;

@synthesize userProfile = currentUser;

#pragma mark -
#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if(self != nil){
        self.userLoggedIn = NO;
        sessionManager = [IMOSessionManager sharedSessionManager];
        if (sessionManager == nil) {
            NSLog(@"Cannot get the instance of session manager");
        }
    }
    return self;
}

+ (IMOUserManager*) sharedUserManager {
    static IMOUserManager* sharedUserManager = nil;
    if(sharedUserManager) {
        return sharedUserManager;
    }
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedUserManager = [[IMOUserManager alloc] init];
    });
    return sharedUserManager;
}

#pragma mark -
#pragma mark User methods

- (PMKPromise*) userLogin:(NSString*)userEmail password:(NSString*) userPassword{
    NSDictionary * postData = @{
                                @"email": userEmail,
                                @"password": userPassword
                                };
    if(self.userLoggedIn){
        NSLog(@"User already logged in, return.");
        return nil;
    }
    
    return [sessionManager postJSON:@"user/login" data:postData]
    .then((^id(OVCResponse *response, NSError* error){
        if(error != nil){
            NSLog(@"Login failed...");
            return nil;
        } else{
            NSLog(@"Login Success");
            self.userLoggedIn = YES;
            return [self refreshUserProfile];
        }
    }))
    ;
}

- (BOOL) userLogout{
    self.userLoggedIn = NO;
    [sessionManager getJSON:@"user/logout" parameters:nil].finally((^(){
        NSLog(@"User logout requested");
    }));
    return YES;
}

- (PMKPromise*) refreshUserProfile{
    return [sessionManager getJSON:@"user/profile" parameters:nil]
        .then(^(OVCResponse* response, NSError* error){
            if(error != nil){
                NSLog(@"Failed to get user profile: %@", error.description);
            }
            self.userProfile = (IMOUser*)response.result;
        });
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age {
    return [self updateUserProfile:fullname age:age oldPassword:nil newPassword:nil];
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword{
    if (!self.userLoggedIn) {
        NSLog(@"User not loggedin");
    }
    NSMutableDictionary* postData = [NSMutableDictionary dictionary];
    if(fullname != nil){
        [postData setValue:fullname forKey:@"fullname"];
    }
    if(age != nil){
        [postData setValue:age forKey:@"age"];
    }
    if(oldPassword != nil){
        [postData setValue:oldPassword forKey:@"old_password"];
    }
    if(newPassword != nil && oldPassword == nil){
        @throw [NSException exceptionWithName:@"Invalid data" reason:@"Old password cannot be empty" userInfo:nil];
    }else if(newPassword != nil && oldPassword != nil){
        [postData setValue:newPassword forKey:@"new_password"];
    }
    
    return [sessionManager postJSON:@"user/update" data:postData]
    .then(^id(OVCResponse* result, NSError* error){
        if(error != nil){
            return error;
        }
        return [self refreshUserProfile];
    });
}

- (PMKPromise*) userRegister:(NSString*)email password:(NSString*)password fullname:(NSString*)fullname age:(NSNumber*)age author_id:(NSString*)author_id {
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue:fullname forKey:@"fullname"];
    [data setValue:email forKey:@"email"];
    [data setValue:age forKey:@"age"];
    [data setValue:password forKey:@"password"];
    [data setValue:author_id forKey:@"author_id"];
    return [sessionManager postJSON:@"user/register" data:data]
    .catch((^(NSError* error){
        NSLog(@"Failed to register: %@", error);
    }))
    .then((^(OVCResponse* response, NSError* error){
        self.userProfile = (IMOUser*)response.result;
    }));
}

#pragma mark -
#pragma mark Billing Information

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
        if (self.userProfile.billing_methods != nil) {
            [self.userProfile.billing_methods addObject:newBilling];
        }else{
            self.userProfile.billing_methods = [NSMutableArray arrayWithObject:newBilling];
        }
        
        // TODO: Verify credit card
    });
}

- (PMKPromise*) updateBillingMethod:(IMOBillingInfo*)newBillingInfo {
    if (!self.userLoggedIn) {
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
            index = [self.userProfile.billing_methods indexOfObject:newBillingInfo];
        }
        @catch (NSException *exception) {
            @throw exception;
            NSLog(@"Billing record not found.");
        }
        [self.userProfile.billing_methods replaceObjectAtIndex:index withObject:newBillingInfo];
    });
}

- (PMKPromise*) removeBillingMethod:(IMOBillingInfo *)billingInfo {
    if(!billingInfo){
        NSLog(@"'nil' billing info received. Return.");
        return nil;
    }
    if(!self.userLoggedIn){
        NSLog(@"User not logged in when removing billing information.");
        return nil;
    }
    if (![self.userProfile.billing_methods containsObject:billingInfo]) {
        NSLog(@"Billing info is not registered. Cannot remove it.");
        return nil;
    }
    return [sessionManager getJSON:@"billing/delete" urlParameters:@[@(billingInfo.bid)] parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if (error) {
            return;
        }
        [self.userProfile.billing_methods removeObject:billingInfo];
    });
}

- (PMKPromise*) removeBillingMethodAtIndex:(NSInteger)index {
    IMOBillingInfo* billing = nil;
    
    @try {
        billing = [self.userProfile.billing_methods objectAtIndex:index];
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
    if(!self.userLoggedIn){
        NSLog(@"User not logged in when refreshing billing information.");
        return nil;
    }
    return [sessionManager getJSON:@"billing/list" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSArray * billingInfoList = response.result;
        self.userProfile.billing_methods = [NSMutableArray arrayWithArray:billingInfoList];
        return billingInfoList;
    });
}

#pragma mark -
#pragma mark Order Information

- (PMKPromise*) placeNewOrder:(IMOOrder*)newOrder{
    if(!newOrder){
        NSLog(@"'nil' new order received. Return.");
        return nil;
    }
    if(!self.userLoggedIn){
        NSLog(@"User not logged in when placing new order.");
        return nil;
    }
    NSDictionary* data = [MTLJSONAdapter JSONDictionaryFromModel:newOrder];
    // TODO: Redirect to payment gateway and finish payment.
    return [sessionManager postJSON:@"order/add" data:data]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        }
        IMOOrder* order = response.result;
        if(![order isKindOfClass:IMOOrder.class]){
            NSLog(@"Errored when placing new order");
            return;
        }
        if(self.userProfile.orders) {
            [self.userProfile.orders addObject:newOrder];
        }else{
            self.userProfile.orders = [NSMutableArray arrayWithObject:newOrder];
        }
    });
}

- (PMKPromise*) cancelOrder:(IMOOrder *)order {
    if(!order){
        NSLog(@"'nil' order received. Return.");
        return nil;
    }
    if(!self.userLoggedIn){
        NSLog(@"User not logged in when cancelling order.");
        return nil;
    }
    if(!self.userProfile.orders){
        NSLog(@"User's order list is not initialized: nil");
        return nil;
    }
    return [sessionManager getJSON:@"order/cancel" urlParameters:@[@(order.oid)] parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        }
        [self.userProfile.orders removeObject:order];
    });
}

- (PMKPromise*) cancelOrderAtIndex:(NSInteger)index {
    IMOOrder* order = [self.userProfile.orders objectAtIndex:index];
    if (order == nil) {
        @throw [NSException exceptionWithName:@"Order not found" reason:@"The order to cancel is not found in user's orders" userInfo:nil];
    }
    return [self cancelOrder:order];
}

- (PMKPromise*) refreshOrders {
    if(!self.userLoggedIn) {
        NSLog(@"User not logged in when refreshing orders.");
        return nil;
    }
    return [sessionManager getJSON:@"order/list" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSArray* orders = response.result;
        self.userProfile.orders = [NSMutableArray arrayWithArray:orders];
        return orders;
    });
}

@end
