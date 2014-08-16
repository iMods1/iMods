//
//  IMOUserManager.m
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOSessionManager.h"
#import "IMOUserManager.h"

@implementation IMOUserManager

static IMOSessionManager* sessionManager = nil;

- (id)init {
    self = [super init];
    if(self != nil){
        self.userLoggedIn = NO;
        sessionManager = [IMOSessionManager sharedSessionManager];
        if (sessionManager == nil) {
            NSLog(@"Cannot get the instance of session manager");
        }
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
    
    return [sessionManager postJSON:@"user/login" data:postData]
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
    [sessionManager getJSON:@"user/logout" parameters:nil].finally((^(){
        NSLog(@"User logout requested");
    }));
    return YES;
}

- (PMKPromise*) refreshUserProfile{
    return [sessionManager getJSON:@"user/profile" parameters:nil]
        .then(^(OVCResponse* response, NSError* error){
            if(error != nil){
                NSLog(@"Failed to get user profile: %@", error.description);
            }
            self.userProfile = (IMOUser*)response.result;
            NSLog(@"Response: %@", response);
            NSLog(@"User: %@ %@", self.userProfile.class, self.userProfile);
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
    
    return [sessionManager postJSON:@"user/update" data:postData]
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
    return [sessionManager postJSON:@"user/register" data:data]
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
    return [sessionManager getJSON:@"billing/list" parameters:nil]
    .then(^(OVCResponse* response, NSError* error){
        NSArray* billingInfoList = response.result;
        [self.userProfile setBillingInfo:billingInfoList];
    });
}

@end
