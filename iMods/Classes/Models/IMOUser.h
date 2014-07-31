//
//  User.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOBillingInfo.h"
#import "IMOConstants.h"

@interface IMOUser : MTLModel <MTLJSONSerializing>

/* JSON fields */
@property (nonatomic, copy, readonly) NSNumber *uid;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, assign, readonly) UserRole role;
@property (nonatomic, copy, readwrite) NSString *fullname;
@property (nonatomic, copy, readwrite) NSNumber *age;
@property (nonatomic, copy, readonly) NSString *author_id;
//@property (nonatomic, copy, readonly) NSArray *billing_methods;
/* Non-JSON fields */
- (id) init:(NSNumber*)uid email:(NSString*)email role:(UserRole)role fullname:(NSString*)fullname age:(NSNumber*)age author:(NSString*)author_id;

- (void) updateBillingInfo:(NSUInteger)index billing:(IMOBillingInfo*)billing;
- (IMOBillingInfo*) billingInfoAtIndex:(NSUInteger)index;
- (NSArray*) listBillingInfo;
@end