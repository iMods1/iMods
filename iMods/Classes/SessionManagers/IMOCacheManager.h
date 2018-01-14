//
//  IMOCacheManager.h
//  iMods
//

#import <Foundation/Foundation.h>

@interface IMOCacheManager : NSObject
	+ (IMOCacheManager*) sharedCacheManager;
	@property (strong, nonatomic) NSMutableDictionary *assetCache;
	- (void) setObject:(NSDictionary *)object forKey:(NSString *)key;
	- (NSDictionary *) objectForKey:(NSString *)key;
@end
