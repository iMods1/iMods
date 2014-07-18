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

@property (nonatomic, copy, readonly) NSNumber * cid;
@property (nonatomic, copy, readonly) NSNumber * parent_id;
@property (nonatomic, copy, readonly) NSString * name;
@property (nonatomic, copy, readonly) NSString * description;

/* Non-JSON data fields */

- (id) init:(NSNumber*)cid parent:(NSNumber*)parent_id name:(NSString*)name desc:(NSString*) description;
@end