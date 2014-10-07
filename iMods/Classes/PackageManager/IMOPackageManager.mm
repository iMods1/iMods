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

// A (package_name, tweak_plist) mapping
// The plist file is located at <substrate root dir>/DynamicLibraries/{name}.plist
// For mobilesubstrate the root dir would be ' /Library/MobileSubstrate'
NSArray* tweakArray;

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

- (BOOL) openCache:(NSString*) path {
    packageCache = new PackageCache([path UTF8String]);
    return packageCache != nullptr;
}

- (BOOL) openIndex:(NSString*) path {
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
//        bool resolved = calcDep(*packageCache, *packageIndex, {targetPkg}, dependencies);
        
//        if (!resolved) {
//            reject([NSError errorWithDomain:@"IMOCannotResolveDependencies" code:0 userInfo:nil]);
//            return;
//        }
//        
//        if (dependencies.empty()) {
//            reject([NSError errorWithDomain:@"IMOZeroDependencies" code:0 userInfo:nil]);
//        }
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

- (BOOL) isSBTargeted {
    // TODO: Check whether SpringBoard is the target bundle
    // Use tweakDictionary to check the plist
    BOOL returnedBool = NO;
    for (NSDictionary *dictionary in tweakArray) {
        NSArray *allTargets = [[dictionary objectForKey:@"Filter"] objectForKey:@"Bundles"];
        for (NSString *bundle in allTargets) {
            if ([bundle isEqualToString:@"com.apple.springboard"]) {
                returnedBool = YES;
            }
        }
    }
    return returnedBool;
}

- (void) respring {
    // TODO: Insert respring code here.
    char file_type[40];
    FILE *fp = popen("ps -ax | grep \"App\"", "r");
    if (fp == NULL) {
        printf("Failed to run command\n" );
    }
    NSString *consoleOutput = @"";
    while (fgets(file_type, sizeof(file_type), fp) != NULL) {
        consoleOutput = [consoleOutput stringByAppendingFormat:@"%s", file_type];
    }
    pclose(fp);
    NSArray *bundleData = [consoleOutput componentsSeparatedByString:@"\n"];
    NSMutableDictionary *allProcesses = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < bundleData.count - 1; i ++) {
        NSString *currentLine = bundleData[i];
        NSArray *largeSeparator = [currentLine componentsSeparatedByString:@"         "];
        NSArray *firstSmallSeparator = [[largeSeparator objectAtIndex:0] componentsSeparatedByString:@" "];
        NSArray *secondSmallSeparator = [[largeSeparator objectAtIndex:1] componentsSeparatedByString:@" "];
        NSString *appLocation = [secondSmallSeparator objectAtIndex:1];
        int found = 0;
        for (int f = 0; f < firstSmallSeparator.count; f++) {
            if (![firstSmallSeparator[f] isEqual:@""]) {
                found = f;
            }
        }
        NSString *pid = [firstSmallSeparator objectAtIndex:found-1];
        NSString *appID = [firstSmallSeparator objectAtIndex:found];
        NSString *number = [secondSmallSeparator objectAtIndex:0];
        if ([appLocation rangeOfString:@".app" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            NSString *appContainer = [[[appLocation componentsSeparatedByString:@".app"] objectAtIndex:0] stringByAppendingString:@".app/Info.plist"];
            NSDictionary *appDictionary = [[NSDictionary alloc] initWithContentsOfFile:appContainer];
            appLocation = [appDictionary objectForKey:@"CFBundleIdentifier"];
        }
        NSDictionary *processData = @{@"pid": pid, @"id": appID, @"number":number};
        NSDictionary *entry = @{appLocation: processData};
        [allProcesses addEntriesFromDictionary:entry];
    }
    for (NSDictionary *dictionary in tweakArray) {
        NSArray *allTargets = [[dictionary objectForKey:@"Filter"] objectForKey:@"Bundles"];
        for (NSString *bundle in allTargets) {
            if ([bundle isEqual:@"com.apple.springboard"]) {
                system("killall SpringBoard");
            }
            else {
                NSDictionary *target = [allProcesses objectForKey:bundle];
                if (target != nil) {
                    NSString *process = [NSString stringWithFormat:@"kill -9 %@", [target objectForKey:@"pid"]];
                    const char *cProcess = [process cStringUsingEncoding:NSASCIIStringEncoding];
                    system(cProcess);
                }
            }
            
        }
    }

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
