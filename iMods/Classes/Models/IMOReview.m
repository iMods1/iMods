//
//  IMOReview.m
//  iMods
//
//  Created by Ryan Feng on 8/21/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOReview.h"

@implementation IMOReview

#pragma mark -
#pragma Initialization

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"rid": @"rid",
             @"uid": @"uid",
             @"iid": @"iid",
             @"rating": @"rating",
             @"content": @"content",
             @"title": @"title",
             @"userFullName": @"user.fullname",
             @"itemDisplayName": @"item.display_name"
             };
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOReview.class]) {
        return NO;
    }
    return self.rid == ((IMOReview*)object).rid;
}

- (void) updateFromModel:(IMOReview *)model {
    self->_rid = model.rid;
    self->_content = model.content;
    self->_rating = model.rating;
    self->_uid = model.uid;
    self->_iid = model.iid;
    self->_userFullName = model.userFullName;
    self->_itemDisplayName = model.itemDisplayName;
}

@end
