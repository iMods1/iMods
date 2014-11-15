//
//  UIView+IMOAnimation.h
//  iMods
//
//  Created by Brendon Roberto on 11/15/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMOAnimationBlock)(UIView *);
static NSString *const IMOAnimationDurationKey = @"IMOAnimationDurationKey";
static NSString *const IMOAnimationCurveKey = @"IMOAnimationTimingKey";
static NSString *const IMOAnimationDelayKey = @"IMOAnimationDelayKey";
static NSString *const IMOAnimationIDKey = @"IMOAnimationIDKey";
static NSString *const IMOAnimationContextKey = @"IMOAnimationContextKey";

@interface UIView(IMOAnimation)
- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options;
- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options completion:(void(^)(void))completion;
@end
