//
//  IMOOrderManager.m
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

/* This file is reserved for future use.
 * Please don't delete this.
 */
#import "IMOOrderManager.h"
#import "IMOSessionManager.h"
#import "IMOUserManager.h"

@implementation IMOOrderManager

static IMOSessionManager* sessionManager = nil;
static IMOUserManager* currentUser = nil;

- (instancetype) init{
    self = [super init];
    if(self){
        sessionManager = [IMOSessionManager sharedSessionManager];
        currentUser = [IMOUserManager sharedUserManager];
    }
    return self;
}

- (PMKPromise*) placeNewOrder:(IMOOrder*)newOrder{
    if(!newOrder){
        NSLog(@"'nil' new order received. Return.");
        return nil;
    }
    if(!currentUser.userLoggedIn){
        NSLog(@"User not logged in when placing new order.");
        return nil;
    }
    NSDictionary* data = [MTLJSONAdapter JSONDictionaryFromModel:newOrder];
    // TODO: Redirect to payment gateway and finish payment.
    return [sessionManager postJSON:@"order/add" data:data]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            @throw error.localizedDescription;
        }
        IMOOrder* order = response.result;
        IMOOrder* serverNewOrder = [[IMOOrder alloc] init];
        [serverNewOrder mergeValuesForKeysFromModel:newOrder];
        [serverNewOrder updateFromModel:order];
        if(![order isKindOfClass:IMOOrder.class]){
            NSLog(@"Errored when placing new order");
            @throw @"Error placing new order";
        }
        if(self.orders) {
            [self.orders addObject:serverNewOrder];
        }else{
            self.orders = [NSMutableArray arrayWithObject:serverNewOrder];
        }
        return serverNewOrder;
    });
}

- (PMKPromise *) placeNewOrder:(IMOOrder *)newOrder withToken:(NSString *)token {
    // TODO: Finish stubbed method
    return [PMKPromise new];
}

- (PMKPromise*) cancelOrder:(IMOOrder *)order {
    if(!order){
        NSLog(@"'nil' order received. Return.");
        return nil;
    }
    if(!currentUser.userLoggedIn){
        NSLog(@"User not logged in when cancelling order.");
        return nil;
    }
    if(!self.orders){
        NSLog(@"User's order list is not initialized: nil");
        return nil;
    }
    return [sessionManager getJSON:@"order/cancel" urlParameters:@[@(order.oid)] parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        }
        IMOOrder* lastOrder = [self.orders lastObject];
        lastOrder.status = OrderCancelled;
    });
}

- (PMKPromise*) cancelOrderAtIndex:(NSInteger)index {
    IMOOrder* order = [self.orders objectAtIndex:index];
    if (order == nil) {
        @throw [NSException exceptionWithName:@"Order not found" reason:@"The order to cancel is not found in user's orders" userInfo:nil];
    }
    return [self cancelOrder:order];
}

- (PMKPromise*) fetchOrderByID:(NSUInteger)oid {
    if(!oid <= 0){
        NSLog(@"Invalid order id received. Return.");
        return nil;
    }
    if(!currentUser.userLoggedIn){
        NSLog(@"User not logged in when placing new order.");
        return nil;
    }
    return [sessionManager getJSON:@"order/id" urlParameters:@[@(oid)] parameters:nil];
}

- (PMKPromise*) fetchOrderByOrder:(IMOOrder*)order {
    if(!order){
        NSLog(@"'nil' order received. Return.");
        return nil;
    }
    return [self fetchOrderByID:order.oid];
}

- (PMKPromise*) fetchOrderByUserItem:(NSUInteger)iid {
    if(!currentUser.userLoggedIn) {
        NSLog(@"User not logged in when placing new order.");
        return nil;
    }
    
    return [sessionManager getJSON:@"order/user_item_purchases"
                     urlParameters:@[@(iid)] parameters:nil];
}

- (PMKPromise*) refreshOrders {
    if(!currentUser.userLoggedIn) {
        NSLog(@"User not logged in when refreshing orders.");
        return nil;
    }
    return [sessionManager getJSON:@"order/list" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSArray* orders = response.result;
        self.orders = [NSMutableArray arrayWithArray:orders];
        return orders;
    });
}

@end
