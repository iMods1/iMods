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

typedef void(^IMORequestCallback)(OVCResponse* result, NSError* error);

@interface IMOSessionManager : NSObject

/* Shared session manager instance, you should use this whenever you need session manager.
 * @return The singleton object of IMOSessionManager
 */
+ (IMOSessionManager*) sharedSessionManager;
+ (IMOSessionManager*) sharedSessionManager:(NSURL*) baseURL;


- (PMKPromise*) postJSON:(NSString*)url data:(NSDictionary*)data;
- (PMKPromise*) getJSON:(NSString*)url parameters:(NSDictionary*)parameters;
- (PMKPromise*) getJSON:(NSString *)url urlParameters:(NSArray*)urlParameters parameters:(NSDictionary *)parameters;
@end