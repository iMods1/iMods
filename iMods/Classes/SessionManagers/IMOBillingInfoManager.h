//
//  IMOBillingInfoManager.h
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOBillingInfo.h"

@interface IMOBillingInfoManager : NSObject

@property (retain) NSMutableArray* billingMethods;

- (PMKPromise*) addNewBillingMethod:(IMOBillingInfo*)billingInfo;
- (PMKPromise*) updateBillingMethod:(IMOBillingInfo*)newBillingInfo;
- (PMKPromise*) removeBillingMethod:(IMOBillingInfo*)billingInfo;
- (PMKPromise*) removeBillingMethodAtIndex:(NSInteger)index;
- (PMKPromise*) refreshBillingMethods;
- (IMOBillingInfo*) billingWithID:(NSUInteger)bid;

@end
