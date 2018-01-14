//
//  IMOCacheManager.m
//  iMods
//

#import "IMOCacheManager.h"

@implementation IMOCacheManager
- (id)init {
    self = [super init];
    if(self != nil){
        self.assetCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (IMOCacheManager*) sharedCacheManager {
    static IMOCacheManager* sharedCacheManager = nil;
    if (sharedCacheManager) {
        return sharedCacheManager;
    }
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        sharedCacheManager = [[IMOCacheManager alloc] init];
    });
    return sharedCacheManager;
}

- (NSDictionary *) objectForKey:(NSString *)key {
    return [self.assetCache objectForKey:key];
}

- (void) setObject:(NSDictionary *)object forKey:(NSString *)key {
    [self.assetCache setObject:object forKey:key];
}

@end
