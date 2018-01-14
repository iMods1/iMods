//
//  IMORecursiveDependencyCalc.m
//  iMods
//
//  Created by Marcus Ferrario on 9/22/15.
//  Copyright (c) 2015 Coolstar, Marcus Ferrario. All rights reserved.
//

#import "IMORecursiveDependencyCalc.h"
#import "IMODependencyCalc.h"
#import <PromiseKit.h>
#import <Promise+When.h>
#import <Foundation/Foundation.h>
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@interface NSURLRequest (DummyInterface)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
			   (CFStringRef)self,
			   NULL,
			   (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
			   CFStringConvertNSStringEncodingToEncoding(encoding));
}
@end

@implementation IMORecursiveDependencyCalc

- (id)init {
    self = [super init];
    return self;
}

- (NSMutableDictionary *)translate:(NSMutableDictionary *)package {
	NSMutableDictionary *pkg = [[NSMutableDictionary alloc] init];
	if (![[package objectForKey:@"pkg_version"] length])
		[pkg setObject:@"" forKey:@"Version"];
	else
		[pkg setObject:[package objectForKey:@"pkg_version"] forKey:@"Version"];
	if (![[package objectForKey:@"pkg_name"] length])
		[pkg setObject:@"" forKey:@"Package"];
	else
		[pkg setObject:[package objectForKey:@"pkg_name"] forKey:@"Package"];
	if (![[package objectForKey:@"pkg_dependencies"] length])
		[pkg setObject:@"" forKey:@"Depends"];
	else
		[pkg setObject:[package objectForKey:@"pkg_dependencies"] forKey:@"Depends"];
	if (![[package objectForKey:@"pkg_conflicts"] length])
		[pkg setObject:@"" forKey:@"Conflicts"];
	else
		[pkg setObject:[package objectForKey:@"pkg_conflicts"] forKey:@"Conflicts"];
	if (![[package objectForKey:@"pkg_predepends"] length])
		[pkg setObject:@"" forKey:@"Pre-Depends"];
	else
		[pkg setObject:[package objectForKey:@"pkg_predepends"] forKey:@"Pre-Depends"];
	[pkg setObject:@"install ok installed" forKey:@"Status"];
	return pkg;
}

- (NSMutableDictionary *)translateIMOItem:(IMOItem *)package {
	NSMutableDictionary *pkg = [[NSMutableDictionary alloc] init];
	if (!package.pkg_version.length)
		[pkg setObject:@"" forKey:@"Version"];
	else
		[pkg setObject:package.pkg_version forKey:@"Version"];
	if (!package.pkg_name.length)
		[pkg setObject:@"" forKey:@"Package"];
	else
		[pkg setObject:package.pkg_name forKey:@"Package"];
	if (!package.pkg_dependencies.length)
		[pkg setObject:@"" forKey:@"Depends"];
	else
		[pkg setObject:package.pkg_dependencies forKey:@"Depends"];
	if (!package.pkg_conflicts.length)
		[pkg setObject:@"" forKey:@"Conflicts"];
	else
		[pkg setObject:package.pkg_conflicts forKey:@"Conflicts"];
	if (!package.pkg_predepends.length)
		[pkg setObject:@"" forKey:@"Pre-Depends"];
	else
		[pkg setObject:package.pkg_predepends forKey:@"Pre-Depends"];
	return pkg;
}

- (NSMutableArray *)madependenciesFromDatabaseWithIds:(NSMutableArray *)packageIDs translate:(BOOL)translate {
	if ([packageIDs count] > 0) {
        NSArray *requests = [self extendRequestToURLSWithQuery:packageIDs];
        NSMutableArray *globalDeps = [[NSMutableArray alloc] init];
        for (NSURL *address in requests) {
            [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[address host]];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:address];
            NSURLResponse * response = nil;
            NSError *error = nil;
            NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
            if (data == nil) {
                return nil;
            }
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil) {
                return nil;
            }
            NSMutableArray *deps = [json mutableCopy];
            if (translate == YES) {
                for (int i = 0; i < [deps count]; i++) {
                    NSMutableDictionary *dep = [deps objectAtIndex:i];
                    [deps replaceObjectAtIndex:i withObject:[self translate:dep]];
                }
            }
            [globalDeps addObjectsFromArray:deps];
        }
        return globalDeps;
    } else {
        return [[NSMutableArray alloc] init];
    }
}

