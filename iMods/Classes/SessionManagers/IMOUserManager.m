//
//  IMOUserManager.m
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOSessionManager.h"
#import "IMOUserManager.h"
#import "IMOOrder.h"
#import "PromiseKit.h"
#include "IMOWishListManager.h"
//#import <PromiseKit/PromiseKit+Foundation.h>

@implementation IMOUserManager

static IMOSessionManager* sessionManager = nil;
static IMOUser* currentUser = nil;

@synthesize userProfile = currentUser;

#pragma mark -
#pragma mark Initialization

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

+ (IMOUserManager*) sharedUserManager {
    static IMOUserManager* sharedUserManager = nil;
    if(sharedUserManager) {
        return sharedUserManager;
    }
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedUserManager = [[IMOUserManager alloc] init];
    });
    return sharedUserManager;
}

#pragma mark -
#pragma mark User methods

- (PMKPromise*) userLogin:(NSString*)userEmail password:(NSString*) userPassword{
    NSDictionary * postData = @{
                                @"email": userEmail,
                                @"password": userPassword
                                };
    if(self.userLoggedIn){
        NSLog(@"User already logged in, return.");
        return [self refreshUserProfile];
    }
    
    return [sessionManager postJSON:@"user/login" data:postData]
    .then((^id(OVCResponse *response, NSError* error){
        if(error != nil){
            NSLog(@"Login failed...");
            return error;
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
                NSString *errorString = [NSString stringWithFormat:@"Failed to get user profile: %@", error.description];

                NSException *exception = [NSException exceptionWithName:@"LoginFailureException" reason:errorString userInfo:nil];
                @throw exception;
            }
            self.userProfile = (IMOUser*)response.result;
            return self.userProfile;
        }).then(^(){
            IMOWishListManager *wishlistManager = [[IMOWishListManager alloc] init];
            [wishlistManager refreshWishList];
        });
}

- (PMKPromise*) refreshInstalled {
    return [sessionManager.packageManager installedPkglist].then(^(NSMutableArray *installed){
        self.installedItems = installed;
    });
}

- (PMKPromise*) refreshUpdates {
    return [sessionManager.packageManager checkUpdates:YES].then(^(NSArray *updates){
        return updates;
    });
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age {
    return [self updateUserProfile:fullname age:age oldPassword:nil newPassword:nil];
}

- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword{
    if (!self.userLoggedIn) {
        NSLog(@"User not loggedin");
    }
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

- (PMKPromise*) userRequestResetPassword:(NSString *)email {
    return [sessionManager getJSON:@"user/request_reset_password" parameters:@{ @"email": email }];
}

- (PMKPromise*) userResetPassword:(NSString *)email token:(NSString *)token new_password:(NSString *)new_password {
    return [sessionManager postJSON:@"user/reset_password"
                               data:@{
                                      @"email": email,
                                      @"token": token,
                                      @"new_password": new_password
                                      }];
}

- (PMKPromise*) getProfileImage {
    return [sessionManager getJSON:@"user/profile_image" parameters:nil]
    .then(^id(OVCResponse* response, NSError* error){
        if (error) {
            NSLog(@"Unable to get profile image: %@", error.localizedDescription);
            return error;
        }
        NSURL* imgURL = [NSURL URLWithString:[response.result valueForKey:@"profile_image_url"]];
        if (imgURL) {
            return imgURL;
        }
        return nil;
    });
}

@end
