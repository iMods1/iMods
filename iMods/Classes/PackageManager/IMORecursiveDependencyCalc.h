//
//  IMORecursiveDependencyCalc.h
//  iMods
//
//  Created by Marcus Ferrario on 9/22/15.
//  Copyright (c) 2015 Coolstar, Marcus Ferrario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMOItem.h"
#import "IMODownloadManager.h"

@interface IMORecursiveDependencyCalc : NSObject

- (id)init;

- (PMKPromise *)calculateDependenciesRecursivelyWithStatus:(NSString *)statusFile andControl:(IMOItem *)controlPkg;
- (PMKPromise *)dependenciesFromDatabaseWithIds:(NSMutableArray *)packageIDs translate:(BOOL)translate;

@end
