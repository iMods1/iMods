//
//  IMOPackageManager.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <objc/runtime.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "IMORecursiveDependencyCalc.h"
#import "IMODependencyCalc.h"
#import "IMOPackageManager.h"
#import <UIKit/UIKit.h>
#import "IMOItem.h"
#include <iostream>
#import "xpc.h"
#import "IMOSessionManager.h"
#import "GUAAlertView.h"

@interface IMOPackageManager ()

@property (readonly, assign) BOOL locked;

@end

@implementation IMOPackageManager;

static IMOPackageManager* sharedIMOPackageManager = nil;
static IMOSessionManager* sessionManager = nil;
static IMORecursiveDependencyCalc* dependencyCalc = nil;
static NSMutableArray *installedDebPaths = nil;

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
        sessionManager = [IMOSessionManager sharedSessionManager];
        dependencyCalc = [[IMORecursiveDependencyCalc alloc] init];
        self->_dpkgManager = [[IMODPKGManager alloc] initWithDPKGPath:@"/usr/bin/dpkg"];
        self.dpkgManager.lockFilePath = @"/var/lib/dpkg/lock";
        self->_taskStderrPipe = [[NSPipe alloc] init];
        self->_taskStdoutPipe = [[NSPipe alloc] init];
        self->_lastInstallNeedsRespring = NO;
        self.targetBundles = [NSMutableArray new];
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

//-------All perfect until HERE!-------\\

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

- (PMKPromise*) installPackage:(IMOItem*)pkg progressCallback:(void(^)(float progress))progressCallback {
    installedDebPaths = [[NSMutableArray alloc] init];
    __block NSError* error = nil;
    [self writeLog:@"Synchronizing database..."];
    progressCallback(0.1);
    
    if (self->_locked) {
        [self writeLog:@"Package manager is currently locked, please wait for it to finish."];
        NSString *translationBundle = [[NSBundle mainBundle] pathForResource:@"Translations" ofType:@"bundle"];
        NSBundle *ourBundle = [[NSBundle alloc] initWithPath:translationBundle];
        NSString *pLocked = NSLocalizedStringFromTableInBundle(@"Package manager is currently locked, please wait for it to finish.", nil, ourBundle, nil);
        NSString *ok = NSLocalizedStringFromTableInBundle(@"OK", nil, ourBundle, nil);
        NSString *errorStr = NSLocalizedStringFromTableInBundle(@"Error", nil, ourBundle, nil);
        GUAAlertView *errorAlert = [GUAAlertView alertViewWithTitle:errorStr
            message:pLocked
            buttonTitle:ok
           buttonTouchedAction:^{
               NSLog(@"button touched");
           } dismissAction:^{
               NSLog(@"dismiss");
           }
           buttons: FALSE];
    
        [errorAlert show];
        
        error = [NSError errorWithDomain:@"PackageManagerLocked" code:2 userInfo:nil];
        NSLog(@"%@", error.localizedDescription);
    }
    
    self->_locked = true;
    
    progressCallback(0.3);
    
#if TARGET_IPHONE_SIMULATOR
    NSString *statusFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"status" ofType:@"txt"]
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
#else
    NSString *statusFile = [NSString stringWithContentsOfFile:@"/var/lib/dpkg/status"
                                                     encoding:NSUTF8StringEncoding
                                                        error:NULL];
