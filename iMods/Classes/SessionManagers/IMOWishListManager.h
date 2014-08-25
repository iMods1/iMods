//
//  IMOWishlistManager.h
//  iMods
//
//  Created by Ryan Feng on 8/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOItem.h"
#import "IMOUser.h"

@interface IMOWishListManager : NSObject

- (PMKPromise*) refreshWishList;
- (PMKPromise*) addItemToWishList:(IMOItem*)item;
- (PMKPromise*) removeItemFromWishListByItem:(IMOItem*)item;
- (PMKPromise*) removeItemFromWishListByIndex:(NSUInteger)idx;
- (PMKPromise*) removeItemFromWishListByItemID:(NSUInteger)iid;
- (PMKPromise*) clearWishList;

@end
