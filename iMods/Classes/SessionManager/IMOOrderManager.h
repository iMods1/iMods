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

@interface IMOOrderManager : NSObject

- (instancetype) init;

- (PMKPromise*) fetchOrders;

@end
