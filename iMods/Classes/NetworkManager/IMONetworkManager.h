//
//  IMONetworkManager.h
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Overcoat/OVCHTTPSessionManager+PromiseKit.h>
#import <Overcoat/OVCResponse.h>

@interface IMONetworkManager : OVCHTTPSessionManager

@property (nonatomic, strong, readonly) NSURL * baseURL;

+ (IMONetworkManager*)sharedNetworkManager:(NSURL*)baseAPIEndpoint;
+ (IMONetworkManager*)sharedNetworkManager;
@end