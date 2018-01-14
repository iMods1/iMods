#import <objc/runtime.h>

@implementation IMOPackageManager

/*
    New iMods Package Management Backend.
    Goal: Lower overhead of requests to server and simplify the installation process.
    - Fetch conflicting modIds + version numbers from server associated with mainModId
    - Determine confliction locally
    - If confliction exists perform analysis to determine whether the confliction can be resolved without effecting other packages
    - Do any installed packages conflict with this package?
    - If no viable options abort

    - If no conflictions proceed to fetch pre-depends+depends (modId + version) tree for mainModId
    - Compare dependencies to installed
    - Determine upgrades + new installs

    Side Note: icon caching. On server store SHA-256 checksum. Return this to diff between avatars without sending image data.
*/

- (void) computeInstallGraph:(NSString *)bundleId {
    NSArray *knownConflicts = //
    for (NSString *modId in knownConflicts) {
      //
    }
    return 0;
}

- (NSMutableArray *)parseStatusFile:(NSString *)rawStatusFile {
    NSMutableArray *packages = [[NSMutableArray alloc] init];
    NSArray *rawPackages = [rawStatusFile componentsSeparatedByString:@"\n\n"];
    for (NSString *rawPackage in rawPackages){
        NSMutableDictionary *package = [[NSMutableDictionary alloc] init];
        NSArray *packageParameters = [rawPackage componentsSeparatedByString:@"\n"];
        for (NSString *parameter in packageParameters) {
            if (([parameter rangeOfString:@" "].location == 0) || ([parameter rangeOfString:@"\t"].location == 0))
                continue;
            NSArray *splitParameter = [parameter componentsSeparatedByString:@": "];
            if ([splitParameter count] < 2)
                continue;
            NSString *parameterId = [splitParameter objectAtIndex:0];
            NSString *parameterValue = [splitParameter objectAtIndex:1];
            [package setObject:parameterValue forKey:parameterId];
        }
        if (![package objectForKey:@"Package"])
            continue;
        [package setObject:[[package objectForKey:@"Package"] stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Package"];
        if ([[package objectForKey:@"Package"] isEqualToString:@""])
            continue;
        if (![package objectForKey:@"Version"])
            continue;
        if ([package objectForKey:@"Status"]) {
            if ([[package objectForKey:@"Status"] isEqualToString:@"install ok installed"])
                [packages addObject:package];
        }
    }
    return packages;
}

@end
