//
//  IMONetworkManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMONetworkManager.h"
#import "IMONetworkErrorResponse.h"

#import "IMOUser.h"
#import "IMOBillingInfo.h"
#import "IMOCategory.h"
#import "IMODevice.h"
#import "IMOItem.h"
#import "IMOOrder.h"
#import "IMOResponse.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFURLResponseSerialization.h>

@implementation IMONetworkManager

static IMONetworkManager * _sharedNetworkManager =  nil;
static dispatch_once_t _onceToken = 0;
static AFJSONRequestSerializer* _jsonRequestSerializer = nil;
static AFJSONResponseSerializer* _jsonResponseSerializer = nil;

+ (IMONetworkManager*) sharedNetworkManager:(NSURL*)baseAPIEndpoint {
    if (_sharedNetworkManager != nil) {
        return _sharedNetworkManager;
    }
    dispatch_once(&_onceToken, ^{
        _sharedNetworkManager = [[IMONetworkManager alloc] initWithBaseURL:baseAPIEndpoint];
        _jsonRequestSerializer = [[AFJSONRequestSerializer alloc] init];
        _jsonResponseSerializer = [[AFJSONResponseSerializer alloc] init];
        _sharedNetworkManager.requestSerializer = _jsonRequestSerializer;
        //_sharedNetworkManager.responseSerializer = _jsonResponseSerializer;
    });
    
    return _sharedNetworkManager;
}

+ (IMONetworkManager*) sharedNetworkManager{
    if(_sharedNetworkManager == nil){
        NSLog(@"Shared network manager is not initialized corrected, call sharedNetworkManager:baseUrl to initialize.");
        return nil;
    }
    return _sharedNetworkManager;
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
             @"user/register": [IMOUser class],
             @"/user/profile": [IMOUser class],
             @"user/login": [IMOResponse class],
             @"billing/*": [IMOBillingInfo class],
             @"category/*": [IMOCategory class],
             @"device/*": [IMODevice class],
             @"item/*": [IMOItem class],
             @"order/*": [IMOOrder class]
             };
}

- (id) init {
    self = [super init];
    return self;
}

@end
