//
//  IMODev.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "IMOItem.h"
#import "IMODev.h"

@implementation IMODev

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"fullname": @"fullname",
             @"profile_image_url": @"profile_image_url",
             @"items": @"items",
             @"summary": @"summary",
             @"contact_email": @"contact_email",
             @"twitter": @"twitter"
             };
}

- (id)init:(NSString *)fullname profile_image_url:(NSString *)profile_image_url summary:(NSString *)summary contact_email:(NSString *)contact_email twitter:(NSString *)twitter {
    self = [super init];
    if(self == nil) return nil;
    
    self->_fullname = fullname;
    self->_profile_image_url = profile_image_url;
    self->_summary = summary;
    self->_contact_email = contact_email;
    self->_twitter = twitter;
    
    return self;
}

+ (NSValueTransformer*)itemsJSONTransformer{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:IMOItem.class];
}

- (void) updateFromModel:(IMODev*)model {
    self->_fullname = model.fullname;
    self->_profile_image_url = model.profile_image_url;
    self->_items = model.items;
    self->_summary = model.summary;
    self->_contact_email = model.contact_email;
    self->_twitter = model.twitter;
}

@end