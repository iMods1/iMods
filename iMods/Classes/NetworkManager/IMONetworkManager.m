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

@implementation IMONetworkManager

static IMONetworkManager * _sharedNetworkManager =  nil;
static dispatch_once_t _onceToken;

+ (IMONetworkManager*) sharedNetworkManager:(NSURL*)baseAPIEndpoint {
    dispatch_once(&_onceToken, ^{
        _sharedNetworkManager = [[IMONetworkManager alloc] initWithBaseURL:baseAPIEndpoint];
    });
    
    return _sharedNetworkManager;
}

+ (IMONetworkManager*) sharedNetworkManager{
    return _sharedNetworkManager;
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
             @"user/register": IMOUser.class,
             @"user/profile": IMOUser.class,
             @"billing/*": IMOBillingInfo.class,
             @"category/*": IMOCategory.class,
             @"device/*": IMODevice.class,
             @"item/*": IMOItem.class,
             @"order/*": IMOOrder.class
             };
}

+ (Class) errorModelClass {
    return [IMONetworkResponse class];
}

@end
