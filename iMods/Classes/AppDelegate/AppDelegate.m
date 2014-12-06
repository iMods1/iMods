//
//  AppDelegate.m
//  iMods
//
//  Created by Ryan Feng on 9/22/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "AppDelegate.h"
#import "IMOConstants.h"
#import "IMOLoginViewController.h"
#import "IMOResetPasswordViewController.h"
#import "IMOScreenShotViewController.h"
#import "Stripe.h"
#import <PayPal-iOS-SDK/PayPalMobile.h>

// FIXME: Replace sandbox account credentials with live account credentials
NSString * const StripePublishableKey = @"pk_test_4ZdjKL2iALVVPu62VM8BbbAE";
NSString * const PaypalClientID = @"AYIxPRAn9AN93GvsRpCpEWwvoRtltxlexuAThDlk5br4ElJDHdY9sHt-YZU8";

@interface AppDelegate ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSString *documentsDirectoryPath;
@property (assign, nonatomic) BOOL shouldUseCoreData;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationIncompatibleStoresDirectory;

- (NSString *)nameForIncompatibleStore;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;

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

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Trigger checking package updates
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iMods.sqlite"];
    
    NSError *error = nil;
    
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES),
                               NSInferMappingModelAutomaticallyOption : @(YES) };
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Error initializing persistent store coordinator: error %@, %@", error, [error userInfo]);
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // Move Incompatible Store
        if ([fm fileExistsAtPath:[storeURL path]]) {
            NSURL *corruptURL = [[self applicationIncompatibleStoresDirectory] URLByAppendingPathComponent:[self nameForIncompatibleStore]];
            
            // Move Corrupt Store
            NSError *errorMoveStore = nil;
            [fm moveItemAtURL:storeURL toURL:corruptURL error:&errorMoveStore];
            
            if (errorMoveStore) {
                NSLog(@"Unable to move corrupt store.");
            }
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iMods" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
        // Create the directory on a jailbroken phone
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error: &error];
        if (error) {
            NSLog(@"Error creating document directory path: %@", error.localizedDescription);
            self.shouldUseCoreData = NO;
        }
    }
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    return storeURL;
}

- (NSURL *)applicationIncompatibleStoresDirectory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *URL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Incompatible"];
    
    if (![fm fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        [fm createDirectoryAtURL:URL withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            NSLog(@"Unable to create directory for corrupt data stores: %@", error.localizedDescription);
            
            return nil;
        }
    }
    
    return URL;
}

- (NSString *)nameForIncompatibleStore {
    // Initialize Date Formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Configure Date Formatter
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    return [NSString stringWithFormat:@"%@.sqlite", [dateFormatter stringFromDate:[NSDate date]]];
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