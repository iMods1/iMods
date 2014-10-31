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
@property (readonly) NSString* controlFilePath;
@property (readonly, assign) BOOL locked;

+ (IMOPackageManager*) sharedPackageManager;

- (BOOL) lockDPKG;

- (BOOL) unlockDPKG;

- (PMKPromise*) fetchIndexFile;

- (PMKPromise*) installPackage:(IMOItem*) pkg_path;

- (PMKPromise*) removePackage:(IMOItem*) pkg_name;

- (PMKPromise*) cleanPackage:(IMOItem*) pkg_name;

- (PMKPromise*) checkUpdates:(BOOL)install;

- (void) respring;

- (PMKPromise*) listInstalledPackages;

@end
