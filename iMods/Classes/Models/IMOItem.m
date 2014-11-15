//
//  Item.m
//  iMods
//
//  Created by Ryan Feng on 7/17/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSDictionary+MTLManipulationAdditions.h>
#import "IMOItem.h"
#import "IMOReview.h"

@implementation IMOItem

- (instancetype) initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSArray* reviews = [dictionaryValue valueForKey:@"reviews"];
    NSUInteger totalRating = 0;
    for(IMOReview* rev in reviews) {
        totalRating += rev.rating;
    }
    NSUInteger count = [reviews count] || 1;
    float finalRating = (float)totalRating/count;
    
    NSMutableDictionary* defaults = [NSMutableDictionary dictionaryWithDictionary:
                            @{ @"rating": @(finalRating)
                               }];
    return [super initWithDictionary:[defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue] error:error];
}

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"item_id": @"iid",
             @"category_id": @"category_id",
             @"author_id": @"author_id",
             @"pkg_name": @"pkg_name",
             @"pkg_version": @"pkg_version",
             @"pkg_assets_path": @"pkg_assets_path",
             @"pkg_signature": @"pkg_signature",
             @"pkg_dependencies": @"pkg_dependencies",
             @"display_name": @"display_name",
             @"price": @"price",
             @"summary": @"summary",
             @"desc": @"description",
             @"add_date": @"add_date",
             @"last_update_date": @"last_update_date",
             @"reviews": @"reviews",
             @"rating": @"rating"
             };
}

+ (NSDateFormatter*) dateFormatter{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    return dateFormatter;
}

+ (NSValueTransformer*) addDateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString* str) {
        return [self.dateFormatter dateFromString:str];
    }reverseBlock:^(NSDate* date){
        return [self.dateFormatter stringFromDate:date];
    }];
}

- (BOOL) isEqual:(id)object {
    if (![object isKindOfClass:IMOItem.class]) {
        return NO;
    }
    return ((IMOItem*)object).item_id == self.item_id;
}

- (void) updateFromModel:(IMOItem*)model{
    self->_add_date = model.add_date;
    self->_author_id = model.author_id;
    self->_category_id = model.category_id;
    self->_desc = model.desc;
    self->_display_name = model.display_name;
    self->_item_id = model.item_id;
    self->_last_update_date = model.last_update_date;
    self->_pkg_assets_path = model.pkg_assets_path;
    self->_pkg_dependencies = model.pkg_dependencies;
    self->_pkg_name = model.pkg_name;
    self->_pkg_signature = model.pkg_signature;
    self->_pkg_version = model.pkg_version;
    self->_price = model.price;
    self->_summary = model.summary;
    // Don't update reviews, because the response won't contain reviews by default.
}

@end