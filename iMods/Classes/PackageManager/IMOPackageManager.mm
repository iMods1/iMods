//
//  IMOPackageManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOPackageManager.h"
#import "IMODownloadManager.h"
#import "IMOItem.h"
#include <iostream>
#include "libimpkg.h"

@implementation IMOPackageManager;

static IMOPackageManager* sharedIMOPackageManager = nil;

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
        self->_locked = false;
        self->_controlFilePath = @"/var/lib/dpkg/status";
    }
    return self;
}

- (PMKPromise*) fetchIndexFile {
    return [[IMODownloadManager sharedDownloadManager] downloadIndex]
    .then(^(NSString* filePath) {
        self->_indexFilePath = filePath;
        return filePath;
    });
}

- (PMKPromise*) installPackage:(IMOItem*)pkg {
    return [self fetchIndexFile]
    .then(^id(NSString* indexFile) {
        @synchronized(@(self.locked)) {
            if (self->_locked) {
                NSLog(@"Package manager is currently locked, please wait for it to finish.");
                return nil;
            }
            
            self->_locked = true;
            auto dep = std::make_tuple([pkg.pkg_name UTF8String], VER_ANY, "");
            DepVector deps = {dep};
            DependencySolver solver([indexFile UTF8String], [self.controlFilePath UTF8String], deps);
            
            // Calculate dependencies
            DepVector brokenDeps;
            std::vector<const Version*> resolvedVers;
            solver.calcDep(resolvedVers, brokenDeps);
            
            if (!brokenDeps.empty()) {
                for(auto d: brokenDeps) {
                    NSLog(@"Package '%s' cannot be resolved", depTuplePackageName(d).c_str());
                }
                self->_locked = false;
                return nil;
            }
            
            // Build download queue
            NSMutableArray* dlQueue;
            IMODownloadManager* dlManager = [IMODownloadManager sharedDownloadManager];
            for(auto ver: resolvedVers) {
                NSDictionary* itemDict = @{
                                           @"iid": @(ver->itemID()),
                                           @"pkg_name": @(ver->packageName().c_str())
                                           };
                NSError* error = nil;
                IMOItem* item = [MTLJSONAdapter modelOfClass:IMOItem.class fromJSONDictionary:itemDict error:&error];
                if (error || !item) {
                    std::cerr << "Failed to create IMOItem for version '" << *ver << "'" << std::endl;
                    self->_locked = false;
                    return nil;
                }
                [dlQueue addObject:[dlManager download:Deb item:item]];
            }
            // Install deb files using dpkg
            return [PMKPromise when:dlQueue]
            .then(^(NSArray* files) {
                [[self dpkgManager] installDEBs:files];
                self->_locked = false;
                return true;
            });
        }
    });
}

- (PMKPromise*) cleanPackage:(IMOItem *)pkg {
    return [self.dpkgManager cleanPackage:pkg.pkg_name];
}

- (PMKPromise*) removePackage:(IMOItem*)pkg {
    return [self.dpkgManager removePackage:pkg.pkg_name];
}

// Return NSArray of updated IMOItem's
- (PMKPromise*) checkUpdates:(BOOL)install {
    return [self fetchIndexFile].then(^id(NSString* indexFile){
        @synchronized(@(self.locked)) {
            if (self->_locked) {
                NSLog(@"Package manager is currently locked, please wait for it to finish.");
                return nil;
            }
            
            self->_locked = true;
            DependencySolver solver([indexFile UTF8String], [self.controlFilePath UTF8String]);
            
            DepVector updates;
            std::vector<const Version*> resolvedVers;
            // Get updates if there's any
            updates = std::move(solver.getUpdates());
            
            // Array of updated IMOItem's
            NSMutableArray* updatedItems;
            
            if (updates.empty()) {
                self->_locked = false;
                return updatedItems;
            }
            
            for(auto dep: updates) {
                NSString* pkg_name = [[NSString alloc] initWithUTF8String:depTuplePackageName(dep).c_str()];
                NSDictionary* itemDict = @{
                                           @"pkg_name": pkg_name
                                           };
                NSError* error = nil;
                IMOItem* item = [MTLJSONAdapter modelOfClass:IMOItem.class fromJSONDictionary:itemDict error:&error];
                if (error || !item) {
                    std::cerr << "Failed to create IMOItem for package '" << pkg_name << "'" << std::endl;
                    self->_locked = false;
                    return nil;
                }
                [updatedItems addObject:item];
            }
            self->_locked = false;
            return [NSArray arrayWithArray:updatedItems];
        }
    });
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
    return result;
}

@end
