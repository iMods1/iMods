//
//  IMOUserManager.h
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOUser.h"

@interface IMOUserManager : NSObject

@property (atomic, assign) bool userLoggedIn;
@property IMOUser* userProfile;

@property (strong, nonatomic) NSMutableArray *installedItems;

/* An shared instance of IMOUserManager, it represents the current user.
 */
+ (IMOUserManager*) sharedUserManager;

/* User login
 * @param userEmail User's email address
 * @param userPassword User's password
 * @return PMKPromise object of the current execution.
 */
- (PMKPromise*) userLogin:(NSString*)userEmail password:(NSString*)userPassword;

- (PMKPromise*) refreshInstalled;
- (PMKPromise*) refreshUpdates;

/* Register a user
 * @param email User email
 * @param password User's password
 * @param fullname User's fullname
 * @param age User's age
 * @param author_id Author identifier of the user
 */
- (PMKPromise*) userRegister:(NSString*)email password:(NSString*)password fullname:(NSString*)fullname age:(NSNumber*)age author_id:(NSString*)author_id;

- (PMKPromise*) userRequestResetPassword:(NSString*)email;
- (PMKPromise*) userResetPassword:(NSString*)email token:(NSString*)token new_password:(NSString*)new_password;

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
- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age;
- (PMKPromise*) updateUserProfile:(NSString*)fullname age:(NSNumber*)age oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;

- (PMKPromise*) getProfileImage;

@end
