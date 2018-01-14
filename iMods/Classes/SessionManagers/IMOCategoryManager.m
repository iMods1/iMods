//
//  IMOCategorySession.m
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOCategoryManager.h"

@implementation IMOCategoryManager

static IMOSessionManager* sessionManager = nil;

// TODO implement a category cache. we don't need to constantly reload them. they can be reloaded in the BG
#pragma mark -
#pragma mark Initialization

- (id) init {
    self = [super init];
    if(self != nil){
        sessionManager = [IMOSessionManager sharedSessionManager];
        if (sessionManager == nil) {
            NSLog(@"Failed to get session manager instance");
        }
    }
    return self;
}

#pragma mark -
#pragma mark Fetching categories

-(PMKPromise*) fetchCategories {
    return [sessionManager getJSON:@"category/list" parameters:nil];
}

-(PMKPromise*) fetchCategoriesByID:(NSNumber *)categoryID{
    return [sessionManager getJSON:@"category/id" urlParameters:@[[categoryID stringValue]] parameters:nil];
}

-(PMKPromise*) fetchCategoriesByName:(NSString *)category {
    return [sessionManager getJSON:@"category/name" urlParameters:@[category] parameters:nil];
}

#pragma mark -
#pragma mark Featured category

-(PMKPromise*) fetchFeatured {
    return [sessionManager getJSON:@"category/featured" parameters:nil];
}
@end