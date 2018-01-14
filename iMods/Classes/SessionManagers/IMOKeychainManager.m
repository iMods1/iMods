//
//  IMOKeychainManager.m
//  iMods
//
//  Created by Yannis on 9/7/15.
//  Copyright (c) 2015 Ryan Feng. All rights reserved.
//

#import "IMOKeychainManager.h"

@implementation IMOKeychainManager

+(void)addLoginToKeychainForUser:(NSString *)user andPassword:(NSString *)pass {
        id group = nil;
        NSString *serviceName = @"com.imods.imodsLogin";
        NSData *dat = [pass dataUsingEncoding:NSUTF8StringEncoding];
        Class ACDKeychain = NSClassFromString(@"ACDKeychain");
        SEL selector = NSSelectorFromString(@"addItemWithServiceName:username:accessGroup:passwordData:options:error:");
        NSMethodSignature *mySignature = [ACDKeychain methodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:mySignature];
        invocation.selector = selector;
        invocation.target = [ACDKeychain class];
        [invocation setArgument:&serviceName atIndex:2];
        [invocation setArgument:&user atIndex:3];
        [invocation setArgument:&group atIndex:4];
        [invocation setArgument:&dat atIndex:5];
        [invocation setArgument:&group atIndex:6];
        [invocation setArgument:&group atIndex:7];
        [invocation invoke];
}

+(void)removeLoginFromKeychainForUser:(NSString *)user {
    id group = nil;
    NSString *serviceName = @"com.imods.imodsLogin";
    Class ACDKeychain = NSClassFromString(@"ACDKeychain");
    SEL selector = NSSelectorFromString(@"removeItemForServiceName:username:accessGroup:error:");
    NSMethodSignature *mySignature = [ACDKeychain methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:mySignature];
    invocation.selector = selector;
    invocation.target = [ACDKeychain class];
    [invocation setArgument:&serviceName atIndex:2];
    [invocation setArgument:&user atIndex:3];
    [invocation setArgument:&group atIndex:4];
    [invocation setArgument:&group atIndex:5];
    [invocation invoke];
}

+(NSString *)passwordForUser:(NSString *)user {
    /*
    id group = nil;
    NSString *serviceName = @"com.imods.imodsLogin";
    Class ACDKeychain = NSClassFromString(@"ACDKeychain");
    SEL selector = NSSelectorFromString(@"passwordForServiceName:username:accessGroup:error:");
    NSMethodSignature *mySignature = [ACDKeychain methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:mySignature];
    invocation.selector = selector;
    invocation.target = [ACDKeychain class];
    [invocation setArgument:&serviceName atIndex:2];
    [invocation setArgument:&user atIndex:3];
    [invocation setArgument:&group atIndex:4];
    [invocation setArgument:&group atIndex:5];
    [invocation invoke];
    NSString *returned = @"";
    [invocation getReturnValue:&returned];
    invocation = nil;

    return returned;*/
    return @"test";
}

@end
