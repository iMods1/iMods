//
//  IMODev.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOConstants.h"

@interface IMODev : MTLModel <MTLJSONSerializing>

/* JSON fields */
@property (nonatomic, copy, readonly) NSString *fullname;
@property (nonatomic, copy, readonly) NSString *profile_image_url;
@property (nonatomic, copy, readonly) NSString *summary;
@property (nonatomic, copy, readonly) NSString *contact_email;
@property (nonatomic, copy, readonly) NSString *twitter;
@property NSMutableArray* items;

/* Non-JSON fields */
- (id)init:(NSString *)fullname profile_image_url:(NSString *)profile_image_url summary:(NSString *)summary contact_email:(NSString *)contact_email twitter:(NSString *)twitter;
- (void) updateFromModel:(IMODev*)model;

@end