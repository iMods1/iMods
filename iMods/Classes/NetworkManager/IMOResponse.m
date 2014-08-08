//
//  IMOResponse.m
//  iMods
//
//  Created by Ryan Feng on 8/8/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOResponse.h"

@implementation IMOResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"status_code": @"status_code",
             @"message": @"message"
             };
}
@end
