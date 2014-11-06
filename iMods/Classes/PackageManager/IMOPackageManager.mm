//
//  IMOPackageManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOPackageManager.h"
#import "IMOItem.h"
#include <iostream>
#include "libimpkg.h"

@interface IMOPackageManager ()

@property (readonly, assign) BOOL locked;

@end

@implementation IMOPackageManager;

static IMOPackageManager* sharedIMOPackageManager = nil;

// A (package_name, tweak_plist) mapping
// The plist file is located at <substrate root dir>/DynamicLibraries/{name}.plist
// For mobilesubstrate the root dir would be ' /Library/MobileSubstrate'
NSArray* tweakArray;

NSFileHandle* logWriter;
NSFileHandle* errWriter;


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
        self.dpkgManager.controlFilePath = @"/var/lib/dpkg/status";
        self.dpkgManager.lockFilePath = @"/var/lib/dpkg/lock";
        self->_taskStderrPipe = [[NSPipe alloc] init];
        self->_taskStdoutPipe = [[NSPipe alloc] init];
        logWriter = [self.taskStdoutPipe fileHandleForWriting];
        errWriter = [self.taskStderrPipe fileHandleForWriting];
    }
    return self;
}

#pragma mark -

- (BOOL)lockDPKG {
    return [self.dpkgManager lock];
}

- (BOOL) unlockDPKG {
    return [self.dpkgManager unlock];
}

#pragma mark -