- (NSArray *)extendRequestToURLSWithQuery:(NSMutableArray *)packageIDs {
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    NSMutableArray *request = [[NSMutableArray alloc] init];
    int i = 0;
    int x = 0;
    for (NSString * pkgId in packageIDs) {
        [request addObject:pkgId];
        if (i == 59 || (x + 1) == [packageIDs count]) {
            i = 0;
            [requests addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://developer.imods.co/api/item/pkgs/%@", [[request componentsJoinedByString:@","] urlEncodeUsingEncoding:NSUTF8StringEncoding]]]];
            request = [[NSMutableArray alloc] init];
        }
        i++;
        x++;
    }
    //switch to uploading a file rather than sending a query in 1.0.2
    return requests;
}

- (PMKPromise *)dependenciesFromDatabaseWithIds:(NSMutableArray *)packageIDs translate:(BOOL)translate {
    if (packageIDs.count > 0) {
        NSArray *requests = [self extendRequestToURLSWithQuery:packageIDs];
        PMKPromise * urlPromise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
            fulfill([[NSMutableArray alloc] init]);
        }];
        NSMutableArray *globalDeps = [[NSMutableArray alloc] init];
        for (NSURL *address in requests) {
        	urlPromise = urlPromise.then(^() {
                [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[address host]];
		       	return [NSURLConnection promise:[NSURLRequest requestWithURL: address]].then(^id(NSArray *json) {
		            if (json == nil) {
		            	return [[NSMutableArray alloc] init];
		            }
		            NSMutableArray *deps = [json mutableCopy];
		            if (translate == YES) {
		                for (int i = 0; i < [deps count]; i++) {
		                    NSMutableDictionary *dep = [deps objectAtIndex:i];
		                    [deps replaceObjectAtIndex:i withObject:[self translate:dep]];
		                }
		            }
		            return deps;
		        }).then(^(NSMutableArray *deps) {
		        	[globalDeps addObjectsFromArray:deps];
		        });
        	});
        }
        return urlPromise.then(^(NSMutableArray *deps) {
            return globalDeps;
        });

    } else {
	    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
            fulfill([[NSMutableArray alloc] init]);
        }];
    }
}

- (PMKPromise *)calculateDependenciesRecursivelyWithStatus:(NSString *)statusFile andControl:(IMOItem *)controlPkg {
	NSMutableDictionary *controlObject = [self translateIMOItem:controlPkg];

	IMODependencyCalc *dependencyCalc = [[IMODependencyCalc alloc] init];
	 __block BOOL isInstallable = YES;

	statusFile = [statusFile stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	__block NSMutableArray *statusArray = [dependencyCalc parseStatusFile:statusFile];

	NSMutableDictionary *finalOutput = [dependencyCalc calculateDependenciesWithStatus:statusArray andControl:controlObject];
	isInstallable = [[finalOutput objectForKey:@"installable"] boolValue];
	NSMutableArray *ids = [[NSMutableArray alloc] init];
	for (NSMutableDictionary *package in [finalOutput objectForKey:@"Dependencies"]) {
		NSString *id = [package objectForKey:@"Package"];
		[ids addObject:id];
		[controlObject setObject:@"install ok installed" forKey:@"Status"];
	}
    return [self dependenciesFromDatabaseWithIds:ids translate:YES]
    .then(^id(NSMutableArray* deps) {
	[statusArray addObjectsFromArray:deps];
	while (isInstallable) {
        if (![controlObject objectForKey:@"Package"])
            continue;
        if (![controlObject objectForKey:@"Version"])
            continue;
		statusArray = [dependencyCalc validateStatusArray:statusArray];
		NSMutableDictionary *output = [dependencyCalc calculateDependenciesWithStatus:statusArray andControl:controlObject];
		isInstallable = [[output objectForKey:@"installable"] boolValue];
		NSMutableArray *ids = [[NSMutableArray alloc] init];
		if ([[output objectForKey:@"Dependencies"] count] == 0)
			break;
		for (NSMutableDictionary *package in [output objectForKey:@"Dependencies"]) {
			NSString *id = [package objectForKey:@"Package"];
			[ids addObject:id];
			[controlObject setObject:@"install ok installed" forKey:@"Status"];
			[[finalOutput objectForKey:@"Dependencies"] addObject:package];
        }
        NSMutableArray *deps = [self madependenciesFromDatabaseWithIds:ids translate:YES];
        if (deps == nil) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"No data returned" forKey:NSLocalizedDescriptionKey];
            NSError *errorData = [[NSError alloc] initWithDomain:@"Dependency Calculator" code:200 userInfo:details];
            return errorData;
        }
        [statusArray addObjectsFromArray:deps];
	}
	if (!isInstallable)
		[finalOutput setObject:[NSNumber numberWithBool:NO] forKey:@"installable"];

	return finalOutput;
    });
}

@end
