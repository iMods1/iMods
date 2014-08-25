//
//  IMOReviewManager.m
//  iMods
//
//  Created by Ryan Feng on 8/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOReviewManager.h"
#import "IMOUserManager.h"
#import "IMOSessionManager.h"

@implementation IMOReviewManager

static IMOSessionManager* sessionManager = nil;
static IMOUserManager* userManager = nil;

- (instancetype) init {
    self = [super init];
    if(self){
        if(!sessionManager){
            sessionManager = [IMOSessionManager sharedSessionManager];
        }
        if(!userManager){
            userManager = [IMOUserManager sharedUserManager];
        }
    }
    return self;
}

- (BOOL) checkUserLogin {
    if (!userManager.userLoggedIn) {
        NSLog(@"User not logged in.");
        return NO;
    }
    return YES;
}

- (PMKPromise*) addReviewForItem:(IMOItem *)item review:(IMOReview *)review {
    if (![self checkUserLogin]) {
        return nil;
    }
    NSMutableDictionary* reviewJson = [NSMutableDictionary dictionaryWithDictionary:[MTLJSONAdapter JSONDictionaryFromModel:review]];
    [reviewJson setValue:@(item.item_id) forKey:@"item_id"];
    return [sessionManager postJSON:@"review/add" data:reviewJson]
    .then(^id(OVCResponse* response, NSError* error){
        if (error) {
            return nil;
        }
        if (!response.result) {
            NSLog(@"nil response result received");
            return nil;
        }
        if (item.reviews) {
            [item.reviews addObject:response.result];
        } else {
            item.reviews = [NSMutableArray arrayWithObject:response.result];
        }
        return item.reviews;
    });
}

- (PMKPromise*) getReviewsByItem:(IMOItem *)item {
    if (![self checkUserLogin]) {
        return nil;
    }
    return [sessionManager getJSON:@"review/item" urlParameters:@[@(item.item_id)] parameters:nil]
    .then(^id(OVCResponse* response, NSError* error){
        if (error) {
            return nil;
        }
        item.reviews = [NSMutableArray arrayWithArray:response.result];
        return item.reviews;
    });
}

- (PMKPromise*) getReviewsByUser:(IMOUser *)user {
    if (![self checkUserLogin]) {
        return nil;
    }
    return [sessionManager getJSON:@"review/user" urlParameters:@[@(user.uid)] parameters:nil]
    .then(^id(OVCResponse* response, NSError* error){
        if(error){
            return nil;
        }
        return response.result;
    });
}

- (PMKPromise*) updateReview:(IMOReview *)newReview {
    if (![self checkUserLogin]) {
        return nil;
    }
    NSDictionary* data = [MTLJSONAdapter JSONDictionaryFromModel:newReview];
    return [sessionManager postJSON:@"review/update" urlParameters:@[@(newReview.rid)] data:data];
}

- (PMKPromise*) removeReview:(IMOReview*)review {
    if (![self checkUserLogin]) {
        return nil;
    }
    return [sessionManager getJSON:@"review/delete" urlParameters:@[@(review.rid)] parameters:nil];
}

@end
