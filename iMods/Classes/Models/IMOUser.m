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
NSMutableArray *billing_infos;
// For security reason, we don't store registered devices information on client-side.

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uid": @"uid",
             @"email": @"email",
             @"fullname": @"fullname",
             @"age": @"age",
             @"author_id": @"author_identifier",
             @"role": @"role",
             //@"billing_infos": NSNull.null
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

- (NSArray*) listBillingInfo {
    return [NSArray arrayWithArray:billing_infos];
}

- (IMOBillingInfo*) billingInfoAtIndex:(NSUInteger)index {
    return [billing_infos objectAtIndex:index];
}

- (void) updateBillingInfoAtIndex:(NSUInteger)index billing:(IMOBillingInfo *)billing {
    [billing_infos replaceObjectAtIndex:index withObject:billing];
}

- (void) setBillingInfo:(NSArray *)billingInfoArray {
    [billing_infos setArray:billingInfoArray];
}

- (void) addBillingInfo:(IMOBillingInfo*)billing {
    [billing_infos addObject:billing];
}

@end