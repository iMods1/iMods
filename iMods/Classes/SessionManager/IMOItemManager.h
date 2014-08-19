//
//  IMOItemManager.h
//  iMods
//
//  Created by Ryan Feng on 8/12/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>

@interface IMOItemManager : NSObject

- (instancetype) init;

/* Fetch an item from the server, result is an IMOItem object.
 * @param pkg_id Package ID
 */
- (PMKPromise*) fetchItem:(NSInteger)pkg_id;

// TODO: fetchItemPreviewAssets should return something that can be directly used by controllers and views.
/* Fetch and store preview assets of an item.
 * @param pkg_id Package ID
 * @param dstPath destination path of stored assets, should be the path to a local folder. *Optional*
 */
- (PMKPromise*) fetchItemPreviewAssets:(NSInteger)pkg_id dstPath:(NSString*)dstPath;

@end
