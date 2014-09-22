//
//  IMODPKGManager.m
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMODPKGManager.h"
#import "IMOTask.h"

@implementation IMODPKGManager

- (instancetype) initWithDPKGPath:(NSString *)dpkgPath {
    self = [super init];
    if (dpkgPath) {
        self->_dpkgPath = dpkgPath;
    }
    return self;
    
}

#pragma mark -

- (PMKPromise*) installDEB:(NSString *)debPath {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-i", debPath]];
}

- (PMKPromise*) installDEBs:(NSArray *)debPaths {
    NSArray* debs = @[@"-i"];
    NSArray* arguments = [debs arrayByAddingObjectsFromArray:debPaths];
    return [IMOTask launchTask:self.dpkgPath arguments:arguments];
}


- (PMKPromise*) removePackage:(NSString *)pkg_name {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-r", pkg_name]];
}

- (PMKPromise*) cleanPackage:(NSString *)pkg_name {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-P", pkg_name]];
}

#pragma mark -

- (PMKPromise*) extractDEBInfoAsString:(NSString *)debPath {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-I", debPath]];
}

- (PMKPromise*) listDEBFiles:(NSString *)debPath {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-c", debPath]];
}

- (PMKPromise*) listInstalledDEBs {
    return [IMOTask launchTask:self.dpkgPath arguments:@[@"-l"]];
}

@end
