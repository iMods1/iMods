//
//  IMODPKGManager.h
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPKGTask.h"

@interface IMODPKGManager : NSObject

@property (strong, nonatomic, readonly) NSString* dpkgPath;
@property NSString* lockFilePath;
@property NSString* dpkgVersion;


#pragma mark -

- (instancetype) initWithDPKGPath:(NSString*)dpkgPath;

- (id) installDEB:(NSString*)debPath;

- (id) installDEBs:(NSArray*)debPaths;

- (id) removePackage:(NSString*)pkg_name;

- (id) cleanPackage:(NSString*)pkg_name;

- (id) extractDEBInfoAsString:(NSString*)debPath;

- (BOOL) lock;

- (BOOL) unlock;

- (id) listDEBFiles:(NSString*)debPath;

- (id) listInstalledDEBContents:(NSString *)pkg_name;

- (id) listInstalledDEBs;

- (id) dpkgControl;

@end
