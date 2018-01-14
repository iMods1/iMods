//
//  IMODPKGManager.m
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMODPKGManager.h"
#import "IMOSessionManager.h"

@implementation IMODPKGManager
static IMOSessionManager* sessionManager = nil;
- (instancetype) initWithDPKGPath:(NSString *)dpkgPath {
    self = [super init];
    sessionManager = [IMOSessionManager sharedSessionManager];
    if (dpkgPath) {
        self->_dpkgPath = dpkgPath;
    }
    return self;
    
}

#pragma mark -

- (id) installDEB:(NSString *)debPath {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"install", debPath]];
    return result;
}

/*- (id) installDEBs:(NSArray *)debPaths {
    //broken for now
    NSArray* debs = @[@"-i"];
    NSArray* arguments = [debs arrayByAddingObjectsFromArray:debPaths];
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:arguments];
    return result;
}*/

- (id) removePackage:(NSString *)pkg_name {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"uninstall", pkg_name]];
    [sessionManager.userManager refreshInstalled];
    return result;
}

- (id) cleanPackage:(NSString *)pkg_name {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"clean", pkg_name]];
    return result;
}

#pragma mark -

- (id) extractDEBInfoAsString:(NSString *)debPath {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"extract", debPath]];
    return result;
}

- (id) listDEBFiles:(NSString *)debPath {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"list", debPath]];
    return result;
}

- (id) listInstalledDEBs {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"listInstalled"]];
    return result;
}

- (id) listInstalledDEBContents:(NSString *)pkg_name {
    DPKGTask *task = [[DPKGTask alloc] init];
    NSString *result = [task dpkgTaskWithArguments:@[@"listInstalledContents", pkg_name]];
    return result;
}

/*- (id) dpkgControl {
    DPKGTask *task = [[DPKGTask alloc] init];
    return [task controlFile];
}*/

- (BOOL) lock {
    DPKGTask *task = [[DPKGTask alloc] init];
    return [task lockDpkg];
}

- (BOOL) unlock {
    DPKGTask *task = [[DPKGTask alloc] init];
    return [task unlockDpkg];
}

@end
