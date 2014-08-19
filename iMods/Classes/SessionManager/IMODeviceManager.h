//
//  IMODeviceManager.h
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMODevice.h"

@interface IMODeviceManager : NSObject

@property IMODevice* currentDevice;

- (instancetype) init;
- (void) registerCurrentDevice;


@end
