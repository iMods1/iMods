//
//  User.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMOUser.h"

@implementation IMOUser

// TODO: Only store last 4 digits of credit card number.

// For security reason, we don't store registered devices information on client-side.

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uid": @"uid",
             @"email": @"email",
             @"fullname": @"fullname",
             @"age": @"age",
             @"author_id": @"author_identifier",
             @"role": @"role",
             };
}

- (id)init:(NSInteger)uid email:(NSString *)email role:(UserRole)role fullname:(NSString *)fullname age:(NSInteger)age author:(NSString *)author_id {
    self = [super init];
    if(self == nil) return nil;
    
    self->_uid = uid;
    self->_email = email;
    self->_role = role;
    self->_fullname = fullname;
    self->_author_id = author_id;
    
    return self;
}

- (BOOL) isEqual:(id)object {
    if(![object isKindOfClass:IMOUser.class]){
        return NO;
    }
    return ((IMOUser*)object).uid == self.uid;
}

@end