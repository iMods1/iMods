//
//  IMOShellCommandTask.m
//  iMods
//
//  Created by Ryan Feng on 8/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOTask.h"

@implementation IMOTask

- (instancetype) initWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments {
    self = [super init];
    if (self) {
        [self setLaunchPath:path];
        [self setArguments:arguments];
        [self setEnvironment:nil];
        self.accumulatesStandardError = YES;
        self.accumulatesStandardOutput = YES;
    }
    return self;
}

+ (PMKPromise*) launchTask:(NSString *)path arguments:(NSArray *)arguments {
    return [IMOTask launchTaskWithEnvironment:path arguments:arguments environment:nil];
}

+ (PMKPromise*) launchTaskWithEnvironment:(NSString *)path arguments:(NSArray *)arguments environment:(NSDictionary*)environment {
    PMKPromise* promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject){
        IMOTask* task = [[IMOTask alloc] init];
        [task setLaunchPath:path];
        [task setArguments:arguments];
        [task setEnvironment:environment];
        task.accumulatesStandardError = YES;
        task.accumulatesStandardOutput = YES;
        [task setSuccessfulTerminationBlock:^(PRHTask* task){
            fulfill(task);
        }];
        [task setAbnormalTerminationBlock:^(PRHTask* task) {
            NSDictionary* errorInfo = @{
                                        @"exitcode": @(task.terminationStatus),
                                        @"path": task.launchPath,
                                        @"arguments": task.arguments,
                                        @"stdout": task.outputStringFromStandardOutputUTF8,
                                        @"stderr": task.errorOutputStringFromStandardErrorUTF8
                                        };
            reject([NSError errorWithDomain:@"IMOTaskExitedAbnormally" code:task.terminationStatus userInfo:errorInfo]);
        }];
        [task launch];
    }];
    return promise;
}

- (id)init {
    self = [super init];
    if (self) {
        return self;
    } else {
        return nil;
    }
}

@end
