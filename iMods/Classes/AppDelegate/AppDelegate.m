#import "AppDelegate.h"
#import "IMOConstants.h"
#import "IMOLoginViewController.h"
#import "IMOResetPasswordViewController.h"
#import "IMOScreenShotViewController.h"
#import "Stripe.h"
#import <PayPal-iOS-SDK/PayPalMobile.h>
#include "xpc.h"
#include <objc/runtime.h>
#import "IMOItemManager.h"
#import "IMOItem.h"
#import "NSTask.h"

@protocol FeedMeACookie
- (void)feedMeACookie: (id)cookie;
@end

@interface NSXPCInterface : NSObject
-(id)interfaceWithProtocol:(id)protocol;
@end

// FIXME: Replace sandbox account credentials with live account credentials
NSString * const StripePublishableKey = @"pk_test_4ZdjKL2iALVVPu62VM8BbbAE";
NSString * const PaypalClientID = @"AYIxPRAn9AN93GvsRpCpEWwvoRtltxlexuAThDlk5br4ElJDHdY9sHt-YZU8";

@interface AppDelegate ()

@property (strong, nonatomic) NSString *documentsDirectoryPath;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationIncompatibleStoresDirectory;

- (NSString *)nameForIncompatibleStore;

@end

@implementation AppDelegate

BOOL isRunningTests(void) __attribute__((const));

BOOL isRunningTests(void) {
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    NSLog(@"Path extension: %@", [injectBundle pathExtension]);
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (isRunningTests()) {
        NSLog(@"Running tests...");
        self.sharedSessionManager = nil;
        self->_isRunningTest = YES;
        self->_paymentProductionMode = NO;
        return YES;
    }
    self->_isRunningTest = NO;
    self.sharedSessionManager = [IMOSessionManager sharedSessionManager:[NSURL URLWithString: [BASE_API_ENDPOINT stringByAppendingString: @"/api/"]]];
//    self.sharedSessionManager = [IMOSessionManager sharedSessionManager:[NSURL URLWithString: [@"http://192.168.119.1:8000" stringByAppendingString: @"/api/"]]];
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    NSURL* handlelUrl = [launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (handlelUrl) {
        [self application:application handleOpenURL:handlelUrl];
    }
    
    // Change page control indicator colors in the screenshot view
    UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[IMOScreenShotViewController class], nil];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    // Initialize paypal payment API
    // FIXME: Switch to production mode when release
    self->_paymentProductionMode = NO;
    if (self.paymentProductionMode) {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : PaypalClientID}];
    } else {
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox : PaypalClientID}];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if ([[IMOPackageManager sharedPackageManager] lastInstallNeedsRespring]) {
        NSTask *task = [[NSTask alloc] init];
       [task setLaunchPath: @"/usr/bin/imodsinstall"];
       [task setArguments: [[NSArray alloc] initWithObjects: @"respring", nil]];
       [task launch];
    }
     
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSLog(@"url: %@", [url absoluteString]);
    if (![url.scheme isEqualToString:@"imods"]) {
        return NO;
    }
    // Handle reset password request
    NSLog(@"host: %@", url.host);
    if([url.host isEqualToString:@"user"]) {
        NSLog(@"path: %@", url.path);
        if ([url.path isEqualToString:@"/reset_password"]) {
            // Handle reset_password URL
            NSDictionary* params = [self parseQueryString: url.query];
            NSString* email = [params valueForKey:@"email"];
            NSString* token = [params valueForKey:@"token"];
            email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            token = [token stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([email length] == 0 || [token length] == 0) {
                return NO;
            }
            NSDictionary* data = @{
                                   @"email": email,
                                   @"token": token
                                   };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetPassword" object: data];
        }
    }
    return NO;
}

@end