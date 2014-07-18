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
#include <Mantle/MTLModel.h>
#include <Mantle/MTLJSONAdapter.h>

@interface IMOItem : MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, copy, readonly) NSNumber * item_id;
@property (nonatomic, copy, readonly) NSNumber * category_id;
@property (nonatomic, copy, readonly) NSString * author_id;
@property (nonatomic, copy, readonly) NSString * pkg_name;
@property (nonatomic, copy, readonly) NSString * pkg_version;
@property (nonatomic, copy, readonly) NSString * pkg_assets_path;
@property (nonatomic, copy, readonly) NSString * pkg_signature;
@property (nonatomic, copy, readonly) NSString * pkg_dependencies;
@property (nonatomic, copy, readonly) NSString * display_name;
@property (nonatomic, assign, readonly) float price;
@property (nonatomic, copy, readonly) NSString * summary;
@property (nonatomic, copy, readonly) NSString * description;
@property (nonatomic, copy, readonly) NSDate * add_date;
@property (nonatomic, copy, readonly) NSDate * last_update_date;

/* Non-JSON data fields */

@end

@implementation IMOItem

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"iid": @"item_id",
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
             @"description": @"description",
             @"add_date": @"add_date",
             @"last_update_date": @"last_update_date"
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

@end