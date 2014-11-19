//
//  UIViewController+shouldAutorotate.m
//  iMods
//
//  Created by Ryan Feng on 11/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "UIViewControllerNoAutorotate.h"

@implementation UIViewControllerNoAutorotate

- (BOOL)shouldAutorotate {
    NSLog(@"VC shouldAutorotate: %@", self.class);
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end