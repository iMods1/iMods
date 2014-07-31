//
//  IMOConstants.m
//  iMods
//
//  Created by Ryan Feng on 7/30/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOConstants.h"

#ifdef DEBUG
NSString * const BASE_API_ENDPOINT = @"127.0.0.1:8000/api";
#else
NSString * const BASE_API_ENDPOINT = @"https://imods.wunderkind.us/api";
#endif
