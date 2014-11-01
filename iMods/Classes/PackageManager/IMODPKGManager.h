//
//  IMODPKGManager.h
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOTask.h"

@interface IMODPKGManager : NSObject

@property (strong, nonatomic, readonly) NSString* dpkgPath;
@property NSString* controlFilePath;
@property NSString* lockFilePath;
@property NSString* dpkgVersion;


#pragma mark -

- (instancetype) initWithDPKGPath:(NSString*)dpkgPath;

- (IMOTask*) installDEB:(NSString*)debPath;

- (IMOTask*) installDEBs:(NSArray*)debPaths;

- (IMOTask*) removePackage:(NSString*)pkg_name;

- (IMOTask*) cleanPackage:(NSString*)pkg_name;

- (IMOTask*) extractDEBInfoAsString:(NSString*)debPath;

- (BOOL) lock;

- (BOOL) unlock;

- (IMOTask*) listDEBFiles:(NSString*)debPath;

- (IMOTask*) listInstalledDEBs;

@end
