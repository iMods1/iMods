//
//  Category.h
//  iMods
//
//  Created by Ryan Feng on 7/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface IMOCategory: MTLModel <MTLJSONSerializing>

/* JSON data fields */

@property (nonatomic, assign, readonly) NSInteger cid;
@property (nonatomic, assign, readonly) NSInteger parent_id;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSString * desc;
@property NSArray * children;
@property IMOCategory * parent;

/* Non-JSON data fields */

- (id) init:(NSInteger)cid parent_id:(NSInteger)parent_id name:(NSString*)name description:(NSString*)description;
- (BOOL) isEqual:(id)object;
@end