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
@property NSString* dpkgVersion;


#pragma mark -

- (instancetype) initWithDPKGPath:(NSString*)dpkgPath;

- (PMKPromise*) installDEB:(NSString*)debPath;

- (PMKPromise*) installDEBs:(NSArray*)debPaths;

- (PMKPromise*) removePackage:(NSString*)pkg_name;

- (PMKPromise*) cleanPackage:(NSString*)pkg_name;

- (PMKPromise*) extractDEBInfoAsString:(NSString*)debPath;

- (PMKPromise*) listDEBFiles:(NSString*)debPath;

- (PMKPromise*) listInstalledDEBs;

@end
