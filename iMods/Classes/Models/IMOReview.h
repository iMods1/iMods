//
//  IMOReview.h
//  iMods
//
//  Created by Ryan Feng on 8/21/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOUser.h"
#import "IMOItem.h"

@interface IMOReview : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSUInteger rid; // Review id
@property (nonatomic, assign, readonly) NSUInteger uid; // User id
@property (nonatomic, assign, readonly) NSUInteger iid; // Item id
@property (nonatomic, assign, readonly) NSUInteger rating;
@property (nonatomic, copy, readonly) NSString* content; // Content of the review
@property (nonatomic, copy, readonly) NSString* title; // Title of the review
@property (nonatomic, copy, readonly) NSString* userFullName;
@property (nonatomic, copy, readonly) NSString* itemDisplayName;

- (BOOL) isEqual:(id)object;
- (void) updateFromModel:(IMOReview*)model;

@end
