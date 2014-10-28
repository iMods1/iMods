//
//  IMOItemManager.m
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemManager.h"
#import "IMOSessionManager.h"
#import "IMOCategoryManager.h"

@implementation IMOItemManager

#pragma mark -
#pragma mark Static objects

static IMOSessionManager* sessionManager = nil;

#pragma mark -
#pragma mark Initialization

- (instancetype)init{
    self = [super init];
    if(self){
        if(!sessionManager){
            sessionManager = [IMOSessionManager sharedSessionManager];
        }
    }
    return self;
}

#pragma mark -
#pragma mark Item methods

- (PMKPromise*) fetchItemByID:(NSUInteger)pkg_id {
    NSParameterAssert(pkg_id);
    return [sessionManager getJSON:@"item/id" urlParameters:@[[NSString stringWithFormat:@"%ld", (long)pkg_id]] parameters:nil].then(^(OVCResponse *response) {
        NSError *error;
        NSLog(@"fetchItemByID result: %@", response.result);
        IMOItem *item;
        if ([response.result isKindOfClass: [IMOItem class]]) {
            item = response.result;
        } else {
            item = [MTLJSONAdapter modelOfClass:[IMOItem class] fromJSONDictionary:response.result error:&error];
            if (error) {
                @throw error;
            }
        }
        return item;
    });
}

- (PMKPromise*) fetchItemByName:(NSString *)pkg_name {
    NSParameterAssert(pkg_name);
    return [sessionManager getJSON:@"item/pkg" urlParameters:@[pkg_name] parameters:nil].then(^(OVCResponse *response) {
        NSError *error;
        IMOItem *item;
        if ([response.result isKindOfClass: [IMOItem class]]) {
            item = response.result;
        } else {
            item = [MTLJSONAdapter modelOfClass:[IMOItem class] fromJSONDictionary:response.result error:&error];
            if (error) {
                @throw error;
            }
        }
        return item;
    });
}

- (PMKPromise*) fetchItemsByCategory:(NSString *)category_name {
    NSParameterAssert(category_name);
    return [sessionManager getJSON:@"item/cat"
                     urlParameters:@[category_name]
                        parameters:nil].then(^(OVCResponse *response) {
        NSError *error;
        NSArray *items = [MTLJSONAdapter modelsOfClass:[IMOItem class] fromJSONArray:response.result error:&error];
        if (error) {
            @throw error;
        } else {
            return items;
        }
    });
}

@end
