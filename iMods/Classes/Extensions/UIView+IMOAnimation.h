//
//  UIView+IMOAnimation.h
//  iMods
//
//  Created by Brendon Roberto on 11/15/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IMOAnimationBlock)(UIView *);
NSString *const IMOAnimationDurationKey = @"IMOAnimationDurationKey";
NSString *const IMOAnimationCurveKey = @"IMOAnimationTimingKey";
NSString *const IMOAnimationDelayKey = @"IMOAnimationDelayKey";
NSString *const IMOAnimationIDKey = @"IMOAnimationIDKey";
NSString *const IMOAnimationContextKey = @"IMOAnimationContextKey";

@interface UIView(IMOAnimation)
- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options;
- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options completion:(void(^)(void))completion;
@end
