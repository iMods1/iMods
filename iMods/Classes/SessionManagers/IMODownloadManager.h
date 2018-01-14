//
//  IMODownloadManager.h
//  iMods
//
//  Created by Brendon Roberto on 10/27/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Overcoat/OVCResponse.h>
#import <PromiseKit/Promise.h>
#import "IMOItem.h"
#import "IMOSessionManager.h"

typedef enum {
    Deb,
    Assets,
    Index,
    All,
    Icon
} IMODownloadType;

@class IMOSessionManager;

@interface IMODownloadManager : NSObject

@property (weak, nonatomic) IMOSessionManager *sessionManager;

+ (IMODownloadManager *)sharedDownloadManager;

- (PMKPromise *)downloadURL:(IMODownloadType)type item:(IMOItem *)item;
- (PMKPromise *)download:(IMODownloadType)type item:(IMOItem *)item;
- (PMKPromise *)downloadIconFromDictionaryWithitem:(NSDictionary *)item;

@end
