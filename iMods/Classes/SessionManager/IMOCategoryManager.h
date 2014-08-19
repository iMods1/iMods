//
//  IMOCategorySession.h
//  iMods
//
//  Created by Ryan Feng on 8/11/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMOSessionManager.h"

@interface IMOCategoryManager: NSObject
/* Async fetch categories, the final result should be a NSArray of IMOCategory.
 */
-(PMKPromise*) fetchCategories;
-(PMKPromise*) fetchCategoriesByName:(NSString*)category;
-(PMKPromise*) fetchCategoriesByID:(NSNumber*)categoryID;

/* Get featured apps, the final result should be a NSArray of IMOItem.
 */
-(PMKPromise*) fetchFeatured;
-(instancetype) init;
@end