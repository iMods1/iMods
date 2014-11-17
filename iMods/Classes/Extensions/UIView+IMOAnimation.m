//
//  UIView+IMOAnimation.m
//  iMods
//
//  Created by Brendon Roberto on 11/15/14.
//  Copyright (c) 2014 Brendon Roberto. All rights reserved.
//

#import "UIView+IMOAnimation.h"

@implementation UIView(IMOAnimation)

- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options{
    [UIView beginAnimations:[options valueForKey:IMOAnimationIDKey] context:(__bridge void *)([options valueForKey:IMOAnimationContextKey])];
    
    if ([[options valueForKey:IMOAnimationDurationKey] isKindOfClass:[NSNumber class]]) {
        [UIView setAnimationDuration:[((NSNumber *)[options valueForKey:IMOAnimationDurationKey]) doubleValue]];
    } else {
        [UIView setAnimationDuration:1.0];
    }
    
    if ([[options valueForKey: IMOAnimationDelayKey] isKindOfClass:[NSNumber class]]) {
        [UIView setAnimationDelay:[((NSNumber *)[options valueForKey:IMOAnimationDelayKey]) doubleValue]];
    } else {
        [UIView setAnimationDelay:0.0];
    }
    
    if ([[options valueForKey:IMOAnimationCurveKey] isKindOfClass: [NSNumber class]]) {
        [UIView setAnimationCurve:[((NSNumber *)[options valueForKey:IMOAnimationCurveKey]) integerValue]];
    } else {
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    }
    
    block(self);
    
    [UIView commitAnimations];
}

- (void) animateWithBlock:(IMOAnimationBlock)block options:(NSDictionary *)options completion:(void (^)(void))completion {
    [self animateWithBlock:block options:options];
    completion();
}
@end
