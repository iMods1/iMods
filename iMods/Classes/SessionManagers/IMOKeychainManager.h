//
//  IMOKeychainManager.h
//  iMods
//
//  Created by Yannis on 9/7/15.
//  Copyright (c) 2015 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMOKeychainManager : NSObject

+(void)addLoginToKeychainForUser:(NSString *)user andPassword:(NSString *)pass;
+(void)removeLoginFromKeychainForUser:(NSString *)user;
+(NSString *)passwordForUser:(NSString *)user;

@end
