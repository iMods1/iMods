//
//  IMODependencyCalc.h
//  iMods
//
//  Created by Marcus Ferrario on 9/22/15.
//  Copyright (c) 2015 Coolstar, Marcus Ferrario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegExCategories.h"

@interface IMODependencyCalc : NSObject

- (id)init;

- (NSMutableArray *)formattedArrayFromString:(NSString *)debianString;
- (NSMutableDictionary *)isPackage:(NSMutableArray *)possiblePackages inStatus:(NSMutableArray *)statusArray;
- (NSMutableDictionary *)findOnePackageFrom:(NSMutableArray *)possiblePackages OrArray:(NSMutableArray *)statusArray;
- (NSMutableArray *)parseStatusFile:(NSString *)rawStatusFile;
- (NSMutableDictionary *)calculateDependenciesWithStatus:(NSMutableArray *)statusArray andControl:(NSMutableDictionary *)controlObject;
- (NSMutableArray *)validateStatusArray:(NSMutableArray *)statusArray;

@end
