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
    return [sessionManager getJSON:@"item/id" urlParameters:@[[NSString stringWithFormat:@"%ld", (long)pkg_id]] parameters:nil];
}

- (PMKPromise*) fetchItemByName:(NSString *)pkg_name {
    NSParameterAssert(pkg_name);
    return [sessionManager getJSON:@"item/pkg" urlParameters:@[pkg_name] parameters:nil];
}

- (PMKPromise*) fetchItemsByCategory:(NSString *)category_name {
    NSParameterAssert(category_name);
    return [sessionManager getJSON:@"category/name"
                     urlParameters:@[category_name]
                        parameters:nil].then(^(OVCResponse *response) {
        return [response.result valueForKey: @"items"];
    });
}

- (PMKPromise*) fetchItemPreviewAssets:(NSInteger)pkg_id dstPath:(NSString *)dstPath {
    // TODO: Implement download manager
    return nil;
}

@end
