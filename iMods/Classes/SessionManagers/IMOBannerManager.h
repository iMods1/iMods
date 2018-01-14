//
//  IMOBannerManager.h
//  iMods
//
//  Created by Ryan Feng on 11/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOBanner.h"

@interface IMOBannerManager : NSObject

@property (strong, nonatomic) NSArray* banners;

+ (IMOBannerManager*) sharedBannerManager;

- (PMKPromise*) refreshBanners;

@end