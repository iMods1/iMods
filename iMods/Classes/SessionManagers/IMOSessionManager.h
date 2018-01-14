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
#import "IMOUserManager.h"
#import "IMOCategoryManager.h"
#import "IMODeviceManager.h"
#import "IMOOrderManager.h"
#import "IMOItemManager.h"
#import "IMOBillingInfoManager.h"
#import "IMODownloadManager.h"
#import "IMOPackageManager.h"
#import "IMOBannerManager.h"
#import "IMOCacheManager.h"

@class IMOCategoryManager;
@class IMODownloadManager;
@class IMOPackageManager;

typedef void(^IMORequestCallback)(OVCResponse* result, NSError* error);

@interface IMOSessionManager : NSObject

/* Shared session manager instance, you should use this whenever you need session manager.
 * @return The singleton object of IMOSessionManager
 */
+ (IMOSessionManager*) sharedSessionManager;
+ (IMOSessionManager*) sharedSessionManager:(NSURL*) baseURL;

@property (readonly) IMOUserManager* userManager;
@property (readonly) IMOBillingInfoManager* billingManager;
@property (readonly) IMODeviceManager* deviceManager;
@property (readonly) IMOCategoryManager* categoryManager;
@property (readonly) IMOItemManager* itemManager;
@property (readonly) IMOOrderManager* orderManager;
@property (readonly) IMODownloadManager* downloadManager;
@property (readonly) IMOPackageManager* packageManager;
@property (readonly) IMOBannerManager* bannerManager;
@property (readonly) IMOCacheManager* cacheManager;

- (PMKPromise*) postJSON:(NSString*)url data:(NSDictionary*)data;
- (PMKPromise*) postJSON:(NSString*)url urlParameters:(NSArray*)urlParameters data:(NSDictionary*)data;
- (PMKPromise*) getJSON:(NSString*)url parameters:(NSDictionary*)parameters;
- (PMKPromise*) getJSON:(NSString *)url urlParameters:(NSArray*)urlParameters parameters:(NSDictionary *)parameters;
@end