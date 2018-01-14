//
//  IMOReviewManager.h
//  iMods
//
//  Created by Ryan Feng on 8/24/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOReview.h"
#import "IMOUser.h"
#import "IMOItem.h"

@interface IMOReviewManager : NSObject

- (PMKPromise*) getReviewsByItem:(IMOItem*)item;
- (PMKPromise*) getReviewsByUser:(IMOUser*)user;
- (PMKPromise*) addReviewForItem:(IMOItem*)item review:(IMOReview*)review;
- (PMKPromise*) updateReview:(IMOReview*)newReview;
- (PMKPromise*) removeReview:(IMOReview*)review;

@end
