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
@property (nonatomic, assign, readonly) NSInteger uid;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, assign, readonly) UserRole role;
@property (nonatomic, copy, readonly) NSString *fullname;
@property (nonatomic, assign, readonly) NSInteger age;
@property (nonatomic, copy, readonly) NSString *author_id;
/* Non-JSON fields */
- (id) init:(NSInteger)uid email:(NSString*)email role:(UserRole)role fullname:(NSString*)fullname age:(NSInteger)age author:(NSString*)author_id;

@end