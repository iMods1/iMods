//
//  IMOPackageManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOPackageManager.h"
#import "IMOItem.h"
#include "libimpkg.h"

@implementation IMOPackageManager

static IMOPackageManager* sharedIMOPackageManager = nil;

PackageCache* packageCache;
PackageCache* packageIndex;

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

- (BOOL) readCache:(NSString*) path {
    packageCache = new PackageCache([path UTF8String]);
    return packageCache != nullptr;
}

- (BOOL) readIndex:(NSString*) path {
    packageIndex = new PackageCache([path UTF8String]);
    return packageIndex != nullptr;
}

- (BOOL) synchronizeIndex {
    // TODO: Add index file to download queue
    return YES;
}

- (PMKPromise*) installPackage:(NSString *)pkg_name{
    PMKPromise* promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        // Check if it's in the index
        auto pkg = packageCache->package([pkg_name UTF8String]);
        if (pkg != nullptr) {
            reject([NSError errorWithDomain:@"IMOPackageAlreadyInstalled" code:0 userInfo:nil]);
            return;
        }
        
        auto targetPkg = packageIndex->package([pkg_name UTF8String]);
        
        if (targetPkg == nullptr) {
            reject([NSError errorWithDomain:@"IMOPackageNotFound" code:0 userInfo:nil]);
            return;
        }
        
        std::vector<const Package*> dependencies;
        bool resolved = calcDep(*packageCache, *packageIndex, {targetPkg}, dependencies);
        
        if (!resolved) {
            reject([NSError errorWithDomain:@"IMOCannotResolveDependencies" code:0 userInfo:nil]);
            return;
        }
        
        if (dependencies.empty()) {
            reject([NSError errorWithDomain:@"IMOZeroDependencies" code:0 userInfo:nil]);
        }
        // TODO: Send request for package download
    }];
    return promise;
}

- (PMKPromise*) removePackage:(NSString *)pkg_name {
    return [self.dpkgManager removePackage:pkg_name];
}

- (PMKPromise*) cleanPackage:(NSString *)pkg_name {
    return [self.dpkgManager cleanPackage:pkg_name];
}

// Return a list of item IDs
- (NSArray*) listInstalledPackages {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for(auto& pkg: packageCache->allPackages()) {
        auto& verList = pkg.second.ver_list();
        for(auto ver: verList) {
            [result addObject:@(ver->itemID())];
        }
        
    }
    return result;
}

@end
