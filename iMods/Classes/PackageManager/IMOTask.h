//
//  IMOShellCommandTask.h
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import <PromiseKit/PromiseKit+Foundation.h>
#import <PRHTask.h>

@interface IMOTask: PRHTask

-(id) init;
+(PMKPromise*) launchTask:(NSString*)path arguments:(NSArray*)arguments;
+(PMKPromise*) launchTaskWithEnvironment:(NSString*)path arguments:(NSArray*)arguments environment:(NSDictionary*)environment;

@end