#endif
    return [dependencyCalc calculateDependenciesRecursivelyWithStatus:statusFile andControl:pkg]
    .then(^id(NSMutableDictionary* dependencyStatus) {
        if (error != nil) {
            self->_locked = false;
            return error;
        }
        [self writeLog:@"Analyzing package dependecies..."];
        
        if ([[dependencyStatus objectForKey:@"installable"] boolValue] == NO) {
            NSString *translationBundle = [[NSBundle mainBundle] pathForResource:@"Translations" ofType:@"bundle"];
            NSBundle *ourBundle = [[NSBundle alloc] initWithPath:translationBundle];
            NSString *problem = NSLocalizedStringFromTableInBundle([dependencyStatus objectForKey:@"reasonForFailure"], nil, ourBundle, nil);
            [self writeLog:problem];
            
            NSString *ok = NSLocalizedStringFromTableInBundle(@"OK", nil, ourBundle, nil);
            NSString *errorStr = NSLocalizedStringFromTableInBundle(@"Error", nil, ourBundle, nil);

            GUAAlertView *errorAlert = [GUAAlertView alertViewWithTitle:errorStr
            message:problem
            buttonTitle:ok
           buttonTouchedAction:^{
               NSLog(@"button touched");
           } dismissAction:^{
               NSLog(@"dismiss");
           }
           buttons: FALSE];
            [errorAlert show];
            error = [NSError errorWithDomain:@"BrokenPackages" code:1 userInfo:nil];
            self->_locked = false;
            return error;
        }
        
        // Download each package and install
        IMODownloadManager* dlManager = [IMODownloadManager sharedDownloadManager];
        __block PMKPromise* installPromise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject){
            fulfill(nil);
        }];
        
        NSMutableArray *pkgArr = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *dep in [dependencyStatus objectForKey:@"Dependencies"]) {
            [pkgArr addObject:[dep objectForKey:@"Package"]];
        }
        [pkgArr addObject:pkg.pkg_name];

        return [self fetchDepsFromDB:pkgArr]
        .then(^id(NSMutableArray *dependenciesToInstall) {
            __block float numb = 0.3;
            for (NSDictionary *instpkg in dependenciesToInstall) {
                NSUInteger count = [dependenciesToInstall count];
                NSError* item_error = nil;
                IMOItem* item = [MTLJSONAdapter modelOfClass:IMOItem.class fromJSONDictionary:instpkg error:&item_error];
                if (item_error || !item) {
                    [self writeErr:@"Failed to create IMOItem model for version"];
                    self->_locked = false;
                    return item_error;
                }
                numb += 0.1/count;
                progressCallback(numb);
                // Download and install
                [self writeLog:@"Downloading package '%@'...", item.pkg_name];
                installPromise = installPromise.then(^(){
                    PMKPromise* dlPromise = [dlManager download:Deb item:item]
                    .then(^id(NSString* debFilePath) {
                        NSLog(@"Download completed.");
                        [installedDebPaths addObject:debFilePath];
                        [self writeLog:@"Download completed."];
                        
                        numb += 0.3/count;
                        progressCallback(numb);
                        NSString* installTask = [self.dpkgManager installDEB:debFilePath];
                        // Install deb
                        NSLog(@"Installing package '%@'...", item.pkg_name);
                        [self writeLog:@"Installing package '%@'...", item.pkg_name];
                        [self writeLog:installTask];
                        numb += 0.3/count;
                        progressCallback(numb);
                        return nil;
                    });
                    return dlPromise;
                });
            }
            self->_locked = false;
            return nil;
        }).then(^() {
            return [self processTweaks:installPromise].then(^() {
                [sessionManager.userManager refreshInstalled];
            });
        });
    });
}

- (NSArray *)codeInjectedPlistsForPkg:(NSString *)pkgPath {
    NSString *debContents = [self.dpkgManager listDEBFiles:pkgPath];
    NSArray *files = [debContents componentsSeparatedByString:@"\n"];
    NSMutableArray *codeInjectedPlists = [NSMutableArray new];
    for (NSString *file in files) {
        if ([file containsString:@".plist"]) {
            if ([file containsString:@"/Library/MobileSubstrate/DynamicLibraries/"] || [file containsString:@"/Library/Substitute/DynamicLibraries/"]) {
                NSRange range = [file rangeOfString:@"/Library/"];
                NSString *properFile = [file substringFromIndex:range.location];
                [codeInjectedPlists addObject:properFile];
            }
        }
    }
    return codeInjectedPlists;
}

- (PMKPromise*) processTweaks:(PMKPromise*)promise {
    return promise.then(^{
        for (NSString *tweak in installedDebPaths) {
            NSArray *injectedPlists = [self codeInjectedPlistsForPkg:tweak];
            if ([self lastInstallNeedsRespring] == FALSE) {
                for (NSString *plistPath in injectedPlists) {
                    BOOL rNeeded = [self isSBTargetedOnPlist:plistPath];
                    if (rNeeded == TRUE) {
                        self->_lastInstallNeedsRespring = TRUE;
                        break;
                    }
                }
            } else {
                self->_lastInstallNeedsRespring = TRUE;
            }
            NSError *errorInst;
            [[NSFileManager defaultManager] removeItemAtPath:tweak error:&errorInst];
            if (errorInst) {
                NSLog(@"%@", [errorInst localizedDescription]);
            }
        }
    });
}

