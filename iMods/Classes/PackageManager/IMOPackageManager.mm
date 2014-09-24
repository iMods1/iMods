//
//  IMOPackageManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOPackageManager.h"
#include "libimpkg.h"

@implementation IMOPackageManager

static IMOPackageManager* sharedIMOPackageManager = nil;

+ (IMOPackageManager*) sharedPackageManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedIMOPackageManager = [[IMOPackageManager alloc] init];
    });
    return sharedIMOPackageManager;
}

- (id) init {
    self = [super init];
    if (self) {
        self->_dpkgManager = [[IMODPKGManager alloc] initWithDPKGPath:@"/usr/bin/dpkg"];
    }
    return self;
}

- (PMKPromise*) installPackage:(NSString *)pkg_path {
    // TODO: Send package dependency solution request
    // TODO: Fetch package files
    // TODO: Check package checksums
    // TODO: Install packages
    // TODO: Apply patches
    return nil;
}

- (PMKPromise*) removePackage:(NSString *)pkg_name {
    // TODO: Check dependency
    // TODO: Remove pacakge
    return nil;
}

- (PMKPromise*) cleanPackage:(NSString *)pkg_name {
    // TODO: Clean package configs
    return nil;
}

- (PMKPromise*) listInstalledPackages {
    // TODO: List installed debian pacakges
    // TODO: Construct an array of IMOItem objects
    return nil;
}

@end
