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

static IMONetworkManager* networkManager = nil;
static IMOSessionManager* sharedSessionManager = nil;

+ (IMOSessionManager*) sharedSessionManager {
    if(sharedSessionManager == nil || networkManager == nil) {
        NSLog(@"Shared session manager is not initialized corrected, call sharedSessionManager:baseUrl to initialize.");
    }
    return sharedSessionManager;
}

+ (IMOSessionManager*) sharedSessionManager:(NSURL*) baseURL {
    if (sharedSessionManager != nil) {
        return sharedSessionManager;
    }
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedSessionManager = [[IMOSessionManager alloc] init:baseURL];
    });
    return sharedSessionManager;
}

- (id) init {
    self = [super init];
    if(self) {
        self.userLoggedIn = NO;
        networkManager = [IMONetworkManager sharedNetworkManager];
    }
    return self;
}

- (id) init:(NSURL*)baseURL {
    self = [super init];
    if(self) {
        self.userLoggedIn = NO;
        networkManager = [IMONetworkManager sharedNetworkManager:baseURL];
    }
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
    .then((^id(OVCResponse *response, NSError* error){
        if(error != nil){
            NSLog(@"Login failed...");
            return nil;
        } else{
            NSLog(@"Login Success");
            self.userLoggedIn = YES;
            return [self refreshUserProfile];
        }
    }))
    ;
}

- (BOOL) userLogout{
    self.userLoggedIn = NO;
    [networkManager GET:@"user/logout" parameters:@{}];
    return YES;
}

- (PMKPromise*) refreshUserProfile{
    return
        [networkManager GET:@"user/profile" parameters:@{}]
        .then(^(OVCResponse* response, NSError* error){
            if(error != nil){
                NSLog(@"Failed to get user profile: %@", error.description);
            }
            self.userProfile = (IMOUser*)response.result;
            NSLog(@"User: %@", self.userProfile);
        });
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age {
    return [self updateUserProfile:fullname age:age oldPassword:nil newPassword:nil];
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword{
    NSMutableDictionary* postData = [NSMutableDictionary dictionary];
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

- (PMKPromise*) userRegister:(NSString*)email password:(NSString*)password fullname:(NSString*)fullname age:(NSNumber*)age author_id:(NSString*)author_id {
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setValue:fullname forKey:@"fullname"];
    [data setValue:email forKey:@"email"];
    [data setValue:age forKey:@"age"];
    [data setValue:password forKey:@"password"];
    [data setValue:author_id forKey:@"author_id"];
    return [networkManager POST:@"user/register" parameters:data]
    .catch((^(NSError* error){
        NSLog(@"Failed to register: %@", error);
    }))
    .then((^(OVCResponse* response, NSError* error){
        self.userProfile = (IMOUser*)response.result;
    }));
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
