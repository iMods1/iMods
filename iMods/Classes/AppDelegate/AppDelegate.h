//
//  AppDelegate.h
//  iMods
//
//  Created by Ryan Feng on 9/22/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMOSessionManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;
@property (strong, nonatomic) IMOSessionManager* sharedSessionManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, nonatomic) BOOL isRunningTest;

@end
