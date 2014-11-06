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

- (IMOTask*) installDEB:(NSString *)debPath {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-i", debPath]];
}

- (IMOTask*) installDEBs:(NSArray *)debPaths {
    NSArray* debs = @[@"-i"];
    NSArray* arguments = [debs arrayByAddingObjectsFromArray:debPaths];
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:arguments];
}


- (IMOTask*) removePackage:(NSString *)pkg_name {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-r", pkg_name]];
}

- (IMOTask*) cleanPackage:(NSString *)pkg_name {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-P", pkg_name]];
}

#pragma mark -

- (IMOTask*) extractDEBInfoAsString:(NSString *)debPath {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-I", debPath]];
}

- (IMOTask*) listDEBFiles:(NSString *)debPath {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-c", debPath]];
}

- (IMOTask*) listInstalledDEBs {
    return [[IMOTask alloc] initWithLaunchPath:self.dpkgPath arguments:@[@"-l"]];
}

- (BOOL) lock {
    if([[NSFileManager defaultManager] fileExistsAtPath:self.lockFilePath]) {
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath:self.lockFilePath error:&error];
    }
    NSString* lockFileContent = @"dpkg is being used by iMods\n";
    [[NSFileManager defaultManager] createFileAtPath:self.lockFilePath
                                            contents:[lockFileContent dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:nil];
    return YES;
}

- (BOOL) unlock {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.lockFilePath]) {
        return NO;
    }
    NSError* error = nil;
    return [[NSFileManager defaultManager] removeItemAtPath:self.lockFilePath error:&error];
}

@end
