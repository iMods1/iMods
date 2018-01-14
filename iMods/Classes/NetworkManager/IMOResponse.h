//
//  IMOResponse.h
//  iMods
//
//  Created by Ryan Feng on 8/8/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface IMOResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign, readonly) NSInteger status_code;
@property (nonatomic, copy, readonly) NSString* message;
@property (nonatomic, copy, readonly) NSDictionary* payload;

@end
