//
//  IMOWishlistManager.m
//  iMods
//
//  Created by Ryan Feng on 8/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOWishListManager.h"
#import "IMOSessionManager.h"
#import "IMOUserManager.h"

@implementation IMOWishListManager

static IMOSessionManager* sessionManager = nil;
static IMOUserManager* userManager = nil;

- (instancetype) init {
    self = [super init];
    if (self) {
        sessionManager = [IMOSessionManager sharedSessionManager];
        userManager = [IMOUserManager sharedUserManager];
    }
    return self;
}

- (PMKPromise*)refreshWishList{
    return [sessionManager getJSON:@"wishlist" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSLog(@"%@", response.result);
        if (!error) {
            userManager.userProfile.wishlist = response.result;
        }
    });
}

- (PMKPromise*)addItemToWishList:(IMOItem *)item{
    NSDictionary* data = @{
                           @"iid": @(item.item_id)
                           };
    return [sessionManager postJSON:@"wishlist/add" data:data]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        }
        if (userManager.userProfile.wishlist) {
            [userManager.userProfile.wishlist addObject:item];
        } else {
            userManager.userProfile.wishlist = [NSMutableArray arrayWithObject:item];
        }
    });
}

- (PMKPromise*)removeItemFromWishListByItem:(IMOItem *)item {
    if (!userManager.userLoggedIn) {
        NSLog(@"User login required");
        return nil;
    }
    if (!item) {
        NSLog(@"'nil' item received");
        return nil;
    }
    return [sessionManager getJSON:@"wishlist/delete" urlParameters:@[@(item.item_id)] parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        } else {
            [userManager.userProfile.wishlist removeObject:item];
        }
    });
}

- (PMKPromise*)removeItemFromWishListByIndex:(NSUInteger)idx {
    IMOItem* item = [userManager.userProfile.wishlist objectAtIndex:idx];
    if (!item) {
        NSLog(@"Wishlist item at index %ld is not found.", (unsigned long)idx);
        return nil;
    }
    return [self removeItemFromWishListByItem:item];
}

- (PMKPromise*)removeItemFromWishListByItemID:(NSUInteger)iid {
    NSUInteger idx = [userManager.userProfile.wishlist indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL* stop){
        if (((IMOItem*)obj).item_id == iid) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    return [self removeItemFromWishListByIndex:idx];
}

- (PMKPromise*)clearWishList {
    return [sessionManager getJSON:@"wishlist/clear" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        if(error){
            return;
        } else {
            [userManager.userProfile.wishlist removeAllObjects];
        }
    });
}

@end
