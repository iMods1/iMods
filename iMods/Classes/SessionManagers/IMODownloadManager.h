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

typedef enum {
    Deb,
    Assets,
    Index,
    All
} IMODownloadType;

@interface IMODownloadManager : NSObject

+ (IMODownloadManager *)sharedDownloadManager;

- (PMKPromise *)downloadURL:(IMODownloadType)type item:(IMOItem *)item;
- (PMKPromise *)download:(IMODownloadType)type item:(IMOItem *)item;
- (PMKPromise *)downloadIndex;

@end
