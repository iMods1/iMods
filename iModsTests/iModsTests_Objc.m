//
//  iModsTests_Objc.m
//  iMods
//
//  Created by Ryan Feng on 8/18/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "IMOUserManager.h"
#import "IMOCategory.h"
#import "IMOCategoryManager.h"
#import "IMOItem.h"
#import "IMOItemManager.h"

@interface iModsTestCase: XCTestCase

@property (readonly) IMOSessionManager* sessionManager;
@property (readonly) NSString* build;

@property (readonly) NSString* userFullName;
@property (readonly) NSString* userEmail;
@property (readonly) IMOUserManager* userManager;


@end

@implementation iModsTestCase

- (void)setUp {
    [super setUp];
    self->_sessionManager = [IMOSessionManager sharedSessionManager:[NSURL URLWithString:@"http://192.168.119.1:8000/api/"]];
    self->_userManager = [IMOUserManager sharedUserManager];
    self->_build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*) kCFBundleVersionKey];
    self->_userFullName = [NSString stringWithFormat:@"test-%@@imods.com", self.build];
    self->_userEmail = [NSString stringWithFormat:@"testing-%@", self.build];
}

- (void)tearDown {
    [self logout];
    [super tearDown];
}

- (void) login:(NSString*)email password:(NSString*)password {
    [self.userManager userLogin:email password:password]
    .then(^(OVCResponse* response, NSError* error){
        if (error) {
            XCTFail(@"User login failed");
        }
    });
}

- (void) logout {
    [self.userManager userLogout];
}

- (void) waitFor:(double)interval {
    [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:interval]];
}

@end

@interface CategorySessionTest: iModsTestCase
@end

@implementation CategorySessionTest

IMOCategoryManager* categoryManager = nil;

- (void)setUp {
    [super setUp];
    categoryManager = [[IMOCategoryManager alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFeatured{
    __block BOOL resolved = NO;
    PMKPromise* request = [categoryManager fetchFeatured];
    XCTAssertNotNil(request);
    request.then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error, @"Error occurred during request");
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
    })
    .finally(^(){
        resolved = YES;
    });
    [self waitFor: 0.2];
    XCTAssertTrue(resolved);
}

- (void)testFetchCategoryByName{
    __block BOOL resovled = NO;
    [categoryManager fetchCategoriesByName:@"featured"]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        NSArray* cat_list = response.result;
        XCTAssertNotNil(cat_list);
        IMOCategory* featured = [cat_list objectAtIndex:0];
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resovled = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resovled);
}

