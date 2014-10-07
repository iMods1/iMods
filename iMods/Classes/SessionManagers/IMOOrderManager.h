//
//  IMOOrderManager.h
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

/* This file is reserved for future use.
 * Please don't delete this.
 */
#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOOrder.h"

@interface IMOOrderManager : NSObject

@property (retain) NSMutableArray* orders;

- (instancetype) init;

- (PMKPromise*) placeNewOrder:(IMOOrder*)newOrder;
- (PMKPromise*) placeNewOrder:(IMOOrder*)newOrder withToken:(NSString *)token;
- (PMKPromise*) cancelOrder:(IMOOrder*)order;
- (PMKPromise*) cancelOrderAtIndex:(NSInteger)index;
- (PMKPromise*) refreshOrders;
- (PMKPromise*) fetchOrderByOrder:(IMOOrder*)order;
- (PMKPromise*) fetchOrderByID:(NSUInteger)oid;
- (PMKPromise*) fetchOrderByUserItem:(NSUInteger)iid;
@end
