//
//  IMODownloadManager.m
//  iMods
//
//  Created by Brendon Roberto on 10/27/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMODownloadManager.h"
#import <PromiseKit.h>
#import <Promise+When.h>

@interface IMODownloadManager ()
@end

@implementation IMODownloadManager

static IMODownloadManager *downloadManager = nil;

+ (IMODownloadManager *)sharedDownloadManager {
    if (downloadManager != nil) {
        return downloadManager;
    }
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        downloadManager = [[IMODownloadManager alloc] init];
    });
    return downloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [IMOSessionManager sharedSessionManager];
    }
    return self;
}

- (PMKPromise *)downloadURL:(IMODownloadType)type item:(IMOItem *)item {
    NSString *downloadType;
    switch (type) {
        case Deb:
            downloadType = @"deb";
            break;
        case Assets:
            downloadType = @"assets";
            break;
        case All:
            downloadType = @"all";
            break;
        default:
            break;
    }
    NSDictionary *paramsDict = @{
                                 @"item_ids": @[[item valueForKey:@"item_id"]],
                                 @"type": downloadType
                                 };
    return [self.sessionManager postJSON:@"package/get" data:paramsDict];
}

- (PMKPromise *)download:(IMODownloadType)type item:(IMOItem *)item {
    switch (type) {
        case Deb:
            return [self downloadURL:type item:item].then(^(OVCResponse *response, NSError *error) {
                NSString *urlString = [[[response valueForKey: @"result"]  valueForKey: @"deb_url"] firstObject];
                __block NSString *nameString = [NSString stringWithFormat:@"%@-%f.deb", [[[response valueForKey:@"result"]  valueForKey: @"pkg_name"] firstObject], [[NSDate date] timeIntervalSince1970] * 1000];
                NSLog(@"nameString: %@", nameString);
                NSURL *url = [[NSURL alloc] initWithString:urlString];
                return [NSURLConnection promise:[NSURLRequest requestWithURL: url]]
                .then(^(NSData *data) {
                    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"] stringByAppendingString: nameString];
                    [data writeToFile:filePath atomically:YES];
                    return filePath;
                });
            });
            break;
        case Assets:
            return [self downloadURL:type item:item].then(^(OVCResponse *response, NSError *error) {
                NSDictionary *result = [[response valueForKey:@"result"] firstObject];
                NSDictionary *assetDetails = [result valueForKey:@"assets"];
                
                NSString *cacheKey = [NSString stringWithFormat:@"%@%@%ld", [item valueForKey:@"pkg_name"], [item valueForKey:@"pkg_version"], (long)[item valueForKey:@"item_id"]];
                NSDictionary *cachedEntry = [self.sessionManager.cacheManager objectForKey:cacheKey];
                NSURL *iconURL = [NSURL URLWithString: [[[assetDetails valueForKey: @"icons"] firstObject] valueForKey: @"url"]];

                PMKPromise *iconPromise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
                    if (cachedEntry != nil) {
                        fulfill([cachedEntry objectForKey:@"icon"]);
                    } else {
                        fulfill([NSURLConnection promise: [NSURLRequest requestWithURL:iconURL ]].then(^(NSData *imageData) {
                            NSMutableDictionary *iconDict = [[NSMutableDictionary alloc] init];
                            [iconDict setObject:imageData forKey:@"icon"];
                            [self.sessionManager.cacheManager setObject:iconDict forKey:cacheKey];
                            return imageData;
                        }));
                    }
                }];

                NSArray *screenshots = [assetDetails valueForKey:@"screenshots"];
                NSArray *videos = [assetDetails valueForKey:@"videos"];
                NSMutableArray* urls = [[NSMutableArray alloc] init];
                for (NSDictionary* ss in screenshots) {
                    NSURL* ssURL = [NSURL URLWithString:[ss valueForKey:@"url"]];
                    if (ssURL) {
                        [urls addObject:ssURL];
                    }
                }
                NSArray *banners = [assetDetails valueForKey:@"banners"];
                if (!banners) {
                    banners = [[NSArray alloc] init];
                }
                NSDictionary *finalAssets = @{ @"icon": iconPromise,
                                               @"screenshots": urls,
                                               @"videos": videos,
                                               @"banners": banners
                                            };
                return [PMKPromise when:finalAssets];
            });
            break;
        case Icon:
            return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
                NSString *cacheKey = [NSString stringWithFormat:@"%@%@%ld", [item valueForKey:@"pkg_name"], [item valueForKey:@"pkg_version"], (long)[item valueForKey:@"item_id"]];
                NSDictionary *cachedEntry = [self.sessionManager.cacheManager objectForKey:cacheKey];
                if (cachedEntry != nil) {
                    fulfill([PMKPromise when:cachedEntry]);
                } else {
                    fulfill([self downloadURL:Assets item:item].then(^(OVCResponse *response, NSError *error) {
                        NSDictionary *result = [[response valueForKey:@"result"] firstObject];
                        NSDictionary *assetDetails = [result valueForKey:@"assets"];
                        
                        NSURL *iconURL = [NSURL URLWithString: [[[assetDetails valueForKey: @"icons"] firstObject] valueForKey: @"url"]];

                        PMKPromise *iconPromise = [NSURLConnection promise: [NSURLRequest requestWithURL:iconURL ]].then(^(NSData *imageData) {
                                                        NSMutableDictionary *iconDict = [[NSMutableDictionary alloc] init];
                                                        [iconDict setObject:imageData forKey:@"icon"];
                                                        [self.sessionManager.cacheManager setObject:iconDict forKey:cacheKey];
                                                        return imageData;
                                                    });

                        NSDictionary *finalAssets = @{ @"icon": iconPromise };
                        return [PMKPromise when:finalAssets];
                    }));
                }
            }];
            break;
        case All:
            // TODO: Handle all download correctly
            return [PMKPromise new];
            break;
        default:
            // TODO: Unstub
            return [PMKPromise new];
            break;
    }
}
- (PMKPromise *)downloadIconFromDictionaryWithitem:(NSDictionary *)item {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSString *cacheKey = [NSString stringWithFormat:@"%@%@%ld", [item valueForKey:@"pkg_name"], [item valueForKey:@"pkg_version"], (long)[item valueForKey:@"item_id"]];
        NSDictionary *cachedEntry = [self.sessionManager.cacheManager objectForKey:cacheKey];
        if (cachedEntry != nil || ![[cachedEntry allKeys] count] == 0) {
            fulfill([PMKPromise when:cachedEntry]);
        } else {
            NSDictionary *paramsDict = @{
                                 @"item_ids": @[[item valueForKey:@"iid"]],
                                 @"type": @"assets"
                                 };
            fulfill([self.sessionManager postJSON:@"package/get" data:paramsDict].then(^(OVCResponse *response, NSError *error) {
                NSDictionary *result = [[response valueForKey:@"result"] firstObject];
                NSDictionary *assetDetails = [result valueForKey:@"assets"];
                NSURL *iconURL = [NSURL URLWithString: [[[assetDetails valueForKey: @"icons"] firstObject] valueForKey: @"url"]];

                PMKPromise *iconPromise = [NSURLConnection promise: [NSURLRequest requestWithURL:iconURL ]].then(^(NSData *imageData) {
                                                NSMutableDictionary *iconDict = [[NSMutableDictionary alloc] init];
                                                [iconDict setObject:imageData forKey:@"icon"];
                                                [self.sessionManager.cacheManager setObject:iconDict forKey:cacheKey];
                                                return imageData;
                                            });

                NSDictionary *finalAssets = @{ @"icon": iconPromise };
                return [PMKPromise when:finalAssets];
            }));
        }
    }];
}

@end