- (void)writeLog:(NSString*)format, ... {
    va_list vl;
    va_start(vl, format);
    NSString* formatted = [[NSString alloc] initWithFormat:format arguments:vl];
    va_end(vl);
    [logWriter writeData:[[formatted stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)writeErr:(NSString*)format, ... {
    va_list vl;
    va_start(vl, format);
    NSString* formatted = [[NSString alloc] initWithFormat:format arguments:vl];
    va_end(vl);
    [errWriter writeData:[[formatted stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -

- (PMKPromise*) fetchIndexFile {
    return [[IMODownloadManager sharedDownloadManager] downloadIndex]
    .then(^(NSString* filePath) {
        self->_indexFilePath = filePath;
        return filePath;
    });
}

- (PMKPromise*) installPackage:(IMOItem*)pkg progressCallback:(void(^)(float progress))progressCallback {
    [self writeLog:@"Synchronizing package index..."];
    progressCallback(0.1);
    return [self fetchIndexFile]
    .then(^id(NSString* indexFile) {
        __block NSError* error = nil;
        if(indexFile == nil) {
            [self writeErr:@"Failed to download index file."];
            error = [NSError errorWithDomain:@"FailedDownloadIndex" code:1 userInfo:nil];
            return error;
        }
        
        if (self->_locked) {
            [self writeLog:@"Package manager is currently locked, please wait for it to finish."];
            error = [NSError errorWithDomain:@"PackageManagerLocked" code:2 userInfo:nil];
            return error;
        }
        
        self->_locked = true;
        auto dep = std::make_tuple([pkg.pkg_name UTF8String], VER_ANY, "");
        NSLog(@"Trying to install %@ ...", pkg.pkg_name);
        
        progressCallback(0.3);
        
        DepVector deps = {dep};
        DependencySolver solver([indexFile UTF8String], [self.dpkgManager.controlFilePath UTF8String], deps);
        
        [self writeLog:@"Analyzing package dependecy..."];
        
        // Calculate dependencies
        DepVector brokenDeps;
        std::vector<const Version*> resolvedVers;
        int errcode = solver.calcDep(resolvedVers, brokenDeps);
        
        if (!brokenDeps.empty()) {
            [self writeLog:@"Following dependencies cannot be resolved"];
            for(auto d: brokenDeps) {
                [self writeLog:@"%s", depTuplePackageName(d).c_str()];
            }
            error = [NSError errorWithDomain:@"BrokenPackages" code:errcode userInfo:nil];
            return error;
        }
        
        if(errcode != 0) {
            self->_locked = false;
            error = [NSError errorWithDomain:@"DependencySolverFailed" code:errcode userInfo:nil];
            return error;
        }
        
        // Download each package and install
        IMODownloadManager* dlManager = [IMODownloadManager sharedDownloadManager];
        __block PMKPromise* installPromise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject){
            fulfill(nil);
        }];
        for(auto ver: resolvedVers) {
            NSDictionary* itemDict = @{
                                       @"iid": @(ver->itemID()),
                                       @"pkg_name": @(ver->packageName().c_str())
                                       };
            NSError* item_error = nil;
            IMOItem* item = [MTLJSONAdapter modelOfClass:IMOItem.class fromJSONDictionary:itemDict error:&item_error];
            if (item_error || !item) {
                [self writeErr:@"Failed to create IMOItem model for version", ver->version().c_str()];
                self->_locked = false;
                return item_error;
            }
            
            progressCallback(0.4);
            // Download and install
            [self writeLog:@"Downloading package '%@'...", item.pkg_name];
            installPromise = installPromise.then(^(){
                PMKPromise* dlPromise = [dlManager download:Deb item:item]
                .then(^id(NSString* debFilePath) {
                    NSLog(@"Download completed.");
                    [self writeLog:@"Download completed."];
                    
                    progressCallback(0.7);
                    IMOTask* installTask = [self.dpkgManager installDEB:debFilePath];
                    // Install deb
                    NSLog(@"Installing package '%@'...", item.pkg_name);
                    [self writeLog:@"Installing packag '%@'...", item.pkg_name];
                    
                    // Construct a new promise
                    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
                        installTask.successfulTerminationBlock = ^(PRHTask* task) {
                            [self writeLog:task.outputStringFromStandardOutputUTF8];
                            NSLog(@"Package '%@' installed successfully.", item.pkg_name);
                            [self writeLog:@"Package '%@' installed successfully.", item.pkg_name];
                            progressCallback(1.0);
                            [self writeLog:@""];
                            fulfiller(nil);
                            // TODO: Verify deb checksum
                        };
                        installTask.abnormalTerminationBlock = ^(PRHTask* task) {
                            [self writeErr:task.errorOutputStringFromStandardErrorUTF8];
                            [self writeErr:@"Failed to install package '%@':", item.pkg_name];
                            error = [NSError errorWithDomain:@"FailedInstallPackage" code:5 userInfo:nil];
                            NSLog(@"Failed to install package '%@':\n%@", item.pkg_name, task.errorOutputStringFromStandardErrorUTF8);
                            [self writeLog:@""];
                            rejecter(error);
                        };
                        [installTask launch];
                    }];
                });
                return dlPromise;
            });
        }
        self->_locked = false;
        return installPromise;
    });
}

- (PMKPromise*) cleanPackage:(NSString*)pkg_name {
    PMKPromise* promise = [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter reject){
        IMOTask* task = [self.dpkgManager cleanPackage:pkg_name];
        task.abnormalTerminationBlock = ^(PRHTask* task) {
            NSDictionary* errorInfo = @{
                                        @"task": task,
                                        @"terminateStatus": @(task.terminationStatus),
                                        @"path": task.launchPath,
                                        @"arguments": task.arguments,
                                        @"stdout": task.outputStringFromStandardOutputUTF8,
                                        @"stderr": task.errorOutputStringFromStandardErrorUTF8
                                        };
            reject([NSError errorWithDomain:@"IMOTaskExitedAbnormally"
                                       code:task.terminationStatus
                                   userInfo:errorInfo]);
            return;
        };
        task.successfulTerminationBlock = ^(PRHTask* task) {
            fulfiller(task);
        };
        [task launch];
    }];
    return promise;
}

- (PMKPromise*) removePackage:(NSString*)pkg_name {
    PMKPromise* promise = [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter reject){
        IMOTask* task = [self.dpkgManager removePackage:pkg_name];
        task.abnormalTerminationBlock = ^(PRHTask* task) {
            NSDictionary* errorInfo = @{
                                        @"task": task,
                                        @"terminateStatus": @(task.terminationStatus),
                                        @"path": task.launchPath,
                                        @"arguments": task.arguments,
                                        @"stdout": task.outputStringFromStandardOutputUTF8,
                                        @"stderr": task.errorOutputStringFromStandardErrorUTF8
                                        };
            reject([NSError errorWithDomain:@"IMOTaskExitedAbnormally"
                                       code:task.terminationStatus
                                   userInfo:errorInfo]);
        };
        task.successfulTerminationBlock = ^(PRHTask* task) {
            fulfiller(task);
        };
        [task launch];
    }];
    return promise;
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
            DependencySolver solver([indexFile UTF8String], [self.dpkgManager.controlFilePath UTF8String]);
            
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
