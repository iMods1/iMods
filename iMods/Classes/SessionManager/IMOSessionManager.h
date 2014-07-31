//
//  SessionManager.h
//  iMods
//
//  Created by Ryan Feng on 7/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Overcoat/OVCResponse.h>
#import <PromiseKit/Promise.h>
#import "IMOUser.h"

typedef void(^IMORequestCallback)(OVCResponse* result, NSError* error);

@interface IMOSessionManager : NSObject

@property (atomic, assign) bool userLoggedIn;
@property IMOUser* userProfile;

/* Shared session manager instance, you should use this whenever you need session manager.
 * @return The singleton object of IMOSessionManager
 */
+ (IMOSessionManager*) sharedSessionManager;

/* User login
 * @param userEmail User's email address
 * @param userPassword User's password
 * @return PMKPromise object of the current execution.
 */
- (PMKPromise*) userLogin:(NSString*)userEmail password:(NSString*)userPassword;

/* Logout
 * @return Always returns YES
 */
- (BOOL) userLogout; //always returns YES

/* Update user's profile.
 * @param fullname New full name.
 * @param age New age, nil for no change
 * @param oldPassword Current password, may be nil.
 * @param newPassword New password, may be nil, this cannot be nil if oldPassword is not nil.
 */
- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;
@end