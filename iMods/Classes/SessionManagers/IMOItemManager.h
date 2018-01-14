//
//  IMOItemManager.h
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "IMODev.h"

@interface IMOItemManager : NSObject

- (instancetype) init;

/* Fetch an item from the server, result is an IMOItem object.
 * @param pkg_id Package ID
 */
- (PMKPromise*) fetchItemByID:(NSUInteger) pkg_id;
- (PMKPromise*) fetchItemByName:(NSString*) pkg_name;
- (PMKPromise*) fetchItemsByCategory:(NSString*) category_name;
- (PMKPromise*) fetchItemsByAuthor:(NSString*) author_name;
- (PMKPromise*) fetchItemBySearchTerm:(NSString *)search_term;

@end
