//
//  IMOPackageManager.h
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMOTask.h"
#import "IMODPKGManager.h"

@interface IMOPackageManager : NSObject

@property (readonly) IMODPKGManager* dpkgManager;

+ (IMOPackageManager*) sharedPackageManager;

- (BOOL) openCache:(NSString*) path;

- (BOOL) openIndex:(NSString*) path;

- (PMKPromise*) installPackage:(NSString*) pkg_path;

- (PMKPromise*) removePackage:(NSString*) pkg_name;

- (PMKPromise*) cleanPackage:(NSString*) pkg_name;

- (PMKPromise*) listInstalledPackages;

@end
