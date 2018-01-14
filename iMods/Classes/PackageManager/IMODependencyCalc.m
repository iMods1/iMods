//
//  IMODependencyCalc.m
//  iMods
//
//  Created by Marcus Ferrario on 9/22/15.
//  Copyright (c) 2015 Coolstar, Marcus Ferrario. All rights reserved.
//

#import "IMODependencyCalc.h"

@implementation IMODependencyCalc

- (id)init {
    self = [super init];
    return self;
}

- (NSMutableArray *)formattedArrayFromString:(NSString *)debianString {
	NSArray *firstRunArray = [debianString componentsSeparatedByString:@", "];
	NSMutableArray *secondRunArray = [[NSMutableArray alloc] init];
	for (NSString *rawPackage in firstRunArray) {
	 	NSArray *possiblePackages = [rawPackage componentsSeparatedByString:@"| "];
	 	[secondRunArray addObject:possiblePackages];
	}

	NSMutableArray *thirdRunArray = [[NSMutableArray alloc] init];
	for (NSMutableArray *rawpossiblePackages in secondRunArray) {
		NSMutableArray *possiblePackages = [[NSMutableArray alloc] init];
	 	for (NSString *rawPackage in rawpossiblePackages) {
	 		NSMutableDictionary *package = [[NSMutableDictionary alloc] init];
	 		NSArray *packageParameters = [RX(@"[(^\\)]") split:rawPackage];
	 		[package setObject:[[packageParameters objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Package"];
	 		[package setObject:[[package objectForKey:@"Package"] stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Package"];
			if ([[package objectForKey:@"Package"] isEqualToString:@""])
				continue;
	 		for (int i = 1; i < [packageParameters count]; i++) { 
	 			NSArray *versionsplit = [RX(@"(>|<|)(=| )( |)") split:[packageParameters objectAtIndex:i]];
	 			if ([versionsplit count] < 2)
	 				continue;
	 			NSString *version = [versionsplit objectAtIndex:1];
	 			BOOL equalTokenSet = NO;
	 			if ([[packageParameters objectAtIndex:i] rangeOfString:@">="].location == 0)
	 				[package setObject:version forKey:@"GreaterOrEqual"];
	 			else if ([[packageParameters objectAtIndex:i] rangeOfString:@">>"].location == 0)
	 				[package setObject:version forKey:@"Greater"];
	 			else if ([[packageParameters objectAtIndex:i] rangeOfString:@"="].location == 0)
	 				equalTokenSet = YES;
	 			if ([[packageParameters objectAtIndex:i] rangeOfString:@"<="].location == 0)
	 				[package setObject:version forKey:@"LessOrEqual"];
	 			else if ([[packageParameters objectAtIndex:i] rangeOfString:@"<<"].location == 0)
	 				[package setObject:version forKey:@"Less"];
	 			else if ((equalTokenSet == YES) && ([[packageParameters objectAtIndex:i] rangeOfString:@"="].location == 0))
	 				[package setObject:version forKey:@"Equal"];
	 		}
	 		[possiblePackages addObject:package];
	 	}
	 	[thirdRunArray addObject:possiblePackages];
	}
	if ([thirdRunArray count] == 1) {
		if ([[thirdRunArray objectAtIndex:0] count] == 0)
			return [[NSMutableArray alloc] init];
	}
	return thirdRunArray;
}

- (NSMutableDictionary *)isPackage:(NSMutableArray *)possiblePackages inStatus:(NSMutableArray *)statusArray {
	for (NSMutableDictionary *statusPackage in statusArray){
		for (NSMutableDictionary *package in possiblePackages){
			if ([[statusPackage objectForKey:@"Package"] isEqualToString:[package objectForKey:@"Package"]]){
				BOOL versionMatches = YES;
				if ([package objectForKey:@"GreaterOrEqual"]){
					if (!([[statusPackage objectForKey:@"Version"] floatValue] >= [[package objectForKey:@"GreaterOrEqual"] floatValue]))
						versionMatches = NO;
				}
				if ([package objectForKey:@"Greater"]){
					if (!([[statusPackage objectForKey:@"Version"] floatValue] > [[package objectForKey:@"Greater"] floatValue]))
						versionMatches = NO;
				}
				if ([package objectForKey:@"Equal"]){
					if (!([[statusPackage objectForKey:@"Version"] floatValue] == [[package objectForKey:@"Equal"] floatValue]))
						versionMatches = NO;
				}
				if ([package objectForKey:@"LessOrEqual"]){
					if (!([[statusPackage objectForKey:@"Version"] floatValue] <= [[package objectForKey:@"LessOrEqual"] floatValue]))
						versionMatches = NO;
				}
				if ([package objectForKey:@"Less"]){
					if (!([[statusPackage objectForKey:@"Version"] floatValue] < [[package objectForKey:@"Less"] floatValue]))
						versionMatches = NO;
				}
				if (versionMatches)
					return package;
			}
		}
	}
	return nil;
}

- (NSMutableDictionary *)findOnePackageFrom:(NSMutableArray *)possiblePackages OrArray:(NSMutableArray *)statusArray {
	while ([possiblePackages count] > 1) {
		for (NSMutableDictionary *statusPackage in statusArray) {
			if ([possiblePackages count] <= 1)
				break;
			int i = 0;
			while (i < [possiblePackages count] - 1) {
				NSMutableDictionary *package = [possiblePackages objectAtIndex:i];
				if ([[statusPackage objectForKey:@"Package"] isEqualToString:[package objectForKey:@"Package"]]) {
					BOOL versionMatches = YES;
					if ([package objectForKey:@"GreaterOrEqual"]) {
						if (!([[statusPackage objectForKey:@"Version"] floatValue] >= [[package objectForKey:@"GreaterOrEqual"] floatValue]))
							versionMatches = NO;
					}
					if ([package objectForKey:@"Greater"]) {
						if (!([[statusPackage objectForKey:@"Version"] floatValue] > [[package objectForKey:@"Greater"] floatValue]))
							versionMatches = NO;
					}
					if ([package objectForKey:@"Equal"]) {
						if (!([[statusPackage objectForKey:@"Version"] floatValue] == [[package objectForKey:@"Equal"] floatValue]))
							versionMatches = NO;
					}
					if ([package objectForKey:@"LessOrEqual"]) {
						if (!([[statusPackage objectForKey:@"Version"] floatValue] <= [[package objectForKey:@"LessOrEqual"] floatValue]))
							versionMatches = NO;
					}
					if ([package objectForKey:@"Less"]) {
						if (!([[statusPackage objectForKey:@"Version"] floatValue] < [[package objectForKey:@"Less"] floatValue]))
							versionMatches = NO;
					}
					if (versionMatches) {
						return [possiblePackages objectAtIndex:i];
					} else {
						[possiblePackages removeObjectAtIndex:i];
						i--;
					}
				}
				i++;
			}
		}
	}
	for (NSMutableDictionary *package in possiblePackages) {
		if (![package isKindOfClass:[NSNull class]])
			return package;
	}
    return [[NSMutableDictionary alloc] init];
}

- (NSMutableArray *)parseStatusFile:(NSString *)rawStatusFile {
	NSMutableArray *packages = [[NSMutableArray alloc] init];
	NSArray *rawPackages = [rawStatusFile componentsSeparatedByString:@"\n\n"];
	for (NSString *rawPackage in rawPackages){
		NSMutableDictionary *package = [[NSMutableDictionary alloc] init];
		NSArray *packageParameters = [rawPackage componentsSeparatedByString:@"\n"];
		for (NSString *parameter in packageParameters){
			if (([parameter rangeOfString:@" "].location == 0) || ([parameter rangeOfString:@"\t"].location == 0))
				continue;
			NSArray *splitParameter = [parameter componentsSeparatedByString:@": "];
			if ([splitParameter count] < 2)
				continue;
			NSString *parameterId = [splitParameter objectAtIndex:0];
			NSString *parameterValue = [splitParameter objectAtIndex:1];
			[package setObject:parameterValue forKey:parameterId];
		}
		if (![package objectForKey:@"Package"])
			continue;
		[package setObject:[[package objectForKey:@"Package"] stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Package"];
		if ([[package objectForKey:@"Package"] isEqualToString:@""])
			continue;
		if (![package objectForKey:@"Version"])
			continue;
		if ([package objectForKey:@"Status"]) {
			if ([[package objectForKey:@"Status"] isEqualToString:@"install ok installed"])
				[packages addObject:package];
		}
	}
	return packages;
}

- (NSMutableArray *)validateStatusArray:(NSMutableArray *)statusArray {
	NSMutableArray *packages = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *package in statusArray){
		if (![package objectForKey:@"Package"])
			continue;
		[package setObject:[[package objectForKey:@"Package"] stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Package"];
		if ([[package objectForKey:@"Package"] isEqualToString:@""])
			continue;
		if (![package objectForKey:@"Version"])
			continue;
		if ([package objectForKey:@"Status"]) {
			if ([[package objectForKey:@"Status"] isEqualToString:@"install ok installed"])
				[packages addObject:package];
		}
	}
	return packages;
}

- (NSMutableDictionary *)calculateDependenciesWithStatus:(NSMutableArray *)statusArray andControl:(NSMutableDictionary *)controlObject {

	NSMutableArray *rawDependencyArray = [self formattedArrayFromString:[controlObject objectForKey:@"Depends"]];
	NSMutableArray *preDependsArray = [self formattedArrayFromString:[controlObject objectForKey:@"Pre-Depends"]];
	NSMutableArray *conflictsArray = [self formattedArrayFromString:[controlObject objectForKey:@"Conflicts"]];

	NSMutableDictionary *output = [[NSMutableDictionary alloc] init];

	[output setObject:[NSNumber numberWithBool:YES] forKey:@"installable"];
	[output setObject:@"" forKey:@"reasonForFailure"];
	[output setObject:[[NSMutableArray alloc] init] forKey:@"Dependencies"];

	BOOL reasonForFailureNoPredepends = NO;
	BOOL reasonForFailureConflicts = NO;

	NSMutableArray *dependencyArray = [[NSMutableArray alloc] init];
	for (NSMutableArray *possiblePackages in rawDependencyArray) {
		NSMutableDictionary *packageOrFailure = [self isPackage:possiblePackages inStatus:statusArray];
		if (packageOrFailure == nil) {
			[dependencyArray addObject:[self findOnePackageFrom:possiblePackages OrArray:statusArray]];
		}
	}

	[output setObject:dependencyArray forKey:@"Dependencies"];

	for (NSMutableArray *possiblePackages in preDependsArray) {
		NSMutableDictionary *packageOrFailure = [self isPackage:possiblePackages inStatus:statusArray];
		if (packageOrFailure == nil) {
			[output setObject:[NSNumber numberWithBool:NO] forKey:@"installable"];
			reasonForFailureNoPredepends = YES;
			if (![output objectForKey:@"preDepends"])
				[output setObject:[[NSMutableArray alloc] init] forKey:@"preDepends"];
			[[output objectForKey:@"preDepends"] addObjectsFromArray:possiblePackages];
		}
	}

	for (NSMutableArray *possiblePackages in conflictsArray) {
		NSMutableDictionary *packageOrFailure = [self isPackage:possiblePackages inStatus:statusArray];
		if (packageOrFailure != nil) {
			[output setObject:[NSNumber numberWithBool:NO] forKey:@"installable"];
			reasonForFailureConflicts = YES;
			if (![output objectForKey:@"Conflicts"])
				[output setObject:[[NSMutableArray alloc] init] forKey:@"Conflicts"];
			[[output objectForKey:@"Conflicts"] addObjectsFromArray:possiblePackages];
		}
	}

	if (reasonForFailureNoPredepends)
		[output setObject:[NSString stringWithFormat:@"%@One or more Predepends isn't installed", [output objectForKey:@"reasonForFailure"]] forKey:@"reasonForFailure"];

	if (reasonForFailureNoPredepends && reasonForFailureConflicts)
		[output setObject:[NSString stringWithFormat:@"%@, and ", [output objectForKey:@"reasonForFailure"]] forKey:@"reasonForFailure"];

	if (reasonForFailureConflicts)
		[output setObject:[NSString stringWithFormat:@"%@one or more packages installed conflicts", [output objectForKey:@"reasonForFailure"]] forKey:@"reasonForFailure"];

	if (reasonForFailureNoPredepends || reasonForFailureConflicts)
		[output setObject:[NSString stringWithFormat:@"%@.", [output objectForKey:@"reasonForFailure"]] forKey:@"reasonForFailure"];
	return output;
}

@end
