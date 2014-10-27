//
//  IMODownloadManager.m
//  iMods
//
//  Created by Brendon Roberto on 10/27/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMODownloadManager.h"
#import "IMOSessionManager.h"
#import <PromiseKit+Foundation.h>

@interface IMODownloadManager ()
@property (weak, nonatomic) IMOSessionManager *sessionManager;
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
    }
    NSDictionary *paramsDict = @{
                                 @"item_ids": @[@(item.item_id)],
                                 @"type": downloadType
                                 };
    return [self.sessionManager getJSON:@"package/get" parameters:paramsDict];
}

- (PMKPromise *)download:(IMODownloadType)type item:(IMOItem *)item {
    switch (type) {
        case Deb:
            return [self downloadURL:type item:item].then(^(OVCResponse *response, NSError *error) {
                NSString *urlString = [[[[response valueForKey: @"result"] valueForKey: @"items"] firstObject] valueForKey: @"deb_url"];
                NSURL *url = [[NSURL alloc] initWithString:urlString];
                return [NSURLConnection promise:[NSURLRequest requestWithURL: url]];
            });
            break;
        default:
            // TODO: Handle assets and all download correctly
            return [self downloadURL:type item:item];
            break;
    }
}

@end
