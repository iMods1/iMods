//
//  IMOBanner.m
//  iMods
//
//  Created by Ryan Feng on 11/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "IMOBanner.h"

@implementation IMOBanner

+ (NSDictionary*) JSONKeyPathsByPropertyKey {
    return @{
             @"banner_id": @"banner_id",
             @"item_id": @"item_id",
             @"item": @"item",
             @"banner_images": @"banner_imgs"
             };
}

+ (NSValueTransformer*) itemJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:IMOItem.class];
}


- (instancetype) init:(NSInteger)banner_id item_id:(NSInteger)item_id item:(IMOItem*)item {
    self = [super init];
    if (self) {
        self->_banner_id = banner_id;
        self->_item_id = item_id;
        self->_item = item;
    }
    return self;
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOBanner.class]) {
        return NO;
    }
    return ((IMOBanner*)object).banner_id  == self.banner_id;
}

@end