- (id) cleanPackage:(NSString*)pkg_name {
    return [self.dpkgManager cleanPackage:pkg_name];
}

- (id) removePackage:(NSString*)pkg_name {
    return [self.dpkgManager removePackage:pkg_name];
}

- (BOOL) compareLatestVersion:(NSString*)latest toLastVersion:(NSString*)last {
    if ([latest isEqualToString:last]) {
        return NO;
    }
    NSArray *latestSections = [latest componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"~.-:"]];
    NSArray *lastSections = [last componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"~.-:"]];
    NSUInteger index = 0;
    for (NSString *integer in latestSections) {
        if (([lastSections count] < index+1 && [integer intValue] > 0) || [integer intValue] > [lastSections[index] intValue]) {
            return YES;
        }
        index++;
    }
    return NO;
}

- (PMKPromise*) checkUpdates:(BOOL)install {   
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSArray *installedPackages = sessionManager.userManager.installedItems;
        NSMutableArray *updatedPackages = [NSMutableArray new];
        for (NSDictionary *item in installedPackages) {
            if ([self compareLatestVersion:[item objectForKey: @"pkg_version_latest"] toLastVersion:[item valueForKey: @"pkg_version"]] == YES) {
                [updatedPackages addObject:item];
            }
        }
        fulfill(updatedPackages);
    }];
}

- (PMKPromise*) fetchDepsFromDB:(NSMutableArray *)pkgs {
    return [dependencyCalc dependenciesFromDatabaseWithIds:pkgs translate:NO]
    .then(^(NSMutableArray* deps) {
        return deps;
    });   
}

- (PMKPromise*) installedPkglist {
    IMODependencyCalc * depCalc = [[IMODependencyCalc alloc] init];
    #if TARGET_IPHONE_SIMULATOR
        NSString *installedIndex = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"status" ofType:@"txt"]
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
    #else
        NSString *installedIndex = [NSString stringWithContentsOfFile:@"/var/lib/dpkg/status"
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
    #endif
    NSMutableArray *installedPackages = [depCalc parseStatusFile:installedIndex];
    NSMutableArray *packageIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *versionMap = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary *package in installedPackages) {
        [packageIds addObject:[package objectForKey: @"Package"]];
        [versionMap setObject:[package objectForKey: @"Version"] forKey:[[package objectForKey: @"Package"] lowercaseString]];
    }
    return [self fetchDepsFromDB:packageIds].then(^ (NSMutableArray* packages) {
        for (NSMutableDictionary *package in packages) {
            [package setObject:[package objectForKey: @"pkg_version"] forKey:@"pkg_version_latest"];
            [package setObject:[versionMap objectForKey: [[package objectForKey: @"pkg_name"] lowercaseString]] forKey:@"pkg_version"];
        }
        return packages;
    });
}

- (BOOL) isSBTargetedOnPlist:(NSString *)plistPath{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *filter = [dictionary objectForKey:@"Filter"];
    if ([filter objectForKey:@"Classes"] != nil) {
        return YES;
    }
    NSArray *allTargets = [filter objectForKey:@"Bundles"];
    for (NSString *bundle in allTargets) {
        if (![bundle isEqualToString:@"com.apple.springboard"]) {
            [self.targetBundles addObject:bundle];
        }
        else {
            return YES;
        }
    }
    return NO;
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
    if (self.lastInstallNeedsRespring) {
        self->_lastInstallNeedsRespring = FALSE;
        system("killall SpringBoard");
    }
    else {
        for (NSString *bundle in self.targetBundles) {
            NSDictionary *target = [allProcesses objectForKey:bundle];
            if (target != nil) {
                NSString *process = [NSString stringWithFormat:@"kill -9 %@", [target objectForKey:@"pid"]];
                const char *cProcess = [process cStringUsingEncoding:NSASCIIStringEncoding];
                system(cProcess);
            }
        }
        self.targetBundles = [NSMutableArray new];
    }
}

// Return a list of item IDs
- (NSArray*) listInstalledPackages {
    //solver.allPackages()
    NSMutableArray* result = [[NSMutableArray alloc] init];
    return result;
}

@end