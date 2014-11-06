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
                __block NSString *nameString = [[[[response valueForKey:@"result"]  valueForKey: @"pkg_name"] firstObject] stringByAppendingString: @".deb"];
                NSLog(@"nameString: %@", nameString);
                NSURL *url = [[NSURL alloc] initWithString:urlString];
                return [NSURLConnection promise:[NSURLRequest requestWithURL: url]]
                .then(^(NSData *data) {
                    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:@"/"] stringByAppendingString: nameString];
                    [data writeToFile:filePath atomically:YES];
                    return filePath;
                });
            });
            break;
        case Assets:
            return [self downloadURL:type item:item].then(^(OVCResponse *response, NSError *error) {
                NSDictionary *result = [[response valueForKey:@"result"] firstObject];
                NSDictionary *assetDetails = [result valueForKey:@"assets"];
                
                NSURL *iconURL = [NSURL URLWithString: [[[assetDetails valueForKey: @"icons"] firstObject] valueForKey: @"url"]];
                PMKPromise *iconPromise = [NSURLConnection promise: [NSURLRequest requestWithURL:iconURL ]];
                NSURL *screenshotURL = [NSURL URLWithString: [[[assetDetails valueForKey:@"screenshots"] firstObject] valueForKey:@"url"]];
                PMKPromise *screenshotPromise = [NSURLConnection promise:[NSURLRequest requestWithURL: screenshotURL]];
                return [PMKPromise when:@{ @"icon": iconPromise, @"screenshot": screenshotPromise}];
            });
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

- (PMKPromise*)downloadIndex {
    PMKPromise* promise = [self.sessionManager getJSON:@"package/index" parameters:nil]
    .then(^id(OVCResponse *response, NSError *error){
        if (error) {
            NSLog(@"Failed to download index file: %@", error.localizedDescription);
            return nil;
        }
        
        NSDictionary* result = [response valueForKey:@"result"];
        NSString* urlString = [result valueForKey:@"url"];
        NSURL* url = [[NSURL alloc] initWithString:urlString];
        return [NSURLConnection promise:[NSURLRequest requestWithURL: url]].then(^(NSData *data) {
            NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingString:@"/"] stringByAppendingString: @"Packages.gz"];
            NSLog(@"Downloaded index file path: %@", filePath);
            [data writeToFile:filePath atomically:YES];
            return filePath;
        });
    });
    return promise;
}

@end
