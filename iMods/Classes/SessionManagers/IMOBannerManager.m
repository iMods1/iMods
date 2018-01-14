//
//  IMOBannerManager.h
//  iMods
//
//  Created by Ryan Feng on 11/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOBannerManager.h"
#import "IMOSessionManager.h"
#import "IMODownloadManager.h"

@implementation IMOBannerManager

static IMOSessionManager* sessionManager = nil;

+ (IMOBannerManager*) sharedBannerManager {
    static IMOBannerManager* sharedBannerManager = nil;
    if (sharedBannerManager) {
        return sharedBannerManager;
    }
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedBannerManager = [[IMOBannerManager alloc] init];
    });
    return sharedBannerManager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        sessionManager = [IMOSessionManager sharedSessionManager];
    }
    return self;
}

- (PMKPromise*) refreshBanners {
    return [sessionManager getJSON:@"banner/list" parameters:nil]
    .then(^id(OVCResponse* response, NSError* error){
        if (error) {
            NSLog(@"Failed to obtain banners: %@", error.localizedDescription);
            return error;
        }
        self->_banners = response.result;
        return response.result;
    });
}

@end