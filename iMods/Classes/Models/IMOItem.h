//
//  Item.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface IMOItem : MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, assign, readonly) NSInteger item_id;
@property (nonatomic, assign, readonly) NSInteger category_id;
@property (nonatomic, copy, readonly) NSString * author_id;
@property (nonatomic, copy, readonly) NSString * pkg_name;
@property (nonatomic, copy, readonly) NSString * pkg_version;
@property (nonatomic, copy, readonly) NSString * pkg_assets_path;
@property (nonatomic, copy, readonly) NSString * pkg_signature;
@property (nonatomic, copy, readonly) NSString * pkg_dependencies;
@property (nonatomic, copy, readonly) NSString * display_name;
@property (nonatomic, assign, readonly) float price;
@property (nonatomic, copy, readonly) NSString * summary;
@property (nonatomic, copy, readonly) NSString * desc;
@property (nonatomic, copy, readonly) NSDate * add_date;
@property (nonatomic, copy, readonly) NSDate * last_update_date;

/* Non-JSON data fields */

@end