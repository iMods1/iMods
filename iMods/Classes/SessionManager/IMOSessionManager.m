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

@implementation IMOSessionManager

IMONetworkManager* networkManager = nil;

+ (IMOSessionManager*) sharedSessionManager {
    static IMOSessionManager * sharedSessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSessionManager = [[IMOSessionManager alloc] init];
    });
    return sharedSessionManager;
}

- (id) init {
    if (self == [super init]) {
        self.userLoggedIn = NO;
    }
    networkManager = [IMONetworkManager sharedNetworkManager];
    return self;
}

- (PMKPromise*) userLogin:(NSString*)userEmail password:(NSString*) userPassword{
    NSDictionary * postData = @{
                                @"email": userEmail,
                                @"password": userPassword
                                };
    if(self.userLoggedIn){
        NSLog(@"User already logged in, return.");
        return nil;
    }
    
    return [networkManager POST:@"user/login" parameters:postData]
    .then((^(OVCResponse *response, NSError* error){
        if(error != nil){
            NSLog(@"Login failed...");
            return;
        } else {
            self.userLoggedIn = YES;
            self.userProfile = (IMOUser*)response.result;
        }
    }));
}

- (BOOL) userLogout{
    self.userLoggedIn = NO;
    [networkManager GET:@"user/logout" parameters:@{}];
    return YES;
}

- (PMKPromise*) refreshUserProfile{
    return
        [networkManager GET:@"user/profile" parameters:@{}]
        .catch(^(OVCResponse* response, NSError* error){
            self.userProfile = (IMOUser*)response.result;
        });
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword{
    NSDictionary* postData = [NSDictionary dictionary];
    if(fullname != nil){
        [postData setValue:fullname forKey:@"fullname"];
    }
    if(age != nil){
        [postData setValue:age forKey:@"age"];
    }
    if(oldPassword != nil){
        [postData setValue:oldPassword forKey:@"old_password"];
    }
    if(newPassword != nil && oldPassword == nil){
        @throw [NSException exceptionWithName:@"Invalid data" reason:@"Old password cannot be empty" userInfo:nil];
    }else if(newPassword != nil && oldPassword != nil){
        [postData setValue:newPassword forKey:@"new_password"];
    }
    
    return [networkManager POST:@"user/update" parameters:postData]
    .then(^id(OVCResponse* result, NSError* error){
        if(error != nil){
            return error;
        }
        return [self refreshUserProfile];
    });
}

- (PMKPromise*) refreshBillingInfo {
    if(!self.userLoggedIn){
        @throw [NSException exceptionWithName:@"UserNotLogin" reason:@"User must login to get billing information" userInfo:nil];
    }
    return [networkManager POST:@"billing/list" parameters:@{}]
    .then(^(OVCResponse* response, NSError* error){
        NSArray* billingInfoList = response.result;
        [self.userProfile setBillingInfo:billingInfoList];
    });
}

@end
