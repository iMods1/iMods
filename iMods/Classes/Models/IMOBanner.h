//
//  IMOBanners.h
//  iMods
//
//  Created by Ryan Feng on 11/28/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import "IMOItem.h"

@interface IMOBanner: MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSInteger banner_id;
@property (nonatomic, assign, readonly) NSInteger item_id;
@property (nonatomic, copy, readonly) IMOItem* item;
@property (nonatomic, copy, readonly) NSArray* banner_images;

- (instancetype) init:(NSInteger)banner_id item_id:(NSInteger)item_id item:(IMOItem*)item;

- (BOOL) isEqual:(id)object;

@end