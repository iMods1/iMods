//
//  IMOSessionManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Overcoat/PromiseKit+Overcoat.h>
#import "IMOSessionManager.h"
#import "IMONetworkManager.h"
#import "IMOUser.h"

@interface NSString (NSString_stringByAddingPathComponents)

- (NSString*) stringByAppendingPathComponents:(NSArray*)components;

@end

@implementation NSString (NSString_stringByAddingPathComponents)

- (NSString*) stringByAppendingPathComponents:(NSArray *)components {
    NSString* result = self;
    for(NSString* param in components){
        if(param.class != NSString.class){
            result = [result stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", param]];
        } else {
            result = [result stringByAppendingPathComponent:param];
        }
    }
    return result;
}

@end

@implementation IMOSessionManager

static IMONetworkManager* networkManager = nil;
static IMOSessionManager* sessionManager = nil;

#pragma mark -
#pragma mark Initialization

+ (IMOSessionManager*) sharedSessionManager {
    if(sessionManager == nil || networkManager == nil) {
        NSLog(@"Shared session manager is not initialized corrected, call sessionManager:baseUrl to initialize.");
    }
    return sessionManager;
}

+ (IMOSessionManager*) sharedSessionManager:(NSURL*) baseURL {
    if (sessionManager != nil) {
        return sessionManager;
    }
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sessionManager = [[IMOSessionManager alloc] init:baseURL];
        [sessionManager initManagers];
    });
    return sessionManager;
}

- (id) init {
    self = [super init];
    if(self) {
        networkManager = [IMONetworkManager sharedNetworkManager];
    }
    return self;
}

- (id) init:(NSURL*)baseURL {
    self = [super init];
    if(self) {
        networkManager = [IMONetworkManager sharedNetworkManager:baseURL];
    }
    return self;
}

- (void) initManagers {
    self->_userManager = [IMOUserManager sharedUserManager];
    self->_categoryManager = [[IMOCategoryManager alloc] init];
    self->_billingManager = [[IMOBillingInfoManager alloc] init];
    self->_deviceManager = [[IMODeviceManager alloc] init];
    self->_orderManager = [[IMOOrderManager alloc] init];
    self->_itemManager = [[IMOItemManager alloc] init];
    self->_packageManager = [IMOPackageManager sharedPackageManager];
    self->_bannerManager = [IMOBannerManager sharedBannerManager];
    self->_cacheManager = [IMOCacheManager sharedCacheManager];
}

#pragma mark -
#pragma mark Request helpers


- (PMKPromise*) getJSON:(NSString*)url parameters:(NSDictionary *)parameters {
    return [networkManager GET:url parameters:parameters]
    .catch(^(NSError* error){
        NSLog(@"Error occurred during request: %@", error.localizedDescription);
        // Should propagate errors to clients to handle
        return error;
    });
}

- (PMKPromise*) getJSON:(NSString *)url urlParameters:(NSArray *)urlParameters parameters:(NSDictionary *)parameters {
    NSString* finalURL = [url stringByAppendingPathComponents:urlParameters];
    return [self getJSON:finalURL parameters:parameters];
}

- (PMKPromise*) postJSON:(NSString*)url data:(NSDictionary *)data {
    return [networkManager POST:url parameters:data]
    .catch(^(NSError* error){
        NSLog(@"Error occurred during request: %@", error);
        // Should propagate errors to clients to handle
        return error;
    });
}

- (PMKPromise*) postJSON:(NSString *)url urlParameters:(NSArray *)urlParameters data:(NSDictionary *)data {
    NSString* finalURL = [url stringByAppendingPathComponents:urlParameters];
    return [self postJSON:finalURL data:data];
}
@end
