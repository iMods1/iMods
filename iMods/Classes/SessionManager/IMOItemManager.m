//
//  IMOItemManager.m
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOItemManager.h"
#import "IMOSessionManager.h"

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

- (PMKPromise*) fetchItem:(NSInteger)pkg_id {
    NSParameterAssert(pkg_id);
    return [sessionManager getJSON:@"item/" urlParameters:@[[NSString stringWithFormat:@"%ld", (long)pkg_id]] parameters:nil];
}

- (PMKPromise*) fetchItemPreviewAssets:(NSInteger)pkg_id dstPath:(NSString *)dstPath {
    // TODO: Implement download manager
    return nil;
}

@end
