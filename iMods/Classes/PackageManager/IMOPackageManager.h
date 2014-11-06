//
//  IMOPackageManager.h
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMOItem.h"
#import "IMOTask.h"
#import "IMODPKGManager.h"
#import "IMODownloadManager.h"

@interface IMOPackageManager : NSObject

@property (readonly) IMODPKGManager* dpkgManager;
@property (readonly) NSString* indexFilePath;
@property (readonly, strong) NSPipe* taskStdoutPipe;
@property (readonly, strong) NSPipe* taskStderrPipe;

+ (IMOPackageManager*) sharedPackageManager;

- (BOOL) lockDPKG;

- (BOOL) unlockDPKG;

- (PMKPromise*) fetchIndexFile;

- (PMKPromise*) installPackage:(IMOItem*)pkg progressCallback:(void(^)(float progress))progressCallback;

- (PMKPromise*) removePackage:(NSString*) pkg_name;

- (PMKPromise*) cleanPackage:(NSString*) pkg_name;

- (PMKPromise*) checkUpdates:(BOOL)install;

- (void) respring;

// Since iMods share the same dpkg cache with Cydia and other marketplace apps
// It's better to track installed packages in iMods rather than use dpkg
//- (PMKPromise*) listInstalledPackages;

@end