- (void)testFetchCategoryByID{
    __block BOOL resolved = NO;
    [categoryManager fetchCategoriesByID:@1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        IMOCategory* featured = response.result;
        XCTAssertNotNil(featured);
        XCTAssert([featured.name isEqualToString:@"featured"]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end

@interface ItemTest : iModsTestCase

@end

@implementation ItemTest

IMOItemManager* itemManager = nil;

- (void)setUp {
    [super setUp];
    itemManager = [[IMOItemManager alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testItemFetch {
    __block BOOL resolved = NO;
    [itemManager fetchItem:1].then(^(OVCResponse* response, NSError* error){
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        IMOItem* item = response.result;
        XCTAssert([item isKindOfClass:[IMOItem class]]);
        XCTAssert(item.pkg_name);
        XCTAssert(item.item_id == 1);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

@end

@interface UserManagerTest: iModsTestCase

@end

@implementation UserManagerTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_01_UserLogin {
    PMKPromise* request = [self.userManager userLogin:@"test@test.com" password:@"test"];
    __block BOOL resolved = NO;
    request.finally(^{
        XCTAssert(self.userManager.userLoggedIn);
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void)test_02_UserLogout {
    [self.userManager userLogout];
    XCTAssert(self.userManager.userLoggedIn == NO);
    [self login:@"test@test.com" password:@"test"];
}

- (void) test_03_UserRegister {
    PMKPromise* request = [self.userManager userRegister:self.userEmail password:@"password" fullname:self.userFullName age:@10 author_id:@"imods.testing"];
    __block BOOL resolved = NO;
    request.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        XCTAssert([user.fullname isEqualToString:self.userFullName]);
        XCTAssert([user.email isEqualToString:self.userEmail]);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self logout];
    PMKPromise* login = [self.userManager userLogin:self.userEmail password:@"password"];
    login.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        resolved = YES;
    });
    [self waitFor:0.2];
    [self logout];
    XCTAssert(resolved);
}

- (void) test_04_UserUpdate {
    NSString* newname = [NSString stringWithFormat:@"testing_update %@", self.build];
    __block BOOL resolved = NO;
    PMKPromise* request = [self.userManager updateUserProfile:newname age:@(self.userManager.userProfile.age+1)];
    request.finally(^{
        IMOUser* user = self.userManager.userProfile;
        XCTAssertNotNil(user);
        XCTAssert([user.fullname isEqualToString:newname]);
        resolved = YES;
    });
    [self waitFor:0.2];
    [self logout];
    XCTAssert(resolved);
}
@end

@interface BillingInfoTest : iModsTestCase

@end

@implementation BillingInfoTest

- (void) setUp {
    [super setUp];
    [super login:@"test@test.com" password:@"test"];
    [self waitFor:0.2];
}

- (void) tearDown {
    [super tearDown];
}

- (void) test_05_BillingMethodAdd {
    NSDictionary* billing = @{
                              @"address": [NSString stringWithFormat:@"address-%@", self.build],
                              @"zipcode": @12345,
                              @"city": @"kent",
                              @"state": @"ohio",
                              @"country": @"USA",
                              @"type_": @"creditcard",
                              @"cc_name": @"Ryan Feng",
                              @"cc_no": @"1234567890",
                              @"cc_expr": @"09/17",
                              @"cc_cvv":@123
                            };
    NSError* error = nil;
    IMOBillingInfo* billingInfo = [MTLJSONAdapter modelOfClass:IMOBillingInfo.class fromJSONDictionary:billing error:&error];
    XCTAssertNil(error);
    
    __block BOOL resolved = NO;
    // Add first billing info
    [self.userManager addNewBillingMethod:billingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.userManager.userProfile.billing_methods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 12345);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    // Add second billing info
    resolved = NO;
    [self.userManager addNewBillingMethod:billingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.userManager.userProfile.billing_methods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 12345);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_06_BillingMethodUpdate {
    [self.userManager refreshBillingMethods];
    [self waitFor:0.2];
    
    IMOBillingInfo* lastBilling = [self.userManager.userProfile.billing_methods lastObject];
    NSDictionary* newbilling = @{
                              @"bid": @(lastBilling.bid),
                              @"uid": @(lastBilling.uid),
                              @"address": [NSString stringWithFormat:@"newaddress-%@", self.build],
                              @"zipcode": @54321,
                              @"city": @"newkent",
                              @"state": @"newohio",
                              @"country": @"newUSA",
                              @"type_": @"paypal",
                              @"cc_name": @"New Ryan Feng",
                              @"cc_no": @"0987654321",
                              @"cc_cvv": @123,
                              @"cc_expr": @"01/23"
    };
    NSError* error = nil;
    IMOBillingInfo* newBillingInfo = [MTLJSONAdapter modelOfClass:IMOBillingInfo.class fromJSONDictionary:newbilling error:&error];
    XCTAssertNil(error);
    
    __block BOOL resolved = NO;
    [self.userManager updateBillingMethod:newBillingInfo]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        IMOBillingInfo* billing = [self.userManager.userProfile.billing_methods lastObject];
        XCTAssertNotNil(billing);
        // Integrity check
        XCTAssert(billing.zipcode == 54321);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}

- (void) test_07_BillingMethodRemove {
    [self.userManager refreshBillingMethods];
    [self waitFor:0.2];
    IMOBillingInfo* billing = [self.userManager.userProfile.billing_methods lastObject];
    NSUInteger billingCount = [self.userManager.userProfile.billing_methods count];
    XCTAssertNotNil(billing);
    XCTAssert(billingCount > 0);
    
    __block BOOL resolved = NO;
    [self.userManager removeBillingMethod:billing]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert(self.userManager.userProfile.billing_methods.count == billingCount - 1);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
    
    resolved = NO;
    [self.userManager removeBillingMethodAtIndex:[self.userManager.userProfile.billing_methods count]-1]
    .then(^(OVCResponse* response, NSError* error){
        XCTAssertNil(error);
        XCTAssert(self.userManager.userProfile.billing_methods.count == billingCount - 2);
        resolved = YES;
    });
    [self waitFor:0.2];
    XCTAssert(resolved);
}
@end

@interface OrderTest : iModsTestCase

@end

@implementation OrderTest

- (void)setUp {
    [super setUp];
    [self login:@"test@test.com" password:@"test"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPlaceNewOrder {
    NSDictionary* jsonData = @{
                               @"item_id": @1,
                               @"quantity": @1,
                               @"currency": @"USD",
                               @"billing_id": @1,
                               @"total_price": @0.99,
                               @"total_charged": @1.99
                               };
    NSError * error = nil;
    IMOOrder* order = [MTLJSONAdapter modelOfClass:IMOOrder.class fromJSONDictionary:jsonData error:&error];
    XCTAssertNil(error);
    __block BOOL resolved = NO;
}

@end